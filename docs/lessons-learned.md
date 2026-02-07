# 經驗教訓記錄

> 最後更新：2026-01-28

本文件記錄系統開發與執行過程中遇到的問題與解決方案，避免未來重複犯錯。

---

## 1. Fetch 層級問題

### 1.1 Shell Script 能力限制

| 問題 | 影響的 Layer | 說明 |
|------|-------------|------|
| **curl 無法處理動態網站** | tw_company_reviews | 網站使用 React/Next.js 動態渲染，curl 只能抓到空殼 HTML |
| **反爬機制封鎖** | global_wef_jobs | WEF 網站所有 URL 回應 HTTP 403 |
| **API endpoint 失效** | tw_104_jobs | 104 人力銀行 API 回應 404，可能已改版或需要認證 |
| **依賴未安裝工具** | tw_govjobs | 依賴 `pup` HTML 解析工具但未安裝 |

**教訓**：
- Shell script + curl 只適合 RSS feed 和公開 REST API
- 需要 JavaScript 執行的網站必須用 headless browser（Puppeteer/Playwright）
- 建立 Layer 前應先手動測試資料源可及性

**建議**：
- 優先選用有 RSS/API 的資料源
- 若必須爬網站，考慮引入 Python + Playwright 模組
- 在 CLAUDE.md 中標註資料源的技術需求（curl 可抓 / 需要 JS 執行）

### 1.2 Bash 3.2 相容性（macOS）

| 問題 | 說明 |
|------|------|
| `declare -A` 不支援 | macOS 預設 bash 3.2 不支援 associative array |

**教訓**：
- macOS 預設 bash 版本為 3.2（2007 年），缺少許多現代功能
- `declare -A`（associative array）需要 bash 4.0+

**解法**：
```bash
# 錯誤寫法（bash 4.0+ only）
declare -A REGIONS=(
  ["au"]="https://example.com/au"
  ["uk"]="https://example.com/uk"
)

# 正確寫法（bash 3.2 相容）
REGION_CODES=("au" "uk")
REGION_URLS=("https://example.com/au" "https://example.com/uk")

for i in "${!REGION_CODES[@]}"; do
  code="${REGION_CODES[$i]}"
  url="${REGION_URLS[$i]}"
  # ...
done
```

### 1.3 jq 路徑錯誤

| 問題 | 影響的 Layer |
|------|-------------|
| `.categories[].roles[]` 路徑不存在 | tw_govjobs |

**教訓**：
- 在 fetch.sh 中使用 jq 讀取 JSON 前，應先驗證 JSON 結構
- 建議在 CLAUDE.md 或腳本註解中記錄預期的 JSON schema

---

## 2. 萃取層級問題

### 2.1 WebFetch 子代理限制

| 問題 | 影響範圍 | 說明 |
|------|---------|------|
| **WebFetch 自動被拒絕** | 所有子代理 | 背景執行的 Task 子代理無法使用 WebFetch 工具 |

**影響的 Layer**（WebFetch 策略為「必用」）：
- global_hays_salary — 23 筆全部 REVIEW_NEEDED
- global_linkedin_workforce — 12 筆全部 REVIEW_NEEDED
- global_manpower_outlook — 3 筆全部 REVIEW_NEEDED

**教訓**：
- 子代理在背景模式執行時，WebFetch 權限會被自動拒絕
- 這不是 bug，是平台設計的安全限制
- WebFetch 策略為「必用」的 Layer 在子代理模式下會產生大量 REVIEW_NEEDED

**解法選項**：
1. **接受降級**：讓這些 Layer 產出有限資訊，標記 REVIEW_NEEDED 供人工補充
2. **前景執行**：不使用 Task 子代理，改由頂層 Claude 直接執行（但會很慢）
3. **改善資料源**：找到有完整 RSS description 的替代來源，減少對 WebFetch 的依賴

### 2.2 JSONL 處理規範

| 問題 | 說明 |
|------|------|
| 直接用 Read tool 讀取 .jsonl | JSONL 可能很大，會超出 token 上限 |

**正確做法**：
```bash
# 取得總行數
wc -l < file.jsonl

# 逐行讀取（N = 1, 2, 3, ...）
sed -n '{N}p' file.jsonl
```

### 2.3 Write Tool 強制規定

| 問題 | 說明 |
|------|------|
| 使用 Bash heredoc 寫檔 | 可能有 escaping 問題，且不符合系統規範 |

**正確做法**：
- 一律使用 Write tool 產生 .md 檔
- 禁止使用 `cat > file.md <<'EOF'` 等 heredoc 寫法

