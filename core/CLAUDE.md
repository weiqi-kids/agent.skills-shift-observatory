# 系統維護指令

## 本文件用途

當在 `core/` 目錄下進行維護操作時，Claude CLI 會自動載入本文件。本文件定義系統維護相關的操作指令與規範。

## 系統概述

本系統為**技能需求變化觀測站**（Skills Shift Observatory），用於觀測全球就業市場變化、AI 對 14 個產業中 53 個職業角色的取代影響。

### 系統架構

- **14 個 Layers**：3 個台灣微觀資料源 + 9 個全球宏觀資料源 + 2 個事件追蹤資料源
- **5 個 Narrator Modes**：景氣溫度計、技能需求漂移、產業分層分析、薪資帶分析、求職策略建議
- **53 個觀測職業角色**：橫跨 5 個 AI 取代向量（認知例行、認知非例行、體力例行、體力非例行、人際互動）

完整系統規格請參閱根目錄的 `CLAUDE.md`。

---

## Layer 管理

### 新增 Layer

使用者說：「新增一個 {名稱} Layer，資料來源是 {URL}，類型是 {RSS/API/...}」

#### 執行流程

1. **確認 Layer 定義表**（與使用者互動確認以下項目）：
   - Layer name（中英文名稱）
   - Engineering function（工程職責）
   - Collectable data（可收集的資料類型與來源）
   - Automation level（自動化程度百分比 + 說明）
   - Output value（產出的價值）
   - Risk type（主要風險）
   - Reviewer persona（從審核人設池中選擇）
   - **Category enum**（固定分類清單，英文 key + 中文 + 判定條件）
   - **WebFetch 策略**（必用 / 按需（含觸發條件） / 不使用）

2. **確認 `[REVIEW_NEEDED]` 觸發規則**：
   - 必須明確定義哪些情況**必須**標記
   - 必須明確定義哪些情況**不觸發**（避免子任務自行擴大範圍）
   - 原則：僅當萃取結果**可能有誤**時標記，資料來源的結構性限制應在 `confidence` 欄位反映

3. **建立 Layer 目錄結構**：
   ```
   core/Extractor/Layers/{layer_name}/
   ├── CLAUDE.md          # Layer 定義 + 萃取邏輯 + 審核規則
   ├── fetch.sh           # 資料擷取腳本
   └── update.sh          # Qdrant 更新 + REVIEW_NEEDED 檢查
   ```

4. **產生檔案內容**（依據根目錄 CLAUDE.md 的模板）：
   - `CLAUDE.md`：必須包含 Layer 定義表、執行指令、分類規則（enum）、WebFetch 補充規則、`[REVIEW_NEEDED]` 觸發規則、輸出格式、自我審核 Checklist
   - `fetch.sh`：使用 `lib/rss.sh` 下載原始資料到 `docs/Extractor/{layer_name}/raw/`
   - `update.sh`：使用 `lib/qdrant.sh` 寫入向量資料庫、檢查 `[REVIEW_NEEDED]`

5. **建立文件目錄結構**：
   ```
   docs/Extractor/{layer_name}/
   ├── raw/                      # 原始資料（.gitignore）
   └── {category_1}/             # 按 category enum 建立子目錄
   └── {category_2}/
   └── ...
   ```

6. **更新 `docs/explored.md`**：
   - 在「已採用」表格新增此資料源

7. **告知使用者**：
   - 若需要 API key 或其他環境變數，提醒在 `.env` 補充

#### 嚴格限制

- **Category enum 必須固定值**：不可開放式分類，必須列舉所有可能值
- **新增 category 需使用者確認**：子任務不可自行新增 category 值

### 修改 Layer

