# Layer: global_hays_salary

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_hays_salary / Hays 薪資指南 |
| **Engineering function** | 擷取 Hays 年度薪資指南的關鍵薪資數據與就業趨勢分析 |
| **Collectable data** | 各職務薪資基準、薪資成長率、熱門技能、雇主給薪策略、產業薪資比較 |
| **Automation level** | 40% — PDF 報告需 AI 萃取，報告格式因區域而異，薪資數據需結構化處理 |
| **Output value** | 跨國薪資基準數據，人資顧問觀點的市場分析，中高階職位薪資趨勢 |
| **Risk type** | 報告僅年度更新、偏向 Hays 服務的中高階職位、各國報告格式不一 |
| **Reviewer persona** | 資料可信度審核員 |

## 資料來源

- **來源名稱**: Hays Salary Guide
- **URL**: https://www.hays.com/ (各區域網站路徑不同)
- **更新頻率**: 年度（通常於每年 Q4 發布次年度指南）
- **資料格式**: PDF 報告 + 網頁摘要
- **涵蓋範圍**: 多國/地區（澳洲、英國、德國、新加坡、香港、中國等）

## 主要區域與 URL

| 區域 | URL 範例 |
|------|----------|
| Global | https://www.hays.com/salary-guide |
| Australia | https://www.hays.com.au/salary-guide |
| UK | https://www.hays.co.uk/salary-guide |
| Germany | https://www.hays.de/personaldienstleistung/gehaltsstudie |
| Singapore | https://www.hays.com.sg/salary-guide |
| Hong Kong | https://www.hays.com.hk/salary-guide |
| China | https://www.hays.cn/salary-guide |

## 執行指令

### 萃取邏輯

從 `docs/Extractor/global_hays_salary/raw/*.jsonl` 逐行讀取報告元數據，透過 WebFetch 抓取完整報告內容或 PDF 摘要，萃取以下資訊：

1. **薪資基準數據**
   - 職務名稱
   - 薪資範圍（最低-最高，含幣別）
   - 經驗年限要求
   - 產業分類

2. **薪資成長趨勢**
   - 年度成長率
   - 產業間比較
   - 地區差異

3. **熱門技能與人才需求**
   - 最受雇主歡迎的技能
   - 人才短缺領域
   - 新興技能趨勢

4. **雇主給薪策略**
   - 固定薪資 vs 績效獎金
   - 福利趨勢
   - 留才策略

### 輸出格式

每個區域每年產出多個 `.md` 檔（依類別），檔名格式：`{YYYY}-{region}-{category_slug}.md`

---
```yaml
title: "{報告標題}"
source_layer: "global_hays_salary"
source_url: "{原始 URL}"
fetched_at: "{ISO 8601 timestamp}"
report_year: "{YYYY}"
region: "{country/region code}"
category: "{category_value}"
currency: "{幣別 (ISO 4217)}"
```
---

## 內容摘要

{2-3 句話總結本區域本年度薪資指南重點}

## 薪資基準

{若為 salary_benchmark category，列出關鍵職務薪資範圍}

| 職務 | 經驗年限 | 薪資範圍 | 產業 |
|------|----------|----------|------|
| {職務名稱} | {X-Y 年} | {min}-{max} {currency} | {產業} |

## 薪資成長趨勢

{若為 salary_growth category，列出年度成長數據}

- **整體成長率**: {%}
- **成長最快產業**: {產業名稱} ({%})
- **與前一年比較**: {說明}

## 熱門技能

{若為 hot_skills category，列出最受歡迎的技能}

1. {技能名稱} — {簡短說明}
2. {技能名稱} — {簡短說明}

## 雇主策略洞察

{若為 employer_strategy category，列出雇主給薪與留才策略}

## 資料來源驗證

- [ ] 薪資數字可從原始報告/PDF 驗證
- [ ] 幣別明確標示
- [ ] 報告年度與發布時間一致

## 備註

{特殊情況、資料限制、報告涵蓋範圍說明}

---

## 分類規則 (Category Enum)

| 英文值 | 中文 | 判定條件 |
|--------|------|----------|
| `salary_benchmark` | 薪資基準 | 主要內容為特定職務的薪資範圍數據 |
| `salary_growth` | 薪資成長 | 聚焦年度薪資成長率或跨年比較 |
| `hot_skills` | 熱門技能 | 列出最受歡迎或需求增長的技能 |
| `employer_strategy` | 雇主策略 | 雇主給薪策略、留才措施、福利趨勢 |
| `regional_comparison` | 區域比較 | 跨國家或跨地區的薪資比較 |

**嚴格限制**: category 只能使用上述英文值，不可自行新增。需要新增 category 時必須與使用者確認後更新此表格。

## WebFetch 補充規則

### 策略: 必用

Hays 薪資指南僅在網頁上提供摘要或 PDF 下載連結，完整數據需透過 WebFetch 抓取報告頁面或 PDF 內容。

### 觸發條件

每筆 JSONL 記錄都必須執行 WebFetch。

### 降級處理

若 WebFetch 失敗：
1. 基於 JSONL 中已有的元數據產出有限度的萃取結果
2. 在 `notes` 欄位標註：「WebFetch 失敗，僅基於元數據產出」
3. 觸發 `[REVIEW_NEEDED]` 標記

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. 薪資數字無法從原始報告驗證（例如：WebFetch 失敗，僅能猜測）
2. 幣別不明確或與報告區域矛盾
3. 報告年度無法確定或與 URL/標題不一致
4. WebFetch 失敗導致僅能產出部分資訊
5. 薪資範圍格式異常（例如：最低薪高於最高薪）

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 報告僅年度更新 — 這是 Hays 薪資指南的正常頻率
- ❌ 偏向中高階職位 — 這是 Hays 的業務特性，應在 confidence 欄位反映
- ❌ 各區域報告格式不一致 — 這是結構性限制，不代表萃取有誤
- ❌ 某些產業或職務資料缺失 — 並非所有區域都涵蓋所有產業
- ❌ 僅有薪資範圍，無平均值 — 某些報告不提供平均值

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] 報告年度明確標示
- [ ] 薪資數字可追溯至原始報告或 PDF
- [ ] 幣別正確標示（符合 ISO 4217）
- [ ] Category 分類符合 enum 定義
- [ ] 若有薪資範圍，確認最低 ≤ 最高
- [ ] 若 WebFetch 失敗，已標註並觸發 REVIEW_NEEDED
- [ ] 未將「僅年度更新」或「偏向中高階」作為 REVIEW_NEEDED 的理由
- [ ] 檔案命名格式正確：`{YYYY}-{region}-{category_slug}.md`
