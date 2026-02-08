# global_eurostat Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_eurostat / 歐盟統計局就業市場數據 |
| **Engineering function** | 收集歐盟 27 國就業率、失業率、薪資結構等官方統計數據，提供跨國比較基準 |
| **Collectable data** | Eurostat REST API（JSON-stat 格式）：失業率（月度）、就業率（年度）、薪資結構統計 |
| **Automation level** | 100% — 官方 Open API，無需認證，結構穩定 |
| **Output value** | 提供歐盟勞動市場的權威數據，支援跨國趨勢分析與政策比較 |
| **Risk type** | 低風險 — 官方統計數據，但需注意數據發布延遲與修訂 |
| **Reviewer persona** | 資料可信度審核員 |

## Category Enum

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `unemployment_rate` | 失業率數據 | 資料集代碼為 `une_rt_m` 或包含 unemployment 關鍵字 |
| `employment_rate` | 就業率數據 | 資料集代碼為 `lfsi_emp_a` 或包含 employment 關鍵字 |
| `wage_statistics` | 薪資統計 | 資料集代碼為 `earn_ses_annual` 或包含 wage/salary/earnings 關鍵字 |

> **嚴格限制**：category 只能使用上述三個英文值，不可自行新增。需要新增時必須與使用者確認後寫入本文件。

## 執行指令

### 資料擷取邏輯

1. **API 端點**：`https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/{dataset}?format=JSON`
2. **主要資料集**：
   - `une_rt_m`：失業率（月度）
   - `lfsi_emp_a`：就業率（年度）
   - `earn_ses_annual`：薪資結構統計
3. **參數**：
   - `format=JSON`：JSON-stat 格式
   - `geo=EU27_2020`：歐盟 27 國
   - `sinceTimePeriod=YYYY-MM`：起始時間

### 萃取邏輯

接收 JSONL 中的單筆 JSON 資料（包含 dataset、geo、time、value、label 等欄位），產出 Markdown 文件。

**輸出規範**：
- 檔名：`{time}_{geo}_{dataset}.md`（例：`2024-M01_EU27_unemployment.md`）
- 路徑：`docs/Extractor/global_eurostat/{category}/`
- 內容：依下方輸出格式模板

## WebFetch 補充規則

**策略**：不使用

**原因**：Eurostat API 直接回傳結構化 JSON-stat 資料，無需 WebFetch 補充。

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：

1. **API 回應缺少必要欄位** — `value`、`dimension`、`id` 等核心欄位為空或缺失
2. **時間格式異常** — 無法解析為標準時間週期（如 `2024-M01`）
3. **數值超出合理範圍** — 失業率 > 50% 或 < 0%，就業率 > 100% 或 < 0%
4. **地理代碼無法識別** — geo 欄位不在已知的歐盟國家/區域清單中
5. **資料集代碼未定義** — dataset 不在已知的三個資料集代碼中

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 僅有 API 資料，無其他來源交叉驗證 — 這是結構性限制，應在 `confidence` 欄位反映
- ❌ 資料發布日期晚於統計期間 — Eurostat 資料常有延遲發布，屬正常現象
- ❌ 某些國家資料缺失 — 部分國家可能未報送特定統計項目，屬正常現象

## 輸出格式

```markdown
---
title: "{地區名稱} {資料集名稱} ({時間週期})"
date: {API 回應時間戳（ISO 8601）}
source_url: "https://ec.europa.eu/eurostat/databrowser/view/{dataset}/default/table"
fetched_at: {擷取時間戳（ISO 8601）}
category: {category_enum_value}
geo_code: "{地理代碼}"
time_period: "{時間週期}"
dataset_code: "{資料集代碼}"
value: {數值}
unit: "{單位}"
confidence: "高"
---

# {地區名稱} {資料集名稱} ({時間週期})

**來源**：Eurostat
**資料集代碼**：{dataset_code}
**時間週期**：{time_period}
**地理範圍**：{geo_code} — {地區名稱}
**數值**：{value} {unit}

## 資料詳情

{根據資料集類型填寫}

### 失業率數據（若 category = unemployment_rate）
- **失業率**：{value}%
- **統計期間**：{time_period}
- **涵蓋地區**：{地區名稱}

### 就業率數據（若 category = employment_rate）
- **就業率**：{value}%
- **統計期間**：{time_period}
- **涵蓋地區**：{地區名稱}

### 薪資統計（若 category = wage_statistics）
- **平均薪資**：{value} {unit}
- **統計期間**：{time_period}
- **涵蓋地區**：{地區名稱}

## 資料來源

- **官方連結**：https://ec.europa.eu/eurostat/databrowser/view/{dataset_code}/default/table
- **API 端點**：https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/{dataset_code}
- **擷取時間**：{fetched_at}

## Notes

{若有特殊情況或需要說明的事項}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] category 欄位只使用定義的三個英文值之一
- [ ] source_url 指向正確的 Eurostat Databrowser 頁面
- [ ] time_period 格式正確（如 `2024-M01` 或 `2024`）
- [ ] geo_code 在已知的歐盟國家/區域清單中
- [ ] value 數值在合理範圍內（失業率/就業率 0-100%）
- [ ] unit 單位正確（%、EUR、等）
- [ ] confidence 欄位填寫完整（通常為「高」，因為是官方統計）
- [ ] 若觸發 `[REVIEW_NEEDED]` 規則，已在檔案開頭加上標記
- [ ] 檔名符合規範：`{time}_{geo}_{dataset}.md`
- [ ] 路徑正確：`docs/Extractor/global_eurostat/{category}/`
- [ ] 無幻覺內容（所有資訊來自 API 回應，未自行推測）
- [ ] Jekyll front matter 格式正確（YAML 語法無誤）

## 已知問題

### API 限制
- Eurostat API 對單次查詢的資料點數有限制（建議分批查詢）
- 部分資料集可能需要額外的 dimension 參數（如年齡、性別等）

### 資料延遲
- 月度資料通常延遲 1-2 個月發布
- 年度資料可能延遲 6-12 個月

### JSON-stat 格式
- 需要正確解析 `dimension`、`id`、`size` 等欄位以對應數值
- 部分資料集使用 `status` 欄位標註數據狀態（如暫估值、修訂值）

## 相關資源

- Eurostat API 文件：https://ec.europa.eu/eurostat/web/json-and-unicode-web-services
- 資料集清單：https://ec.europa.eu/eurostat/data/database
- JSON-stat 格式規範：https://json-stat.org/
