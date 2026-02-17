# 產業智慧分析系統 — 初始 Prompt v2

## 一、系統概覽

### 1.1 系統目的

本系統是一套圍繞 Claude CLI 運作的產業智慧分析系統，透過多角色協作完成資料擷取、萃取、報告生成與品質審核。

### 1.2 架構角色

| 角色 | 職責 | 實現方式 |
|------|------|----------|
| **Architect** | 系統巡檢、資料源探索、指揮協調 | 由 Claude CLI 頂層直接扮演（無外部腳本） |
| **Extractor** | 資料擷取（fetch）與萃取（extract） | `core/Extractor/Layers/` 下的 Layer 定義 + shell 腳本 |
| **Narrator** | 跨來源綜合分析、報告產出 | `core/Narrator/Modes/` 下的 Mode 定義 |
| **Reviewer** | 自我審核 Checklist | 內嵌於每個 Layer/Mode 的 CLAUDE.md |

### 1.3 資料流

```
外部資料源（RSS/API）
  → fetch.sh 下載原始資料 → docs/Extractor/{layer}/raw/*.jsonl
  → Claude 萃取（逐行處理）→ docs/Extractor/{layer}/{category}/*.md
  → update.sh 寫入 Qdrant + 檢查 REVIEW_NEEDED
  → Narrator Mode 讀取 Layer 資料 → docs/Narrator/{mode}/*.md
```

---

## 二、執行編排模型

### 2.1 編排架構

本系統由 **Claude CLI 全程編排**，透過 Task tool 分派子代理執行各步驟。這不是 shell-based 互動模式（不會 `cd` + `claude` 逐步執行）。

```
頂層 Claude CLI（Opus）
├── Task(Bash, sonnet)     → 目錄掃描、fetch.sh、update.sh
├── Task(general-purpose, sonnet) → Layer 萃取（需 Write tool 寫 .md 檔）
└── Task(general-purpose, opus)   → Mode 報告產出（需跨來源綜合分析）
```

### 2.2 模型與子代理指派規則

| 步驟 | 任務類型 | 指定模型 | 子代理類型 | 原因 |
|------|----------|----------|------------|------|
| 步驟一 | 動態發現所有 Layer | `sonnet` | `Bash` | 純目錄掃描，無需推理 |
| 步驟二 | fetch.sh 執行 | `sonnet` | `Bash` | 純腳本執行 |
| 步驟二 | Layer 萃取（RSS → Markdown） | `sonnet` | `general-purpose` | 需用 Write 工具寫 .md 檔 |
| 步驟二 | update.sh 執行 | `sonnet` | `Bash` | 純腳本執行 |
| 步驟三 | 動態發現所有 Mode | `sonnet` | `Bash` | 純目錄掃描，無需推理 |
| 步驟四 | Mode 報告產出 | `opus` | `general-purpose` | 需要跨來源綜合分析、趨勢判斷 |

> **強制規則**：只有步驟四（Mode 報告產出）使用 `opus`，其餘所有步驟一律使用 `sonnet`。
> **子代理規則**：需要寫入檔案的 Task 必須使用 `general-purpose`（透過 Write 工具寫檔），純腳本執行使用 `Bash`。

### 2.3 平行分派策略

- JSONL 萃取可平行分派多個 Task（例如：20 筆 JSONL 可一次分派 10 個 Task）
- 多個 Layer 的 fetch.sh 可平行執行（彼此獨立）
- Mode 報告產出：前 4 個 Mode 可平行執行，**career_strategy 必須最後執行**（依賴其他報告輸出）

### 2.4 背景執行與主執行緒分工

**原則**：Opus 主執行緒保持空閒以監控進度、處理例外，耗時任務委派給 Sonnet 背景執行。

### 2.5 擷取頻率控制

**原則**：避免重複擷取已有的資料，節省資源與時間。

| Layer 類型 | 建議頻率 | 判斷方式 |
|------------|----------|----------|
| **職缺資料** (tw_govjobs, global_hn_hiring, global_arbeitnow 等) | 每週一次 | 檢查 `.last_fetch` 時間戳 |
| **報告/研究** (global_bls, global_linkedin_workforce 等) | 每週一次 | 檢查 `.last_fetch` 時間戳 |
| **新聞事件** (workforce_news, funding_signals) | 每日一次 | 新聞時效性較高 |

**跳過 fetch 的條件**：
```bash
# 檢查 .last_fetch 時間戳
last_fetch=$(cat docs/Extractor/{layer}/raw/.last_fetch 2>/dev/null)
days_since=$(( ($(date +%s) - $(date -d "$last_fetch" +%s 2>/dev/null || echo 0)) / 86400 ))

# 若距離上次 fetch 不足 7 天，跳過
if [[ $days_since -lt 7 ]]; then
  echo "跳過 {layer}：上次 fetch 於 $last_fetch（$days_since 天前）"
fi
```

