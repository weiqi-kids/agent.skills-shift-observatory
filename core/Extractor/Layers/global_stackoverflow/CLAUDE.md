# global_stackoverflow Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_stackoverflow / Stack Overflow 開發者調查 |
| **Engineering function** | 擷取 Stack Overflow 年度開發者調查的公開數據集與分析報告 |
| **Collectable data** | 程式語言/框架使用率、開發者薪資分布、工作滿意度、學習路徑、遠端工作偏好 |
| **Data source** | Stack Overflow Annual Developer Survey (https://survey.stackoverflow.co/), public dataset download |
| **Automation level** | 75% — 公開資料集為 CSV，需轉換；報告頁面需 WebFetch |
| **Output value** | 全球開發者社群的技術偏好與薪資基準 |
| **Risk type** | 調查偏差（Stack Overflow 用戶偏向英語圈、男性、Web 開發） |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

從 Stack Overflow Developer Survey 擷取的 JSONL 資料進行萃取，每一行為一筆調查結果摘要或報告章節。

### 萃取邏輯

1. 解析 JSON 欄位：`survey_year`、`question`、`response`、`percentage`、`sample_size`、`link`
2. **按需使用 WebFetch 工具**（當 response 資訊不足時）抓取報告摘要頁面
3. 依照 category enum 分類
4. 產生結構化 Markdown 輸出
5. 若 CSV 解析產生非預期欄位或年份不明，標記 `[REVIEW_NEEDED]`

## 分類規則（Category Enum）

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `language_framework` | 語言與框架 | question 涉及程式語言、框架、函式庫使用率 |
| `salary_survey` | 薪資調查 | question 涉及開發者薪資、薪酬分布 |
| `work_satisfaction` | 工作滿意度 | question 涉及工作滿意度、職場文化、工作生活平衡 |
| `learning_path` | 學習路徑 | question 涉及學習方式、教育背景、技能習得管道 |
| `developer_profile` | 開發者輪廓 | question 涉及開發者人口統計、經驗年資、角色類型 |

**嚴格限制：category 只能使用上述英文值,不可自行新增。** 需要新增 category 時必須與使用者確認後寫入本檔案。

## WebFetch 補充規則

### 策略：按需

CSV 資料集已包含完整統計數據，但報告摘要頁面提供更多情境說明。

### 觸發條件

1. JSONL 中 response 欄位為空或過短（少於 50 字）
2. 需要理解問題情境（如「Other」選項的具體內容）
3. 需要補充樣本數說明或統計方法

### WebFetch 執行

1. 使用 WebFetch 工具，`url` 為 JSONL 中的 `link` 欄位
2. `prompt` 應包含：
   - 「萃取該問題的背景說明與統計方法」
   - 「識別樣本數與受訪者特徵」
   - 「萃取圖表標題與說明」

### 降級處理

若 WebFetch 失敗（網頁無法訪問、超時等）：
1. 降級為僅基於 JSONL 的 CSV 欄位萃取
2. 在 notes 欄位標註：「WebFetch 失敗，僅基於 CSV 資料萃取」
3. **不需標記 `[REVIEW_NEEDED]`**（CSV 資料本身完整）

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的場景

1. **CSV 欄位異常** — CSV 解析產生的欄位與預期不符（如缺少 survey_year 或 response 欄位）
2. **年份不明** — 無法確認調查是哪一年的版本
3. **百分比異常** — percentage 欄位總和不為 100%（多選題除外）或超過 100%

### 不觸發的場景

- ❌ **調查偏差** — Stack Overflow 用戶偏差為結構性限制，應在 confidence 欄位反映，不標記 REVIEW_NEEDED
- ❌ **WebFetch 失敗** — CSV 資料本身完整，WebFetch 僅為補充，失敗不影響萃取品質
- ❌ **特定選項樣本數過小** — 調查本身的統計限制，非萃取問題

## 輸出格式

```markdown
---
source_layer: global_stackoverflow
category: {category_enum_value}
survey_year: {YYYY}
question: {調查問題原文}
sample_size: {受訪者數量}
fetched_at: {YYYY-MM-DD HH:MM:SS}
source_url: {Stack Overflow Survey 頁面 URL}
webfetch_used: true/false
confidence: {高/中/低}
---

# {調查問題標題} — Stack Overflow {survey_year}

## 問題描述

{調查問題的完整陳述與選項說明}

## 調查結果

{列表呈現各選項的百分比與排名}

例如：
1. JavaScript — 65.36%
2. Python — 48.07%
3. TypeScript — 34.83%
4. Java — 33.27%
5. C# — 27.98%

（基於 {sample_size} 位受訪者，多選題）

## 趨勢分析

{如有多年資料，比較與前一年的變化}

## 受訪者特徵

- **總樣本數**：{sample_size}
- **主要地區**：{如報告有提及}
- **經驗分布**：{如報告有提及}

## 資料來源

- **調查**：Stack Overflow Annual Developer Survey {survey_year}
- **發布機構**：Stack Overflow
- **資料集**：Public CSV download
- **擷取時間**：{fetched_at}
- **WebFetch 狀態**：{成功/未使用/失敗降級}

## 備註

{如有調查偏差說明、統計限制等，在此補充}

**注意**：Stack Overflow 調查樣本偏向英語圈、男性、Web 開發者，結果可能不代表全球開發者整體。
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] category 為定義的 5 個 enum 值之一
- [ ] survey_year 為有效年份（2011-2100，Stack Overflow 調查始於 2011）
- [ ] sample_size 為有效數值
- [ ] 百分比數據與原始 CSV 一致（允許四捨五入誤差）
- [ ] 多選題已標註「多選題」
- [ ] confidence 評估合理（考量調查偏差，通常為「中」）
- [ ] 已在備註說明調查偏差（Stack Overflow 用戶特徵）
- [ ] 若 CSV 欄位異常或年份不明，已標記 `[REVIEW_NEEDED]`
- [ ] 未因調查偏差或 WebFetch 失敗而誤標 `[REVIEW_NEEDED]`