---

## 3. Update 層級問題

### 3.1 Qdrant 寫入未實作

| 問題 | 說明 |
|------|------|
| `qdrant_upsert_document` 被註解 | update.sh 僅執行 REVIEW_NEEDED 掃描，未實際寫入 Qdrant |

**現況**：
- workforce_news 和 funding_signals 的 update.sh 有完整 Qdrant 連線邏輯
- 但實際的 `qdrant_upsert_document` 呼叫為註解狀態
- 其他 6 個 Layer 的 update.sh 為框架腳本

**待辦**：
- 實作 `lib/qdrant.sh` 中的 `qdrant_upsert_document` 函式
- 取消 update.sh 中的註解

### 3.2 GitHub Issue 建立失敗

| 問題 | 說明 |
|------|------|
| `gh issue create` 失敗 | 工作目錄不是 git repo，或未設定 remote |

**解法**：
- 確保工作目錄是 git repo 且已設定 GitHub remote
- 或在 update.sh 中加入檢查，若非 git repo 則跳過 issue 建立

---

## 4. Layer 設計問題

### 4.1 不存在的 Layer 被列入計畫

| Layer 名稱 | 狀態 |
|-----------|------|
| ai_displacement_news | 從未建立 |
| ai_benchmark_tracker | 從未建立 |
| global_wef_reports | 實際名稱為 global_wef_jobs |

**教訓**：
- 在系統規劃文件中列出的 Layer 應與實際目錄結構保持同步
- 建議維護一份 Layer registry（可在 README.md 或獨立文件）

### 4.2 WebFetch 策略選擇

| 策略 | 適用場景 | 子代理相容性 |
|------|---------|-------------|
| **不使用** | RSS/API 已包含完整資訊 | ✅ 完全相容 |
| **按需** | RSS 有時完整有時不足 | ⚠️ 降級為不使用 |
| **必用** | RSS 幾乎無資訊 | ❌ 全部產出 REVIEW_NEEDED |

**建議**：
- 新建 Layer 時優先選擇「不使用」或「按需」策略的資料源
- 若選擇「必用」策略，需接受子代理模式下的降級後果

---

## 5. 系統層級問題

### 5.1 環境依賴

| 依賴 | 用途 | 安裝方式 |
|------|------|---------|
| `pup` | HTML 解析 | `brew install pup` |
| `jq` | JSON 處理 | `brew install jq` |
| `xmllint` | XML 處理 | macOS 內建 |
| `gh` | GitHub CLI | `brew install gh` |

**建議**：
- 在 README.md 中列出所有系統依賴
- 提供 `scripts/setup.sh` 一鍵安裝依賴

### 5.2 .env 設定

必要的環境變數：
```
QDRANT_URL=...
QDRANT_API_KEY=...
QDRANT_COLLECTION=...
OPENAI_API_KEY=...
```

---

## 附錄：Layer 狀態總覽

| Layer | Fetch | 萃取 | Update | 備註 |
|-------|-------|------|--------|------|
| global_bls | ✅ | ✅ 143 筆 | ✅ | 3 筆 REVIEW_NEEDED（撥款中斷） |
| workforce_news | ✅ | ✅ 20 筆 | ✅ | 1 筆 REVIEW_NEEDED |
| funding_signals | ✅ | ✅ 37 筆 | ✅ | 1 筆 REVIEW_NEEDED |
| global_indeed_hiring | ✅ | ✅ 10 筆 | ✅ | |
| global_stackoverflow | ✅ | ✅ ~21 筆 | ✅ | |
| global_linkedin_workforce | ✅ | ✅ 12 筆 | ✅ | 12 筆全部 REVIEW_NEEDED（WebFetch 限制） |
| global_manpower_outlook | ✅ | ✅ 3 筆 | ✅ | 3 筆全部 REVIEW_NEEDED（WebFetch 限制） |
| global_hays_salary | ✅ | ✅ 23 筆 | ✅ | 23 筆全部 REVIEW_NEEDED（WebFetch 限制） |
| tw_104_jobs | ❌ | - | - | API 404 |
| tw_govjobs | ❌ | - | - | 工具缺失 + 解析錯誤 |
| tw_company_reviews | ❌ | - | - | 需要 JS 執行 |
| global_wef_jobs | ❌ | - | - | HTTP 403 封鎖 |
| ai_displacement_news | ❌ | - | - | 目錄不存在 |
| ai_benchmark_tracker | ❌ | - | - | 目錄不存在 |