**強制 fetch**：使用者說「強制更新」或「force fetch」時，忽略頻率限制。

### 2.6 主動資料源探索

**原則**：系統應定期探索新的資料來源，擴展觀測範圍。

執行時機：
- 使用者明確要求：「找新的資料來源」「探索新來源」
- 每月系統巡檢時

探索流程：
1. 使用 WebSearch 搜尋新的就業市場資料來源
2. 評估 API/RSS 可用性、資料品質、涵蓋範圍
3. 將結果寫入 `docs/explored.md`（評估中表格）
4. P1 優先級的來源建議立即建立 Layer

| 任務類型 | 執行方式 | 說明 |
|----------|----------|------|
| fetch.sh（多個 Layer） | `Task(Bash, sonnet, run_in_background=true)` | 平行背景執行，Opus 監控 |
| JSONL 萃取 | `Task(general-purpose, sonnet)` | 批次平行分派 |
| Qdrant 搜尋 | Opus 直接執行 | 快速操作，不需委派 |
| Mode 報告（前 4 個） | `Task(general-purpose, opus)` 平行 | 同時分派 4 個 Task |
| career_strategy 報告 | `Task(general-purpose, opus)` | **等待前 4 個完成後**再執行 |
| git push | Opus 直接執行 | 快速操作，需確認結果 |

**背景任務監控**：
```
1. 分派 Task 時設定 run_in_background=true
2. 使用 TaskOutput 檢查進度（block=false）
3. 任務完成後繼續下一步驟
```

---

## 三、執行流程

使用者說「執行完整流程」或「更新資料」時，依照以下步驟執行：

### 步驟一：動態發現所有 Layer

掃描 `core/Extractor/Layers/*/`，排除含有 `.disabled` 檔案的目錄。
每個有效 Layer 目錄應包含 `fetch.sh`、`update.sh`、`CLAUDE.md`。

### 步驟二：逐一執行 Layer

對每個 Layer 依序執行：

1. **fetch** — 執行 `core/Extractor/Layers/{layer_name}/fetch.sh` 下載原始資料
2. **萃取（逐行處理）** — 讀取該 Layer 的 `CLAUDE.md` 和 `core/Extractor/CLAUDE.md`，再對 `docs/Extractor/{layer_name}/raw/` 目錄中的 JSONL 逐行處理（詳見第四節 JSONL 處理規範）
3. **update** — 將步驟 2 產出的 `.md` 檔案路徑作為參數，執行 `core/Extractor/Layers/{layer_name}/update.sh {md_files...}` 寫入 Qdrant 並檢查 REVIEW_NEEDED

### 步驟三：動態發現所有 Mode

掃描 `core/Narrator/Modes/*/`，排除含有 `.disabled` 檔案的目錄。
每個有效 Mode 目錄應包含 `CLAUDE.md`。

### 步驟四：執行 Mode 報告產出

#### 4.1 執行順序

```
第一批（平行執行）：
├── Task(opus) → climate_index
├── Task(opus) → skills_drift
├── Task(opus) → industry_segments
└── Task(opus) → salary_bands

等待第一批完成後：
└── Task(opus) → career_strategy（依賴前 4 個報告）
```

#### 4.2 每個 Mode 執行步驟

1. **Qdrant 向量搜尋**（Opus 主執行緒執行，取得相關資料）
2. **分派 Task(opus)**，prompt 包含：
   - 該 Mode 的 `CLAUDE.md` 指令
   - Qdrant 搜尋結果
   - 來源 Layer 路徑（`docs/Extractor/{layer_name}/`）
3. **Task 內部**：
   - 讀取 Layer 資料（.md 檔）
   - 產出報告到 `docs/Narrator/{mode_name}/`
   - 報告必須標註「本報告使用 Qdrant 向量搜尋取得相關資料」
   - 設定正確的 Jekyll 前置資料（nav_order = 10000 - 週次）

### 步驟五：發布到 GitHub Pages

完成報告產出後，自動發布更新：

1. **更新首頁 index.md**（全部項目，避免遺漏）：
   - 頂部按鈕連結 → 最新週次
   - 「最新報告」表格 → 週次 + 連結
   - 「Modes 狀態」表格 → 最新報告週次
   - 「最後更新」日期 → 當天日期

2. **更新各 Mode 索引頁**：
   - `docs/Narrator/{mode}/index.md` 的 `redirect_to` 和按鈕連結

3. **提交並推送**：
   ```bash
   git add docs/Narrator/ index.md
   git commit -m "更新報告: {YYYY}-W{WW}"
   git pull --rebase && git push
   ```

> **注意**：推送後 GitHub Actions 會自動觸發 `pages.yml` 工作流程，重新建置並部署網站。

> **⚠️ 常見錯誤**：首頁有多處週次引用，必須全部更新，不可只改按鈕。

### 步驟六：品質檢查（強制）

完成所有步驟後，**必須**執行「十七、任務完成品質關卡」中的檢查清單：

