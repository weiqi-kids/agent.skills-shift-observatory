# global_linkedin_workforce Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_linkedin_workforce / LinkedIn 全球勞動力報告 |
| **Engineering function** | 擷取 LinkedIn Economic Graph 與 Workforce Reports 公開發布的就業市場分析報告 |
| **Collectable data** | 全球人才流動趨勢、產業招聘指數、熱門技能排名、遠端工作趨勢 |
| **Data source** | LinkedIn Economic Graph public reports, LinkedIn blog workforce insights |
| **Automation level** | 50% — 報告為非結構化文本，需 AI 萃取關鍵指標 |
| **Output value** | 全球就業市場宏觀趨勢，跨國人才流動數據 |
| **Risk type** | 資料偏差（僅 LinkedIn 用戶群體）、報告發布不定期 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

從 raw/ 目錄中的 JSONL 檔案讀取 LinkedIn 報告條目，對每個條目：

1. 使用 WebFetch 抓取報告頁面完整內容
2. 萃取以下關鍵資訊：
   - 報告標題與發布日期
   - 報告涵蓋的時間區間（report_period）
   - 地理範圍（geographic_scope）
   - 核心指標與數據（talent flow, hiring trends, skills, remote work）
   - 關鍵發現（key findings）
3. 判定分類（category）
4. 產出 Markdown 檔案到對應 category 子目錄

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下英文值，不可自行新增。**

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `talent_flow` | 人才流動 | 報告主題為跨國、跨城市、跨產業的人才遷移趨勢 |
| `hiring_index` | 招聘指數 | 報告提供招聘活動量化指標（如招聘速度、職缺增長率） |
| `skills_ranking` | 技能排名 | 報告列出熱門技能、需求技能排行榜 |
| `remote_work` | 遠端工作 | 報告聚焦遠端工作趨勢、混合辦公模式 |
| `industry_trend` | 產業趨勢 | 報告分析特定產業的就業市場變化 |

若報告主題無法明確對應上述分類，預設使用 `industry_trend`。

## WebFetch 補充規則

### 策略：必用

LinkedIn 報告頁面為主要資料來源，RSS 或 API 回應通常僅包含標題與摘要。**必須**使用 WebFetch 抓取報告頁面完整內容。

### WebFetch prompt 範例

```
請從以下 LinkedIn 報告頁面中萃取：
1. 報告標題與發布日期
2. 報告涵蓋的時間區間（例如：2024 Q4, 2024年度）
3. 地理範圍（全球 / 特定國家或地區）
4. 報告的核心數據與指標（人才流動、招聘指數、技能排名等）
5. 關鍵發現（key findings）列表
6. 如有圖表，請描述圖表內容

請以結構化格式回傳。
```

### 降級處理

若 WebFetch 失敗（例如頁面需登入、IP 封鎖），則：
- 僅基於 JSONL 中的 `title` 和 `description` 欄位產出 Markdown
- 在 `notes` 欄位標註：「WebFetch 失敗，僅基於標題與摘要萃取」
- 觸發 `[REVIEW_NEEDED]` 標記

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`

1. **WebFetch 失敗** — 無法抓取報告頁面完整內容
2. **萃取指標與報告標題矛盾** — 例如標題為「遠端工作趨勢」，但內容無相關數據
3. **無法判定報告時間區間** — `report_period` 欄位無法從內容中推斷
4. **無法判定地理範圍** — `geographic_scope` 欄位無法判定

### 以下情況**不觸發** `[REVIEW_NEEDED]`

- ❌ **LinkedIn 用戶群體偏差** — 這是結構性限制，應在 `confidence` 欄位反映（例如 confidence: 中）
- ❌ **報告未涵蓋特定國家或產業** — 這是報告本身的範圍限制，不是萃取錯誤
- ❌ **缺少特定欄位** — 若報告本身未提供該欄位資訊（例如無薪資數據），不標記 REVIEW_NEEDED

## 輸出格式

### Markdown 模板

```markdown
---
title: "{報告標題}"
source_url: "{原始報告 URL}"
source_layer: "global_linkedin_workforce"
category: "{category enum value}"
date: "{報告發布日期 YYYY-MM-DD}"
fetched_at: "{擷取時間戳 ISO 8601}"
report_period: "{報告涵蓋時間區間，例如 2024-Q4 或 2024年度}"
geographic_scope: "{地理範圍，例如：全球 / 美國 / 歐洲}"
confidence: "{高/中/低}"
severity: "info"
---

# {報告標題}

## 關鍵發現

{列出報告的主要發現，每項一段}

## 核心數據

{萃取的量化指標，例如：
- 人才流動：XX% 增長
- 熱門技能：1. Python 2. Cloud Computing 3. ...
- 遠端工作職缺占比：XX%
}

## 趨勢分析

{報告中的趨勢描述與解讀}

## 來源資訊

- 發布單位：LinkedIn Economic Graph / Workforce Reports
- 報告涵蓋期間：{report_period}
- 地理範圍：{geographic_scope}

## 備註

{notes}
```

### 檔案命名規則

`{YYYY-MM-DD}_{sanitized_title}.md`

例如：`2024-12-15_global-talent-migration-trends.md`

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] 報告標題與 `source_url` 正確對應
- [ ] `category` 值為預定義的 enum 值之一
- [ ] `report_period` 和 `geographic_scope` 已填寫（若報告有提供）
- [ ] 關鍵發現來自報告內容，非 AI 推測
- [ ] 核心數據有明確來源（報告內的圖表或文字）
- [ ] `confidence` 欄位反映資料來源的結構性限制（LinkedIn 用戶群體偏差 → 中）
- [ ] 若 WebFetch 失敗，已在 `notes` 標註並觸發 `[REVIEW_NEEDED]`
- [ ] 若萃取指標與標題矛盾，已觸發 `[REVIEW_NEEDED]`
- [ ] 檔案名稱符合命名規則
- [ ] Markdown 格式正確（YAML frontmatter + 內容區塊）
