# global_ilo_stats Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_ilo_stats / ILO 國際勞工統計 |
| **Engineering function** | 從 ILO ILOSTAT API 擷取全球勞動市場統計數據，涵蓋開發中國家 |
| **Collectable data** | 全球失業率、非正規就業比例、性別薪資差距、童工統計、產業就業分布 |
| **Data source** | ILOSTAT API (https://ilostat.ilo.org/data/), ILOSTAT bulk download |
| **Automation level** | 80% — REST API 提供結構化數據，僅需格式轉換 |
| **Output value** | 全球（含開發中國家）勞動市場數據，補充 OECD 的已開發國家偏差 |
| **Risk type** | 數據時滯更長（年度更新為主）、開發中國家數據品質不一 |
| **Reviewer persona** | 領域保守審核員 |

## 執行指令

從 ILOSTAT API 擷取的 JSONL 資料進行萃取，每一行為一筆統計指標記錄。

### 萃取邏輯

1. 解析 JSON 欄位：`indicator`（指標代碼）、`country`（國家代碼）、`year`、`value`、`sex`、`age_group` 等
2. 依照 category enum 分類
3. 產生結構化 Markdown 輸出
4. 若國家代碼或指標代碼無法識別，標記 `[REVIEW_NEEDED]`

## 分類規則（Category Enum）

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `employment` | 就業統計 | indicator = EMP_TEMP_SEX_AGE_NB_A 或 EMP_DWAP_SEX_AGE_RT_A |
| `unemployment` | 失業統計 | indicator = UNE_TUNE_SEX_AGE_NB_A 或 UNE_DEAP_SEX_AGE_RT_A |
| `labour_force` | 勞動力統計 | indicator = EAP_TEAP_SEX_AGE_NB_A 或 EIP_TEIP_SEX_AGE_NB_A |
| `participation_rate` | 勞動參與率 | indicator = EAP_DWAP_SEX_AGE_RT_A |

**嚴格限制：category 只能使用上述英文值，不可自行新增。** 需要新增 category 時必須與使用者確認後寫入本檔案。

## WebFetch 補充規則

### 策略：不使用

ILOSTAT API 提供完整結構化數據，無需 WebFetch 補充。

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的場景

1. **數據格式異常** — JSON 結構與預期不符（缺少必要欄位 indicator、country、year、value）
2. **國家代碼無效** — country 欄位不符合 ISO 3166 標準且無法識別
3. **指標代碼無法分類** — indicator 無法對應到任何 category enum

### 不觸發的場景

- ❌ **數據時滯** — ILO 年度更新為常態，非萃取問題
- ❌ **特定國家數據缺失** — 資料來源結構性限制，應在 notes 說明，不標記 REVIEW_NEEDED
- ❌ **數值為空或零** — 可能為該國未統計該指標，屬正常情況

## 輸出格式

```markdown
---
source_layer: global_ilo_stats
category: {category_enum_value}
indicator: {指標名稱}
country: {國家名稱}
country_code: {ISO 3166 代碼}
year: {YYYY}
value: {數值}
unit: {單位}
sex: {male/female/total}
age_group: {年齡組}
fetched_at: {YYYY-MM-DD HH:MM:SS}
source_url: {ILO ILOSTAT 資料頁面 URL}
confidence: 高
---

# {指標名稱} — {國家名稱} ({year})

## 數據摘要

- **指標**：{indicator}
- **國家**：{country} ({country_code})
- **年份**：{year}
- **數值**：{value} {unit}
- **性別**：{sex}
- **年齡組**：{age_group}

## 資料來源

- **來源**：ILO ILOSTAT
- **資料集**：{dataset_code}
- **擷取時間**：{fetched_at}

## 備註

{如有資料品質說明、覆蓋範圍限制等，在此補充}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] category 為定義的 5 個 enum 值之一
- [ ] country_code 符合 ISO 3166 標準
- [ ] year 為有效年份（1900-2100）
- [ ] value 為數值或明確標註 N/A
- [ ] source_url 可連結至 ILOSTAT 資料頁面
- [ ] confidence 評估合理（API 結構化數據通常為「高」）
- [ ] 若數據格式異常或無法分類，已標記 `[REVIEW_NEEDED]`
- [ ] 未因數據時滯或國家缺失而誤標 `[REVIEW_NEEDED]`