1. 連結檢查
2. Jekyll Front Matter 檢查
3. 報告內容品質檢查
4. 內容更新確認
5. Git 狀態檢查
6. SOP 完成度檢查

> **⚠️ 未通過品質檢查的執行不視為成功。** 必須修正所有問題並重新檢查，直到全部通過才能回報「完成」。

### 指定執行

使用者也可以指定執行特定 Layer 或 Mode：

- 「執行 security_news_facts」→ 只跑該 Layer 的 fetch → 萃取 → update
- 「執行 threat_landscape」→ 只跑該 Mode 的報告產出
- 「只跑 fetch」→ 只執行所有 Layer 的 fetch.sh，不萃取
- 「只跑萃取」→ 假設 `docs/Extractor/{layer_name}/raw/` 已有 JSONL 資料，只做萃取 + update

> 指定執行時，模型指派規則仍然生效。Layer 相關任務使用 `sonnet`，Mode 相關任務使用 `opus`。

---

## 四、JSONL 處理規範

### 4.1 禁止行為

> **⛔ 禁止使用 Read 工具直接讀取 `.jsonl` 檔案**
> JSONL 檔案可能數百 KB，直接讀取會超出 token 上限。

### 4.2 正確流程

```
✅ 用 `wc -l < {jsonl_file}` 取得總行數
✅ 用 `sed -n '{N}p' {jsonl_file}` 逐行讀取（N = 1, 2, 3, ...）
✅ 每行獨立交由一個 Task 子代理處理
✅ 子代理透過 Write tool 寫出 .md 檔（不用 Bash heredoc）
```

### 4.3 子代理接收格式

每個萃取 Task 接收：
- **單一 JSON 字串**（sed 取出的該行內容）
- **Layer CLAUDE.md 的萃取邏輯**（作為 Task prompt 的一部分）
- **core/Extractor/CLAUDE.md 的通用規則**（WebFetch、REVIEW_NEEDED 等）

### 4.4 萃取前去重

在萃取前，應檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同 `source_url` 或 ID 的 `.md` 檔：
- 若存在且內容相同（同一筆資料重複擷取），**跳過**該筆
- 若存在但內容不同（同一來源的更新版本），依 Layer 策略決定**覆蓋**或**保留兩版**
- 去重檢查由頂層編排邏輯執行（在分派 Task 前），不由子代理自行判斷

---

## 五、WebFetch 補充機制

### 5.1 通用規則

RSS 的 `description` 欄位資訊量有限。萃取 Task 可透過 WebFetch 工具抓取 JSON 中 `link` 欄位指向的原始公告頁面，以取得完整內容。

- 各 Layer 的 CLAUDE.md 定義該 Layer 的 WebFetch 使用策略
- WebFetch 失敗**不阻斷**萃取流程，應降級為僅基於 RSS 資料萃取
- 降級時需在 `notes` 欄位標註
- 依各 Layer 的 `[REVIEW_NEEDED]` 觸發規則判定是否標記

### 5.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含 WebFetch 策略宣告：

| WebFetch 策略 | 說明 | 適用場景 |
|---------------|------|----------|
| **必用** | 一律使用 WebFetch 抓取原始頁面 | RSS description 幾乎無資訊（如 TVN 漏洞公告） |
| **按需** | description 不足時才使用 | RSS description 有時完整有時不足（如資安新聞） |
| **不使用** | 完全基於 RSS 資料萃取 | RSS 本身已包含完整結構化資料 |

按需策略的觸發條件（由各 Layer CLAUDE.md 定義），例如：
- description 內容不足 100 字
- 缺少特定關鍵欄位（CVE、CVSS、攻擊手法等）

---

## 六、`[REVIEW_NEEDED]` 標記規範

### 6.1 統一原則

| 概念 | 含義 | 標記方式 |
|------|------|----------|
| `[REVIEW_NEEDED]` | 萃取結果**可能有誤**，需要人工確認 | 在 .md 檔開頭加上 |
| `confidence: 低` | 資料來源有**結構性限制**（如單一來源、無交叉驗證） | 在 confidence 欄位反映 |

> **兩者不等價。** 子任務不可自行擴大判定範圍。

### 6.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含明確的觸發規則表：

```markdown
### `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. {具體場景 1 — 萃取結果可能有誤}
2. {具體場景 2}
...

