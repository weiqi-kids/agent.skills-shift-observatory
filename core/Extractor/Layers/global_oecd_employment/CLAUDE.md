# global_oecd_employment Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_oecd_employment / OECD 就業統計 |
| **Engineering function** | 從 OECD.Stat API 擷取 OECD 國家的就業統計數據 |
| **Collectable data** | 失業率、就業人口、勞動參與率、產業就業結構、薪資中位數 |
| **Data source** | OECD.Stat REST API (https://stats.oecd.org/) |
| **Automation level** | 85% — REST API 結構化數據 |
| **Output value** | OECD 國家官方就業統計，高可信度跨國比較基準 |
| **Risk type** | 數據時滯（通常落後1-2季）、定義差異（各國統計口徑不同） |
| **Reviewer persona** | 領域保守審核員 |

## 執行指令

從 raw/ 目錄中的 JSONL 檔案讀取 OECD API 回應，對每個條目：

1. 解析 JSON 結構，提取指標資料
2. 萃取以下關鍵資訊：
   - 指標名稱（例如：Unemployment Rate, Employment Population）
   - 國家代碼（LOCATION）與國家名稱
   - 時間區間（TIME_PERIOD）
   - 數值（OBS_VALUE）與單位（UNIT_MEASURE）
   - 資料來源與最後更新時間
3. 判定分類（category）
4. 產出 Markdown 檔案到對應 category 子目錄

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下英文值，不可自行新增。**

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `unemployment_rate` | 失業率 | 指標為 Unemployment Rate 相關數據 |
| `employment_population` | 就業人口 | 指標為 Employment Population, Employment-to-Population Ratio |
| `labor_participation` | 勞動參與率 | 指標為 Labour Force Participation Rate |
| `industry_employment` | 產業就業結構 | 指標為 Employment by Industry, Sectoral Employment |
| `wage_statistics` | 薪資統計 | 指標為 Average Wage, Median Wage, Wage Growth |

若指標無法明確對應上述分類，預設使用 `employment_population`。

## WebFetch 補充規則

### 策略：不使用

OECD.Stat API 回傳結構化 JSON 數據，資訊完整，**不需要**使用 WebFetch。

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`

1. **API 回傳非預期的數據格式** — 例如缺少必要欄位（LOCATION, TIME_PERIOD, OBS_VALUE）
2. **國家代碼無法識別** — LOCATION 欄位的國家代碼不在 OECD 成員國清單中且無法對應
3. **數值異常** — 例如失業率超過 100%、就業人口為負數
4. **時間區間格式無法解析** — TIME_PERIOD 欄位格式異常（例如非 YYYY-QN 或 YYYY-MM）

### 以下情況**不觸發** `[REVIEW_NEEDED]`

- ❌ **數據時滯（落後1-2季）** — 這是官方統計的正常狀況，應在 `notes` 欄位標註
- ❌ **特定國家無數據** — OECD 數據涵蓋範圍本身有限，應在 `notes` 欄位標註
- ❌ **統計定義差異** — 各國統計口徑不同是結構性限制，應在 `confidence` 欄位反映（例如 confidence: 中）
- ❌ **缺少特定產業細分數據** — 若 API 本身未提供該欄位資訊，不標記 REVIEW_NEEDED

## 輸出格式

### Markdown 模板

```markdown
---
title: "{國家名稱} - {指標名稱} ({時間區間})"
source_url: "https://stats.oecd.org/"
source_layer: "global_oecd_employment"
category: "{category enum value}"
date: "{資料發布日期 YYYY-MM-DD}"
fetched_at: "{擷取時間戳 ISO 8601}"
report_period: "{時間區間，例如 2024-Q3}"
geographic_scope: "{國家名稱，例如：美國 (USA) / 日本 (JPN)}"
confidence: "{高/中/低}"
severity: "info"
---

# {國家名稱} - {指標名稱} ({時間區間})

## 核心數據

- **指標名稱**：{INDICATOR}
- **國家**：{LOCATION}（{國家中文名稱}）
- **時間區間**：{TIME_PERIOD}
- **數值**：{OBS_VALUE} {UNIT_MEASURE}
- **資料來源**：OECD.Stat
- **最後更新**：{LAST_UPDATED}

## 歷史趨勢

{若 API 回傳包含多個時間點的數據，列出趨勢}

例如：
- 2024-Q3: 3.8%
- 2024-Q2: 4.0%
- 2024-Q1: 4.2%

趨勢：失業率持續下降

## 跨國比較

{若有其他國家同期數據，可提供簡單比較}

## 備註

{notes}

例如：
- 數據時滯：本數據為 2024 Q3 統計，發布時間為 2024-12-15
- 統計定義：各國失業率定義可能略有差異，跨國比較需謹慎
```

### 檔案命名規則

`{YYYY-MM-DD}_{LOCATION}_{indicator_code}.md`

例如：`2024-12-15_USA_unemployment-rate.md`

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] API 回應包含必要欄位（LOCATION, TIME_PERIOD, OBS_VALUE）
- [ ] `category` 值為預定義的 enum 值之一
- [ ] 國家代碼（LOCATION）已正確對應為國家名稱
- [ ] 時間區間（TIME_PERIOD）格式正確（YYYY-QN 或 YYYY-MM）
- [ ] 數值（OBS_VALUE）與單位（UNIT_MEASURE）正確對應
- [ ] `confidence` 欄位為「高」（OECD 官方統計）
- [ ] `notes` 欄位標註數據時滯與統計定義差異
- [ ] 若數值異常（如失業率 > 100%），已觸發 `[REVIEW_NEEDED]`
- [ ] 若國家代碼無法識別，已觸發 `[REVIEW_NEEDED]`
- [ ] 檔案名稱符合命名規則
- [ ] Markdown 格式正確（YAML frontmatter + 內容區塊）
