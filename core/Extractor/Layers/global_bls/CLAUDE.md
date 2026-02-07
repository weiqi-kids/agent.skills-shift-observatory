# Layer: global_bls

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_bls / 美國勞工統計局 |
| **Engineering function** | 從 BLS Public Data API 擷取美國勞動市場統計數據 |
| **Collectable data** | 非農就業人數(NFP)、失業率(U-3/U-6)、CPI、平均時薪、JOLTS職缺數、產業就業 |
| **Automation level** | 90% — REST API 完全結構化，僅需處理 API 錯誤與數據修正標記 |
| **Output value** | 美國（全球最大經濟體）官方勞動統計，高頻高品質，全球勞動市場的領先指標 |
| **Risk type** | 數據修正（初值常被修正）、僅限美國市場 |
| **Reviewer persona** | 領域保守審核員 |

## 資料來源

- **來源名稱**: U.S. Bureau of Labor Statistics Public Data API
- **API 端點**: https://api.bls.gov/publicAPI/v2/timeseries/data/
- **更新頻率**: 月度（每月第一個星期五發布 NFP；其他指標各有排程）
- **資料格式**: JSON REST API
- **涵蓋範圍**: 美國全國及各州
- **API 文檔**: https://www.bls.gov/developers/

## 關鍵 Series ID

| Series ID | 指標名稱 | 說明 |
|-----------|----------|------|
| CES0000000001 | Total Nonfarm Employment | 非農就業總人數（千人） |
| LNS14000000 | Unemployment Rate | U-3 失業率（%） |
| LNS13327709 | U-6 Underemployment | U-6 未充分就業率（%） |
| CES0500000003 | Average Hourly Earnings | 平均時薪（美元） |
| JTS000000000000000JOL | JOLTS Job Openings | JOLTS 總職缺數（千人） |
| CUSR0000SA0 | CPI-U All Items | 消費者物價指數（1982-84=100） |

## 執行指令

### 萃取邏輯

從 `docs/Extractor/global_bls/raw/*.jsonl` 逐行讀取 API 回應，每行為一個時間序列的單一資料點。萃取以下資訊：

1. **Series ID** 與對應的指標名稱
2. **期間** (year + period，例如：2025M01)
3. **數值** (value)
4. **是否為初值/修正值** (若 API 提供 footnotes)

### 輸出格式

每個 Series ID 每月產出一個 `.md` 檔，檔名格式：`{series_id}_{YYYY}-{MM}.md`

---
```yaml
title: "{指標中文名稱} - {YYYY}年{M}月"
source_layer: "global_bls"
source_url: "https://api.bls.gov/publicAPI/v2/timeseries/data/{series_id}"
fetched_at: "{ISO 8601 timestamp}"
series_id: "{series_id}"
indicator_name: "{指標英文名稱}"
report_period: "{YYYY-MM}"
category: "{category_value}"
value: {數值}
unit: "{單位}"
is_preliminary: {true/false}
```
---

## 內容摘要

{1-2 句話說明本期數值與背景}

## 數據詳情

- **指標**: {指標中文名稱} ({series_id})
- **期間**: {YYYY}年{M}月
- **數值**: {value} {unit}
- **資料狀態**: {初值 / 修正值 / 最終值}

## 歷史比較

{若有前期數據，列出：}
- **月變化**: {與上月比較}
- **年變化**: {與去年同期比較}

## 備註

{API 回應中的 footnotes 或特殊說明}

---

## 分類規則 (Category Enum)

| 英文值 | 中文 | 判定條件 |
|--------|------|----------|
| `nonfarm_payroll` | 非農就業 | CES0000000001 及相關產業就業數據 |
| `unemployment_rate` | 失業率 | LNS14000000 (U-3) 或 LNS13327709 (U-6) |
| `average_earnings` | 平均薪資 | CES0500000003 及相關薪資指標 |
| `jolts_openings` | JOLTS職缺 | JTS* 系列（職缺、離職、僱用） |
| `industry_employment` | 產業就業 | 特定產業的就業人數 |
| `cpi_inflation` | 消費者物價 | CUSR* 系列 CPI 指標 |

**嚴格限制**: category 只能使用上述英文值，不可自行新增。需要新增 category 時必須與使用者確認後更新此表格。

## WebFetch 補充規則

### 策略: 不使用

BLS Public Data API 回應為完全結構化的 JSON，無需 WebFetch。

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. API 回應狀態碼非 200，或 JSON 結構中 `status` 欄位非 "REQUEST_SUCCEEDED"
2. Series ID 無法識別（不在已知指標清單中）
3. 數值欄位為空或格式異常（例如：非數字字串）
4. 期間格式無法解析（例如：year/period 欄位缺失或不合法）

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 數據修正（preliminary → revised → final）— 這是 BLS 正常流程
- ❌ 初值與修正值之間的差異 — 應在 `notes` 欄位記錄，但不代表萃取有誤
- ❌ 某個月的數據尚未發布 — 這是時間序列的正常特性
- ❌ 僅涵蓋美國市場 — 這是 BLS 的結構性限制，應反映在 confidence，而非 REVIEW_NEEDED

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] Series ID 與指標名稱對應正確
- [ ] 期間格式為 YYYY-MM（若原始為 M01 格式已轉換）
- [ ] 數值為數字型別，單位正確標示
- [ ] Category 分類符合 enum 定義
- [ ] 若 API 回應包含 footnotes，已記錄於備註欄
- [ ] 未將「數據修正」誤判為需要審核的錯誤
- [ ] 檔案命名格式正確：`{series_id}_{YYYY}-{MM}.md`
- [ ] 未因「僅限美國」而標記 REVIEW_NEEDED