以下情況**不觸發** `[REVIEW_NEEDED]`：
- ❌ {場景 A — 這是結構性限制，應在 confidence 欄位反映}
- ❌ {場景 B}
...
```

### 6.3 子任務合規

- 子任務必須**嚴格遵循** Layer CLAUDE.md 定義的觸發規則
- 不可因「僅單一來源、無交叉驗證」而自行標記 REVIEW_NEEDED
- 不可因「欄位為空」（資料來源本身不提供該欄位）而標記 REVIEW_NEEDED

---

## 七、目錄結構

### 7.1 完整結構

```
winV1/
├── CLAUDE.md                              # 執行入口（Claude CLI 自動載入）
├── README.md                              # 專案說明 + 健康度儀表板
├── .env                                   # 環境設定（不入版控）
├── .gitignore
│
├── core/
│   ├── CLAUDE.md                          # 系統維護指令（維護時載入）
│   ├── Architect/
│   │   └── CLAUDE.md                      # Architect 角色說明（由 Claude CLI 直接扮演）
│   ├── Extractor/
│   │   ├── CLAUDE.md                      # Extractor 角色說明 + 通用規則
│   │   └── Layers/
│   │       └── {layer_name}/
│   │           ├── CLAUDE.md              # Layer 定義 + 萃取邏輯 + 審核規則
│   │           ├── fetch.sh               # 資料擷取（輸出到 docs/Extractor/{layer_name}/raw/）
│   │           ├── update.sh              # Qdrant 更新 + REVIEW_NEEDED 檢查
│   │           └── .disabled              # 存在時跳過此 Layer
│   └── Narrator/
│       ├── CLAUDE.md                      # Narrator 角色說明
│       └── Modes/
│           └── {mode_name}/
│               ├── CLAUDE.md              # Mode 定義 + 輸出框架 + 審核規則
│               └── .disabled              # 存在時跳過此 Mode
│
├── lib/
│   ├── args.sh                            # 參數解析工具
│   ├── core.sh                            # 核心工具函式
│   ├── time.sh                            # 時間/日期工具
│   ├── rss.sh                             # RSS 擷取與解析（fetch.sh 的核心依賴）
│   ├── chatgpt.sh                         # OpenAI embedding 呼叫（Qdrant 寫入的核心依賴）
│   └── qdrant.sh                          # Qdrant 向量資料庫操作
│
├── docs/
│   ├── explored.md                        # 資料源探索紀錄
│   ├── prompt-v2.md                       # 本文件
│   ├── Extractor/
│   │   └── {layer_name}/
│   │       ├── raw/                       # 原始資料（.gitignore）
│   │       │   ├── rss-*.xml              # 下載的 RSS XML
│   │       │   ├── rss-*.jsonl            # 轉換後的 JSONL
│   │       │   └── .last_fetch            # 最後擷取時間戳
│   │       └── {category}/               # 萃取結果（.md 檔）
│   └── Narrator/
│       └── {mode_name}/
│           └── {報告檔名}.md              # 報告文件
│
└── .github/
    └── workflows/
        └── build-index.yml                # docs/ 下 .md 變動時自動重建 index.json
```

### 7.2 lib/ 說明

| 檔案 | 用途 | 主要依賴者 |
|------|------|------------|
| `args.sh` | 命令列參數解析 | 所有 shell 腳本 |
| `core.sh` | 通用工具函式（路徑、日誌等） | 所有 shell 腳本 |
| `time.sh` | 時間與日期計算 | fetch.sh、update.sh |
| `rss.sh` | RSS 下載（`rss_fetch`）、XML 轉 JSONL（`rss_extract_items_jsonl`） | fetch.sh |
| `chatgpt.sh` | OpenAI API 呼叫（text-embedding-3-small） | update.sh（透過 qdrant.sh） |
| `qdrant.sh` | Qdrant 向量資料庫 CRUD、去重（by source_url） | update.sh |

---

## 八、Layer 建立規範

### 8.1 Layer 定義表

新增 Layer 時必須確認以下每一欄：

| 項目 | 說明 |
|------|------|
| **Layer name** | 中英文名稱 |
| **Engineering function** | 這個 Layer 的工程職責 |
| **Collectable data** | 可收集的資料類型與來源 |
| **Automation level** | 自動化程度百分比 + 說明 |
| **Output value** | 產出的價值 |
| **Risk type** | 主要風險 |
| **Reviewer persona** | 從審核人設池中選擇 |
| **Category enum** | 固定分類清單（英文 key + 中文 + 判定條件） |
| **WebFetch 策略** | 必用 / 按需（含觸發條件） / 不使用 |

### 8.2 Layer CLAUDE.md 必備內容

每個 Layer 的 CLAUDE.md 必須包含：

1. **Layer 定義表**（見 8.1）
2. **執行指令** — 萃取邏輯與輸出格式
3. **分類規則（enum）** — 固定值清單 + 判定條件
   > **嚴格限制：category 只能使用定義的英文值，不可自行新增。** 需要新增 category 時必須與使用者確認後寫入 CLAUDE.md。
4. **WebFetch 補充規則** — 策略宣告 + 降級處理
5. **`[REVIEW_NEEDED]` 觸發規則** — 必須標記的場景 + 不觸發的場景
6. **輸出格式** — Markdown 模板
7. **自我審核 Checklist** — 輸出前必須逐項確認

### 8.3 fetch.sh 模板

```bash
#!/bin/bash
# {layer_name} 資料擷取腳本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/rss.sh"

