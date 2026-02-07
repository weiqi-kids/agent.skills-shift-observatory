# global_indeed_hiring Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_indeed_hiring / Indeed Hiring Lab 報告 |
| **Engineering function** | 擷取 Indeed Hiring Lab 公開的就業市場研究報告與數據集 |
| **Collectable data** | 職缺刊登趨勢、薪資趨勢、求職者行為、產業招聘動態 |
| **Data source** | Indeed Hiring Lab (https://www.hiringlab.org/) - RSS feed and public reports |
| **Automation level** | 80% — RSS feed available, structured data in some reports |
| **Output value** | 多國就業市場量化趨勢數據 |
| **Risk type** | Indeed market coverage varies by country |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

從 raw/ 目錄中的 JSONL 檔案讀取 Indeed Hiring Lab 報告條目，對每個條目：

1. 優先使用 RSS 的 `description` 欄位
2. 若 `description` 內容不足（少於 100 字或缺少關鍵數據），使用 WebFetch 抓取完整頁面
3. 萃取以下關鍵資訊：
   - 報告標題與發布日期
   - 報告涵蓋的時間區間（report_period）
   - 地理範圍（geographic_scope）
   - 核心指標與數據（job posting trends, salary trends, job seeker behavior）
   - 關鍵發現（key findings）
4. 判定分類（category）
5. 產出 Markdown 檔案到對應 category 子目錄

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下英文值，不可自行新增。**

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `job_posting_trend` | 職缺刊登趨勢 | 報告主題為職缺數量、增長率、刊登速度等趨勢 |
| `salary_trend` | 薪資趨勢 | 報告提供薪資水準、薪資增長、薪資分布數據 |
| `job_seeker_behavior` | 求職者行為 | 報告分析求職者搜尋行為、應徵模式、偏好變化 |
| `industry_hiring` | 產業招聘 | 報告聚焦特定產業的招聘動態 |
| `labor_market_overview` | 勞動市場概覽 | 報告提供跨產業、跨地區的整體勞動市場分析 |

若報告主題無法明確對應上述分類，預設使用 `labor_market_overview`。

## WebFetch 補充規則

### 策略：按需

Indeed Hiring Lab 的 RSS feed 通常包含報告摘要，但詳細數據與圖表需從原始頁面取得。

### 觸發條件

以下情況**需要**使用 WebFetch：
1. RSS `description` 欄位少於 100 字
2. `description` 中未包含量化數據（例如百分比、增長率）
3. 報告標題提及特定指標（如「薪資趨勢」）但 `description` 無相關數據

### WebFetch prompt 範例

```
請從以下 Indeed Hiring Lab 報告頁面中萃取：
1. 報告標題與發布日期
2. 報告涵蓋的時間區間（例如：2024年12月, 2024 Q4）
3. 地理範圍（全球 / 美國 / 加拿大 / 歐洲等）
4. 報告的核心數據與指標（職缺刊登趨勢、薪資數據、求職者行為等）
5. 關鍵發現（key findings）列表
6. 如有圖表，請描述圖表內容與趨勢

請以結構化格式回傳。
```

### 降級處理

若 WebFetch 失敗，則：
- 僅基於 RSS 的 `title` 和 `description` 欄位產出 Markdown
- 在 `notes` 欄位標註：「WebFetch 失敗，僅基於 RSS 摘要萃取」
- **不觸發** `[REVIEW_NEEDED]`（RSS 本身已有基本資訊）

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`

1. **萃取指標與報告標題嚴重矛盾** — 例如標題為「薪資趨勢上升」，但內容顯示薪資下降
2. **無法判定報告時間區間且無法從 pubDate 推斷** — `report_period` 和 `date` 欄位皆無法填寫
3. **數據單位不明** — 例如報告提及「增長 15」但未說明單位（百分比？千人？）

### 以下情況**不觸發** `[REVIEW_NEEDED]`

- ❌ **Indeed 市場涵蓋範圍限制** — 這是結構性限制，應在 `confidence` 欄位反映（例如 confidence: 中）
- ❌ **報告未涵蓋特定國家或產業** — 這是報告本身的範圍限制，不是萃取錯誤
- ❌ **WebFetch 失敗但 RSS 有基本資訊** — 降級處理即可，不需標記
- ❌ **缺少薪資數據但報告主題非薪資** — 若報告本身未提供該欄位資訊，不標記 REVIEW_NEEDED

## 輸出格式

### Markdown 模板

```markdown
---
title: "{報告標題}"
source_url: "{原始報告 URL}"
source_layer: "global_indeed_hiring"
category: "{category enum value}"
date: "{報告發布日期 YYYY-MM-DD}"
fetched_at: "{擷取時間戳 ISO 8601}"
report_period: "{報告涵蓋時間區間，例如 2024-12 或 2024-Q4}"
geographic_scope: "{地理範圍，例如：全球 / 美國 / 加拿大}"
confidence: "{高/中/低}"
severity: "info"
---

# {報告標題}

## 關鍵發現

{列出報告的主要發現，每項一段}

## 核心數據

{萃取的量化指標，例如：
- 職缺刊登量：較去年同期增長 XX%
- 平均薪資：$XXX,XXX（年薪）
- 求職者搜尋關鍵字 Top 5：...
}

## 趨勢分析

{報告中的趨勢描述與解讀}

## 來源資訊

- 發布單位：Indeed Hiring Lab
- 報告涵蓋期間：{report_period}
- 地理範圍：{geographic_scope}

## 備註

{notes}
```

### 檔案命名規則

`{YYYY-MM-DD}_{sanitized_title}.md`

例如：`2024-12-10_us-job-posting-trends-december.md`

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] 報告標題與 `source_url` 正確對應
- [ ] `category` 值為預定義的 enum 值之一
- [ ] `report_period` 和 `geographic_scope` 已填寫（若報告有提供）
- [ ] 關鍵發現來自報告內容，非 AI 推測
- [ ] 核心數據有明確單位（百分比、金額、人數等）
- [ ] `confidence` 欄位反映資料來源的結構性限制（Indeed 市場涵蓋範圍 → 中）
- [ ] 若萃取指標與標題嚴重矛盾，已觸發 `[REVIEW_NEEDED]`
- [ ] 若無法判定時間區間且無 pubDate，已觸發 `[REVIEW_NEEDED]`
- [ ] 檔案名稱符合命名規則
- [ ] Markdown 格式正確（YAML frontmatter + 內容區塊）