1. 讀取 `core/Extractor/Layers/{layer_name}/CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 修改對應檔案
4. 若 category enum 有變動，確認不會影響既有 `docs/Extractor/{layer_name}/` 下的 .md 檔分類
5. 列出影響範圍：哪些 Mode 會受此 Layer 修改影響

### 刪除 / 暫停 Layer

- **刪除前警告**：列出所有依賴此 Layer 的 Mode，說明影響範圍
- **暫停方式**：在 Layer 目錄建立 `.disabled` 標記檔，執行流程會自動跳過
- **刪除方式**：移除整個 Layer 目錄，並更新 `docs/explored.md`

---

## Mode 管理

### 新增 Mode

使用者說：「新增一個 {名稱} Mode，用於 {報告目的}」

#### 執行流程

1. **確認 Mode 定義表**（與使用者互動確認以下項目）：
   - Mode name（中英文名稱）
   - Purpose and audience（報告目的與目標受眾）
   - Source layers（讀取哪些 Layer 的資料）
   - Automation ratio（自動化比例 + 說明）
   - Content risk（內容風險）
   - Reviewer persona（從審核人設池中選擇）

2. **建立 Mode 目錄結構**：
   ```
   core/Narrator/Modes/{mode_name}/
   └── CLAUDE.md          # Mode 定義 + 輸出框架 + 審核規則
   ```

3. **產生 `CLAUDE.md`**（必須包含）：
   - Mode 定義表
   - 資料來源定義（從 Qdrant / docs / 本次執行讀取的資料）
   - 輸出框架（報告結構）
   - 免責聲明（若涉及職涯建議、財務影響等）
   - 輸出位置（檔案路徑規則，通常為 `{YYYY}-W{WW}-{mode_name}.md`）
   - 自我審核 Checklist

4. **建立文件目錄**：
   ```
   docs/Narrator/{mode_name}/
   ```

5. **告知使用者**：
   - 此 Mode 依賴哪些 Layer
   - 建議執行頻率

### 修改 Mode

1. 讀取 `core/Narrator/Modes/{mode_name}/CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 修改對應檔案
4. 若修改了資料來源（Source layers），確認 Layer 是否存在且已啟用

### 刪除 / 暫停 Mode

- **暫停方式**：在 Mode 目錄建立 `.disabled` 標記檔，執行流程會自動跳過
- **刪除方式**：移除整個 Mode 目錄

---

## 資料源管理

### 新增資料源

使用者說：「我找到一個新的資料源 {URL}」

#### 執行流程

1. **測試連線**：
   ```bash
   curl -I {URL}
   ```
   確認可達，檢查 HTTP 狀態碼

2. **若為 RSS，驗證格式**：
   ```bash
   curl {URL} | xmllint --format -
   ```
   顯示前 5 筆標題，確認資料品質

3. **更新 `docs/explored.md`**：
   - 在「評估中」表格新增此資料源
   - 欄位：資料源、類型、URL、語言、發現日期、狀態、下次評估

4. **詢問使用者**：
   - 要建立新 Layer 還是加入現有 Layer？

### docs/explored.md 格式

```markdown
## 已採用

| 資料源 | 類型 | 對應 Layer | 採用日期 | 備註 |
|--------|------|------------|----------|------|

## 評估中

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 下次評估 |
|--------|------|-----|------|----------|------|----------|

## 已排除

| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估時間 |
|--------|------|----------|----------|--------------|
```

---

## 系統巡檢

使用者說：「系統巡檢」或「health check」

執行流程：

1. 掃描所有啟用的 Layer（排除含 `.disabled` 的目錄）
2. 檢查每個 Layer 的最後擷取時間（`docs/Extractor/{layer_name}/raw/.last_fetch`）
3. 掃描所有啟用的 Mode（排除含 `.disabled` 的目錄）
4. 檢查每個 Mode 的最後產出時間（`docs/Narrator/{mode_name}/` 下最新的 .md 檔）
5. 更新 `README.md` 中的健康度儀表板

### 健康度判定規則

- ✅ 正常：最後更新在預期週期內
- ⚠️ 需關注：超過預期週期但未超過 2 倍
- ❌ 異常：超過預期週期 2 倍以上

---

## 審核人設池

在建立或修改 Layer/Mode 時，從以下人設中選擇合適的審核角色：

| 審核人設 | 關注重點 |
|----------|----------|
| 資料可信度審核員 | 來源是否一手、是否可驗證 |
| 幻覺風險審核員 | AI 是否產生無中生有的內容 |
| 領域保守審核員 | 是否符合該領域的專業標準 |
| 邏輯一致性審核員 | 前後陳述是否矛盾 |
| 法規與責任審核員 | 是否有法律風險 |
| 使用者誤導風險審核員 | 是否可能造成誤解 |
| 自動化邊界審核員 | 是否超出適合自動化的範圍 |

---

## 禁止行為

維護操作時必須遵守以下限制：

1. **不可自行新增 category enum 值** — 必須與使用者確認後寫入 CLAUDE.md
2. **不可跳過 Layer/Mode 定義表確認** — 每次新增必須完整填寫
3. **不可省略 `[REVIEW_NEEDED]` 觸發規則定義** — 必須明確列出必須標記與不觸發的場景
4. **不可產生開放式分類** — 所有 category 必須是固定值清單
5. **不可將高風險領域標記為全自動** — 涉及職涯建議、法律、財務等必須有人工介入

---

## 參考文件

- 完整系統規格：根目錄 `CLAUDE.md`
- Architect 角色說明：`core/Architect/CLAUDE.md`
- Extractor 通用規則：`core/Extractor/CLAUDE.md`
- Narrator 角色說明：`core/Narrator/CLAUDE.md`