LAYER_NAME="{layer_name}"
RAW_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME/raw"

mkdir -p "$RAW_DIR"

# === 資料擷取邏輯 ===
# 1. rss_fetch 下載 XML 到 $RAW_DIR/
# 2. rss_extract_items_jsonl 轉換為 JSONL

echo "Fetch completed: $LAYER_NAME"
```

### 8.4 update.sh 模板

```bash
#!/bin/bash
# {layer_name} 資料更新腳本
# 職責：Qdrant 更新 + REVIEW_NEEDED 檢查
# 注意：不處理 index.json（由 GitHub Actions 產生）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

source "$PROJECT_ROOT/lib/args.sh"
source "$PROJECT_ROOT/lib/core.sh"
source "$PROJECT_ROOT/lib/qdrant.sh"

LAYER_NAME="{layer_name}"
DOCS_DIR="$PROJECT_ROOT/docs/Extractor/$LAYER_NAME"

# 確保分類子目錄存在
for category in {category_enum_values}; do
  mkdir -p "$DOCS_DIR/$category"
done

# === Qdrant 更新（by source_url 去重）===
if [[ -n "${QDRANT_URL:-}" ]]; then
  qdrant_init_env || echo "Qdrant 連線失敗" >&2
fi

# === REVIEW_NEEDED 檢查 ===
REVIEW_FILES=""
for f in $(find "$DOCS_DIR" -name "*.md" -type f 2>/dev/null); do
  if grep -q "\[REVIEW_NEEDED\]" "$f" 2>/dev/null; then
    REVIEW_FILES+="  - $f\n"
  fi
done

if [[ -n "$REVIEW_FILES" ]]; then
  echo "需要審核：" && echo -e "$REVIEW_FILES"
  command -v gh >/dev/null 2>&1 && gh issue create \
    --title "[Extractor] $LAYER_NAME - 需要人工審核" \
    --label "review-needed" \
    --body "偵測到 [REVIEW_NEEDED] 標記" 2>/dev/null || true
fi

echo "Update completed: $LAYER_NAME"
```

---

## 九、Mode 建立規範

### 9.1 Mode 定義表

新增 Mode 時必須確認以下每一欄：

| 項目 | 說明 |
|------|------|
| **Mode name** | 中英文名稱 |
| **Purpose and audience** | 報告目的與目標受眾 |
| **Source layers** | 讀取哪些 Layer 的資料 |
| **Automation ratio** | 自動化比例 + 說明 |
| **Content risk** | 內容風險 |
| **Reviewer persona** | 從審核人設池中選擇 |

### 9.2 Mode CLAUDE.md 必備內容

每個 Mode 的 CLAUDE.md 必須包含：

1. **Mode 定義表**（見 9.1）
2. **資料來源定義** — 從 Qdrant / docs / 本次執行讀取的資料
3. **輸出框架** — 報告結構
4. **免責聲明** — 必須包含的法律與使用限制說明
5. **輸出位置** — 檔案路徑（通常為 `{YYYY}-W{WW}-{mode_name}.md`）
6. **自我審核 Checklist** — 發布前必須逐項確認

---

## 十、系統維護操作

### 10.1 Layer 管理

在 `core/` 目錄下操作，Claude CLI 會載入 `core/CLAUDE.md`。

#### 新增 Layer

使用者說：「新增一個 {名稱} Layer，資料來源是 {URL}，類型是 {RSS/API/...}」

執行流程：
1. 與使用者確認 Layer 定義表（見 8.1）
2. 確認 category enum 清單（嚴格限定，不可開放式）
3. 確認 WebFetch 策略
4. 確認 `[REVIEW_NEEDED]` 觸發規則
5. 建立目錄 `core/Extractor/Layers/{layer_name}/`
6. 產生 `fetch.sh`、`update.sh`、`CLAUDE.md`（依模板）
7. 建立 `docs/Extractor/{layer_name}/` 及 category 子目錄
8. 更新 `docs/explored.md`「已採用」表格
9. 告知使用者需要在 `.env` 補充的設定（若有）

#### 修改 Layer

1. 讀取 `core/Extractor/Layers/{layer_name}/CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 修改對應檔案
4. 若 category enum 有變動，確認不會影響既有 docs 分類
5. 列出影響範圍（哪些 Mode 會受影響）

#### 刪除 / 暫停 Layer

- 刪除前列出依賴此 Layer 的所有 Mode，警告影響範圍
- 暫停：在 Layer 目錄建立 `.disabled` 標記檔
- 執行流程會自動跳過帶有 `.disabled` 的 Layer

### 10.2 Mode 管理

與 Layer 管理邏輯類似，在 `core/Narrator/Modes/` 下操作。

### 10.3 資料源管理

使用者說：「我找到一個新的資料源 {URL}」

執行流程：
1. 測試連線（curl 確認可達）
2. 若為 RSS，驗證格式並顯示前 5 筆標題
3. 更新 `docs/explored.md`「評估中」表格
4. 詢問使用者要建立新 Layer 還是加入現有 Layer

