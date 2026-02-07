# Layer: global_manpower_outlook

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_manpower_outlook / ManpowerGroup 就業展望調查 |
| **Engineering function** | 擷取 ManpowerGroup 季度就業展望調查報告，追蹤全球雇主招聘意向 |
| **Collectable data** | 淨就業展望指數(Net Employment Outlook)、各產業招聘意向、各國比較、季節調整後趨勢 |
| **Automation level** | 50% — PDF/網頁報告需 AI 萃取，報告結構相對固定但格式可能變化 |
| **Output value** | 全球雇主端前瞻指標，每季更新的招聘信心指數，涵蓋 40+ 國家 |
| **Risk type** | 調查方法論變更、季節性干擾、各國樣本數差異 |
| **Reviewer persona** | 領域保守審核員 |

## 資料來源

- **來源名稱**: ManpowerGroup Employment Outlook Survey (MEOS)
- **URL**: https://go.manpowergroup.com/meos
- **更新頻率**: 季度（每年 Q1, Q2, Q3, Q4）
- **資料格式**: 網頁報告 + PDF 下載
- **涵蓋範圍**: 全球 40+ 國家/地區

## 執行指令

### 萃取邏輯

從 `docs/Extractor/global_manpower_outlook/raw/*.jsonl` 逐行讀取報告元數據，透過 WebFetch 抓取完整報告內容，萃取以下資訊：

1. **淨就業展望指數** (Net Employment Outlook, NEO)
   - 計算方式：雇主計劃增加員工比例 - 計劃減少員工比例
   - 季節調整後數值（若有提供）
   - 與前一季度/前一年度比較

2. **產業別展望**
   - 各產業的 NEO 數值
   - 產業排名（最樂觀到最保守）

3. **國家/地區比較**
   - 各國 NEO 數值
   - 區域趨勢分析

4. **人才短缺洞察**
   - 雇主面臨的人才短缺領域
   - 技能需求趨勢

### 輸出格式

每筆資料產出一個 `.md` 檔，檔名格式：`{YYYY}-Q{Q}-{country_or_global}.md`

---
```yaml
title: "{報告標題}"
source_layer: "global_manpower_outlook"
source_url: "{原始 URL}"
fetched_at: "{ISO 8601 timestamp}"
report_period: "{YYYY-Q{Q}}"
category: "{category_value}"
region: "{country/region code or 'global'}"
net_employment_outlook: {數值或 null}
seasonal_adjusted: {true/false}
```
---

## 內容摘要

{2-3 句話總結本期報告重點}

## 淨就業展望指數

- **本期數值**: {NEO}% (季節調整後: {SA_NEO}%)
- **前期比較**: {與上季度比較}
- **年度比較**: {與去年同期比較}

## 產業展望

| 產業 | NEO (%) | 排名 |
|------|---------|------|
| {產業名稱} | {數值} | {排名} |

## 區域/國家亮點

{若為全球報告，列出主要國家/地區數據；若為單一國家報告，列出該國細部分析}

## 人才短缺洞察

{雇主反映的人才短缺領域、技能需求}

## 資料來源驗證

- [ ] NEO 數值可從原始報告驗證
- [ ] 調查期間明確標示
- [ ] 產業分類與報告一致

## 備註

{任何需要說明的方法論變更、資料限制、特殊情況}

---

## 分類規則 (Category Enum)

| 英文值 | 中文 | 判定條件 |
|--------|------|----------|
| `net_outlook_index` | 淨就業展望 | 主要報導整體 NEO 指數或跨期比較 |
| `industry_outlook` | 產業展望 | 聚焦特定產業或產業間比較 |
| `country_comparison` | 國別比較 | 跨國家/地區的 NEO 比較 |
| `seasonal_trend` | 季節趨勢 | 季節調整分析或長期趨勢 |
| `talent_shortage` | 人才短缺 | 人才短缺、技能需求分析 |

**嚴格限制**: category 只能使用上述英文值，不可自行新增。需要新增 category 時必須與使用者確認後更新此表格。

## WebFetch 補充規則

### 策略: 必用

ManpowerGroup MEOS 報告頁面僅提供摘要，完整數據需透過 WebFetch 抓取。

### 觸發條件

每筆 JSONL 記錄都必須執行 WebFetch。

### 降級處理

若 WebFetch 失敗：
1. 基於 JSONL 中已有的元數據產出有限度的萃取結果
2. 在 `notes` 欄位標註：「WebFetch 失敗，僅基於元數據產出」
3. 觸發 `[REVIEW_NEEDED]` 標記

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. NEO 數值無法從原始報告驗證
2. 調查期間（年度/季度）不明確或與報告標題矛盾
3. WebFetch 失敗導致僅能產出部分資訊
4. 報告格式重大變更，萃取邏輯可能失效

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 季節性波動（例如：Q4 通常較 Q1 樂觀）— 這是正常現象
- ❌ 部分國家資料缺失 — 並非所有國家每季都參與調查
- ❌ 僅有季節調整前數值，無調整後數值 — 某些區域報告不提供季節調整
- ❌ 產業分類與過往略有不同 — 調查方法可能逐年調整

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] 報告期間（年度+季度）明確標示
- [ ] NEO 數值可追溯至原始報告
- [ ] Category 分類符合 enum 定義
- [ ] 若有產業/國家數據，至少列出前 3 名
- [ ] 若 WebFetch 失敗，已標註並觸發 REVIEW_NEEDED
- [ ] 未將「僅單一來源」作為 REVIEW_NEEDED 的理由
- [ ] 季節性波動未被誤判為異常
- [ ] 檔案命名格式正確：`{YYYY}-Q{Q}-{region}.md`