### 10.4 docs/explored.md 格式

```markdown
## 已採用
| 資料源 | 類型 | 對應 Layer | 採用日期 | 備註 |

## 評估中
| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 下次評估 |

## 已排除
| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估時間 |
```

> **v1 修正**：「評估中」表格新增 URL 和語言欄位，便於批次評估。

---

## 十一、系統規範

### 11.1 審核人設池

| 審核人設 | 關注重點 |
|----------|----------|
| 資料可信度審核員 | 來源是否一手、是否可驗證 |
| 幻覺風險審核員 | AI 是否產生無中生有的內容 |
| 領域保守審核員 | 是否符合該領域的專業標準 |
| 邏輯一致性審核員 | 前後陳述是否矛盾 |
| 法規與責任審核員 | 是否有法律風險 |
| 使用者誤導風險審核員 | 是否可能造成誤解 |
| 自動化邊界審核員 | 是否超出適合自動化的範圍 |

### 11.2 Qdrant 設定

- Collection 和 向量維度設定在 .env
- 距離：Cosine
- Payload 必要欄位：`source_url`、`fetched_at`、`original_content`、`source_layer`、`title`、`date`、`category`、`severity`
- 去重機制：以 `source_url` 為主鍵，避免重複寫入

### 11.3 禁止行為

1. 不可產出無法驗證的「專業外觀」聲明 — 所有聲明必須有來源
2. 不可跳過審核層 — 每個輸出必須經過自我審核 checklist
3. 不可混淆推測與事實 — 推測必須明確標註
4. 不可將高風險領域標記為全自動 — 涉及法律、財務建議等必須有人工介入
5. 不可自行新增 category enum 值 — 必須與使用者確認後寫入 CLAUDE.md
6. 不可使用 Read 工具直接讀取 `.jsonl` 檔案 — 一律透過 `sed -n '{N}p'` 逐行讀取
7. 不可自行擴大 `[REVIEW_NEEDED]` 判定範圍 — 嚴格遵循各 Layer CLAUDE.md 的觸發規則

### 11.4 GitHub Actions

僅保留一個 workflow：
- `build-index.yml`：docs/ 下的 .md 變動時自動重建 `index.json`
- `index.json` 不由 update.sh 或萃取流程產生

> **v1 修正**：移除了 `explore-source.yml`、`patrol.yml`、`update-health.yml` 的規範。這些功能由 Claude CLI 手動執行即可。

---

## 十二、環境設定

執行前需確認 `.env` 包含以下設定：

```
QDRANT_URL=...
QDRANT_API_KEY=...
QDRANT_COLLECTION=...
EMBEDDING_MODEL=...
EMBEDDING_DIMENSION=...
OPENAI_API_KEY=sk-...
```

---

## 十三、輸出規則

- Layer 萃取的 `.md` 檔必須遵循該 Layer CLAUDE.md 定義的格式
- Mode 報告的 `.md` 檔必須遵循該 Mode CLAUDE.md 定義的框架
- 所有輸出必須通過各自的「自我審核 Checklist」
- 未通過審核的輸出必須在開頭加上 `[REVIEW_NEEDED]`
- `index.json` 由 GitHub Actions 自動產生，不在此流程中處理

---

## 十四、互動規則

完成執行後，簡要回報：

1. 各 Layer 擷取與萃取結果（筆數、有無 REVIEW_NEEDED）
2. 各 Mode 報告產出狀態
3. 是否有錯誤或需要人工介入的項目

> **v1 修正**：移除了「這是用於內容引擎、業務系統、還是內部工具？」等通用模板問題。本系統專為資安情報分析設計，每次執行不需重新詢問用途。

---

## 十五、健康度儀表板

README.md 中的系統健康度表格由頂層 Claude CLI 在「執行完整流程」後更新：

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| {Layer 名稱} | {YYYY-MM-DD} | {N} | {✅/⚠️/❌} |

| Mode | 最後產出 | 狀態 |
|------|----------|------|
| {Mode 名稱} | {YYYY-MM-DD} | {✅/⚠️/❌} |

健康度判定規則：
- ✅ 正常：最後更新在預期週期內
- ⚠️ 需關注：超過預期週期但未超過 2 倍
- ❌ 異常：超過預期週期 2 倍以上

---

## 十六、已知問題與解決方案

> **更新日期**：2026-02-03
> 本節記錄各 Layer 的技術債與已知問題，避免重複踩坑。

### 16.1 資料源類型與策略

| 資料源類型 | 適用策略 | 範例 Layer | 注意事項 |
|------------|----------|------------|----------|
| **官方 Open API** | 直接呼叫，高可靠性 | tw_govjobs | 優先選擇，自動化程度最高 |
| **非官方內部 API** | 需模擬瀏覽器，可能被封鎖 | tw_104_jobs | 需 User-Agent、Referer，有 IP 封鎖風險 |
| **CDN 封鎖網站** | 手動下載 + 自動萃取 | global_wef_jobs | 無法自動化下載，需人工介入 |
| **需登入/積分交換** | 暫停或排除 | tw_company_reviews | 技術與法律風險過高 |

### 16.2 台灣就業市場資料源

#### tw_govjobs（台灣就業通）✅ 推薦

**API 端點**：
```
https://free.taiwanjobs.gov.tw/webservice_taipei/Webservice.ashx?count=1000
```

**API 文件**：https://free.taiwanjobs.gov.tw/webservice_taipei/A17000000J-030144-Taiwanjobs-OpenData.pdf

**參數**：
| 參數 | 說明 |
|------|------|
| `count` | 回傳筆數（最多 1000） |
| `zipno` | 郵遞區號（3 碼，可選） |
| `jobno` | 通俗職業代碼（可選） |

**回傳格式**：XML（需用 xmllint 解析）
```xml
<DataList>
  <Data>
    <OCCU_DESC>職缺名稱</OCCU_DESC>
    <CJOB_NAME1>職業分類</CJOB_NAME1>
    <JOB_DETAIL>工作內容</JOB_DETAIL>
    ...
  </Data>
</DataList>
```

**優點**：政府官方 Open API，穩定可靠，無需 WebFetch

#### tw_104_jobs（104人力銀行）⚠️ 風險中等

**現況**：使用 104 網站內部 API（非官方公開）

**風險**：
- IP 可能被暫時封鎖
- API 結構可能隨時變動
- 需模擬瀏覽器 Headers

**替代方案**：
1. 申請 104 官方開發者 API：https://developers.104.com.tw/
2. 改用 tw_govjobs 作為部分替代

**測試指令**：
```bash
./fetch.sh --test  # 僅擷取 1 個角色，測試 API 連線
```

#### tw_company_reviews（求職天眼通）❌ 已停用

**停用原因**：
- 求職天眼通（Qollie）公司已於 2017 年解散
- 需登入 + 積分交換機制
- 評論主觀性高，法律風險大

**狀態**：已建立 `.disabled` 標記

### 16.3 全球就業趨勢資料源

#### global_wef_jobs（WEF 未來就業報告）⚠️ 需手動下載

**問題**：WEF 網站使用 Akamai CDN 全面封鎖自動化存取（HTTP 403）

**解決方案**：手動下載 PDF + Claude 自動萃取

**操作流程**：
1. 手動下載 PDF 到 `docs/Extractor/global_wef_jobs/raw/`
2. 命名規則：`WEF_Future_of_Jobs_Report_2025.pdf`
3. 執行 fetch.sh（會偵測已下載的 PDF 並產生 JSONL）
4. 萃取流程使用 Claude Read tool 讀取 PDF

**已知報告**：
| 檔名 | 報告 | 下載頁面 |
|------|------|----------|
| `WEF_Future_of_Jobs_Report_2025.pdf` | Future of Jobs Report 2025 | https://www.weforum.org/publications/the-future-of-jobs-report-2025/ |
| `WEF_Future_of_Jobs_Report_2023.pdf` | Future of Jobs Report 2023 | https://www.weforum.org/publications/the-future-of-jobs-report-2023/ |

### 16.4 常見失敗模式與修復

| 失敗模式 | 症狀 | 診斷方式 | 修復策略 |
|----------|------|----------|----------|
| **API 結構變動** | HTTP 200 但解析失敗 | 檢查原始回應格式 | 更新 XML/JSON 解析路徑 |
| **IP 封鎖** | HTTP 403/429 | 換 IP 或等待後重試 | 增加請求間隔、申請官方 API |
| **CDN 封鎖** | HTTP 403 + Akamai 錯誤頁 | 瀏覽器可訪問但 curl 失敗 | 改為手動下載模式 |
| **網站停運** | DNS 無法解析或 HTTP 5xx | 確認網站狀態 | 建立 `.disabled` 標記 |
| **jq 路徑錯誤** | jq 輸出空值 | 檢查 JSON 結構 | 修正 jq 選擇器路徑 |

### 16.5 roles.json 結構

`core/Extractor/Layers/tw_104_jobs/roles.json` 是共用的職業角色定義，其他 Layer 可引用：

```json
[
  {
    "id": 1,
    "search_term": "軟體工程師",
    "key": "software_engineer",
    "sector": "tech",
    "ai_displacement_vector": "cognitive_nonroutine"
  },
  ...
]
```

**正確的 jq 路徑**：
```bash
# ✅ 正確：roles.json 是陣列，直接用 .[]
jq -r '.[].search_term' roles.json

# ❌ 錯誤：不存在 .categories 結構
jq -r '.categories[].roles[]' roles.json
```

### 16.6 Layer 修復 SOP

當 Layer 的 fetch.sh 失敗時：

1. **診斷**
   ```bash
   # 測試 API 連線
   curl -v "API_URL" | head -100

   # 檢查 HTTP 狀態碼
   curl -s -o /dev/null -w "%{http_code}" "API_URL"
   ```

2. **判斷失敗類型**（見 16.4 表格）

3. **選擇修復策略**
   - API 可修復 → 更新 fetch.sh
   - 需手動介入 → 改為 PDF/手動模式
   - 無法修復 → 建立 `.disabled` 並記錄原因

4. **更新文件**
   - 修改 Layer 的 CLAUDE.md（WebFetch 策略、自動化程度）
   - 更新本節（十六）的已知問題

---

## 十七、任務完成品質關卡

> **用途**：每次「執行完整流程」結束前，必須通過以下檢查才能視為成功。

### 17.1 強制檢查清單

**回報「完成」之前，必須逐項確認以下檢查全部通過。**

#### 1. 連結檢查

- [ ] 所有新增/修改的內部連結正常（報告間交叉引用）
- [ ] 所有新增/修改的外部連結正常（資料來源連結）
- [ ] 無死連結或斷裂連結

#### 2. Jekyll Front Matter 檢查（本專案適用）

本專案透過 Jekyll 發布 GitHub Pages，報告需包含正確的 front matter：

| 欄位 | 要求 |
|------|------|
| `title` | 存在且清楚描述報告內容 |
| `description` | 存在且 ≤ 155 字 |
| `nav_order` | 存在且正確（10000 - 週次） |
| `parent` | 存在且對應正確的 Mode |
| `last_modified_date` | 存在且為 ISO 8601 格式 |

#### 3. 報告內容品質檢查

- [ ] 報告標註「本報告使用 Qdrant 向量搜尋取得相關資料」
- [ ] 所有數據聲明都有資料來源標註
- [ ] 免責聲明存在（依各 Mode CLAUDE.md 定義）
- [ ] 無「推測」與「事實」混淆（推測需明確標註）
- [ ] 無 `[REVIEW_NEEDED]` 未處理項目（或已記錄待人工審核）

#### 4. 內容更新確認

- [ ] 列出本次預計修改的所有檔案
- [ ] 逐一確認每個檔案都已正確更新
- [ ] 首頁 index.md 的所有週次引用都已更新（按鈕、表格、日期）
- [ ] 各 Mode 索引頁的 `redirect_to` 已更新
- [ ] 無遺漏項目

#### 5. Git 狀態檢查

- [ ] 所有變更已 commit
- [ ] commit message 清楚描述本次變更（格式：`更新報告: {YYYY}-W{WW}`）
- [ ] 已 push 到 GitHub（除非另有指示）
- [ ] 遠端分支已更新

#### 6. SOP 完成度檢查

- [ ] 回顧原始任務需求
- [ ] 執行流程每個步驟都已執行（Layer fetch → 萃取 → update → Mode 報告）
- [ ] 無遺漏的待辦項目
- [ ] 無「之後再處理」的項目

### 17.2 檢查報告格式

完成檢查後，輸出以下格式：

```
## 完成檢查報告

| 類別 | 狀態 | 問題（如有） |
|------|------|-------------|
| 連結檢查 | ✅/❌ | |
| Jekyll Front Matter | ✅/❌ | |
| 報告內容品質 | ✅/❌ | |
| 內容更新 | ✅/❌ | |
| Git 狀態 | ✅/❌ | |
| SOP 完成度 | ✅/❌ | |

**總結**：X/6 項通過，狀態：通過/未通過
```

### 17.3 檢查未通過時

1. **不回報完成**
2. 列出所有未通過項目
3. 立即修正問題
4. 重新執行檢查
5. 全部通過才能說「完成」

### 17.4 條件式檢查（依內容判斷）

| 內容類型 | 適用檢查 |
|----------|----------|
| 有步驟教學 | 步驟編號連續、有明確行動指引 |
| 有資料表格 | 表格格式正確、數據來源標註 |
| 有圖表/視覺化 | 圖表說明文字存在 |
| 涉及薪資/職涯建議 | 免責聲明存在、標註資料時效性 |

### 17.5 E-E-A-T 信號（就業分析報告適用）

- [ ] 資料來源為一手來源（官方 API、政府公開資料）
- [ ] 至少標註 2 個高權威外部來源（政府、學術機構、專業協會）
- [ ] 報告更新日期清楚標註
- [ ] 方法論透明（說明資料收集與分析方式）

---

## 十八、變更紀錄

| 日期 | 版本 | 變更內容 |
|------|------|----------|
| 2026-02-18 | v2.2 | 新增「十七、任務完成品質關卡」，整合任務完成前的強制檢查清單 |
| 2026-02-03 | v2.1 | 新增「十六、已知問題與解決方案」，記錄 tw_govjobs/tw_104_jobs/global_wef_jobs/tw_company_reviews 的技術債與修復方案 |
| - | v2.0 | 初始版本 |

---

End of CLAUDE.md
