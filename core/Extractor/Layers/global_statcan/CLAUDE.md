# global_statcan Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | global_statcan / 加拿大統計局勞動力調查 |
| **Engineering function** | 從 Statistics Canada Web Data Service 擷取加拿大勞動力市場統計資料,提供北美地區就業市場宏觀趨勢 |
| **Collectable data** | 勞動力特徵（就業、失業、勞動參與率）、按職業分類的就業人數、產業分布、薪資統計 |
| **Data source** | Statistics Canada Web Data Service (https://www150.statcan.gc.ca/t1/wds/rest/) |
| **API 文件** | https://www.statcan.gc.ca/en/developers/wds/user-guide |
| **Automation level** | 50% — API 端點可能變更，需手動下載 CSV 或使用 OECD/ILO 替代來源 |
| **Output value** | 補充北美勞動市場宏觀資料,與全球 ILO、OECD 資料交叉驗證,提供產業就業趨勢基準線 |
| **Risk type** | API 資料結構變動、時間序列資料需要歷史比較、職業分類標準（NOC）與其他國家不一致 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

### 輸入格式

每個 JSONL 行是一筆 Statistics Canada API 回傳的統計資料，由 fetch.sh 轉換後產生：

```json
{
  "product_id": "14-10-0287-01",
  "product_name": "Labour force characteristics by province, monthly, seasonally adjusted",
  "coordinate": "1.1.1.1.1.1.1",
  "dimension": {
    "Geography": "Canada",
    "Labour force characteristics": "Employment",
    "Sex": "Both sexes",
    "Age group": "15 years and over",
    "Statistics": "Estimate"
  },
  "value": 20500.5,
  "uom": "Persons (x 1,000)",
  "scalar": "thousands",
  "reference_period": "2026-01",
  "release_time": "2026-02-07T08:30:00Z",
  "status": "A",
  "symbol": "",
  "fetched_at": "2026-02-08T10:30:00Z",
  "source": "statcan_api"
}
```

### 萃取邏輯

讀取 `docs/Extractor/global_statcan/raw/` 下的 JSONL 檔案,逐行處理每筆統計資料:

1. **欄位映射**
   | 輸出欄位 | 來源欄位 | 處理邏輯 |
   |----------|----------|----------|
   | `title` | `product_name` + `dimension` | 組合成有意義的標題（如「加拿大就業人數（15歲以上，兩性）」） |
   | `product_id` | `product_id` | 直接使用 |
   | `value` | `value` | 數值資料 |
   | `unit` | `uom` | 單位（如「千人」） |
   | `reference_period` | `reference_period` | 統計期間（YYYY-MM 格式） |
   | `geography` | `dimension.Geography` | 地理範圍 |
   | `source_url` | 組合 | `https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid={product_id}` |

2. **分類判定**
   - 依據 `product_id` 和 `dimension.Labour force characteristics` 判定
   - 必須使用 category enum 中定義的英文值
   - 判定優先序：
     1. `Labour force characteristics` 欄位（如 Employment → employment_by_occupation）
     2. `product_id`（如 14-10-0287 → labour_force）
     3. 職業相關資料表 → employment_by_occupation

3. **時間序列處理**
   - 保留 `reference_period` 作為資料日期
   - 若擷取歷史資料，每筆獨立萃取（不合併）
   - 在 notes 欄位標註是否為最新資料

## 分類規則 (Category Enum)

**嚴格限制: category 只能使用以下定義的英文值,不可自行新增。**

| 英文 Key | 中文 | 判定條件 |
|----------|------|----------|
| labour_force | 勞動力統計 | 勞動力特徵、勞動參與率、就業率相關資料表 (product_id: 14-10-0287) |
| employment_by_occupation | 按職業就業 | 按職業分類的就業人數 (product_id: 14-10-0064) |
| unemployment | 失業統計 | 失業率、失業人數相關資料 (Labour force characteristics: Unemployment) |

## WebFetch 補充規則

### WebFetch 策略: 不使用

Statistics Canada Web Data Service 已回傳完整結構化資料，包含：
- `productId` — 資料表編號
- `coordinate` — 資料座標（多維度索引）
- `value` — 統計數值
- `referencePeridod` — 統計期間
- `dimension` — 維度資訊（地理、性別、年齡等）

無需額外抓取網頁補充資訊。

### API 參數說明

Statistics Canada API 端點格式：
```
GET /getDataFromCubePidCoordAndLatestNPeriods/{productId}/{coordinate}/{periods}
```

| 參數 | 說明 | 範例 |
|------|------|------|
| `productId` | 資料表編號（帶連字號） | 1410028701 (對應 14-10-0287-01) |
| `coordinate` | 資料座標（點分格式） | 1.1.1.1.1.1.1 |
| `periods` | 取得最近 N 個期間 | 12 (最近 12 個月) |

### 主要資料表

| Product ID | 名稱 | 更新頻率 | 用途 |
|------------|------|----------|------|
| 14-10-0287-01 | Labour force characteristics by province, monthly | 每月 | 就業、失業、勞動參與率 |
| 14-10-0064-01 | Employment by occupation, annual | 每年 | 按職業分類的就業人數 |
| 14-10-0307-01 | Labour force characteristics by industry, annual | 每年 | 按產業分類的就業資料 |

### 已知問題（2026-02-08）

Statistics Canada Web Data Service API 端點目前回傳 HTTP 404 錯誤。可能原因：

1. API 端點格式已變更（需要重新查閱最新文件）
2. API 服務暫時停用
3. 需要註冊 API key（官方文件未明確說明）

**替代方案**：

1. **手動下載模式**（類似 global_wef_jobs）：
   - 手動下載 CSV: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410028701
   - 放置於 `docs/Extractor/global_statcan/raw/`
   - fetch.sh 偵測後轉換為 JSONL

2. **使用替代資料源**：
   - OECD.Stat 包含加拿大勞動力資料（已有 global_oecd_employment Layer）
   - ILO ILOSTAT 也包含加拿大統計（已有 global_ilo_stats Layer）

**建議**：優先使用 OECD/ILO 替代來源，除非需要 Statistics Canada 特有的細分維度資料。

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`:

1. **category 無法判定** — `product_id` 和 `dimension` 欄位皆無法對應到已定義的 category
2. **資料格式異常** — `value` 欄位為空或非數值
3. **API 結構變動** — 回傳 JSON 格式與預期不符
4. **時間序列缺失** — `reference_period` 欄位為空
5. **維度資訊不完整** — `dimension` 物件缺少關鍵欄位（如 Geography）

### 以下情況**不觸發** `[REVIEW_NEEDED]`:

- ❌ 僅單一來源（這是此 Layer 的結構性限制,在 confidence 欄位反映）
- ❌ symbol 欄位有值（如 "E" 表示估計值,這是統計局的標準註記）
- ❌ scalar 欄位為 "thousands" 或其他單位換算（這是正常的資料表示方式）
- ❌ 資料為歷史期間（非最新月份）
- ❌ 部分維度欄位為 "Total" 或 "Both sexes"（這是聚合資料）

## 輸出格式

每筆統計資料萃取為一個 Markdown 檔案,檔名格式: `{product_id}_{coordinate}_{reference_period}.md`

### Markdown 模板

```markdown
---
title: "{統計項目標題}"
product_id: "{Statistics Canada 資料表編號}"
coordinate: "{資料座標}"
category: "{category_enum_value}"
value: {數值}
unit: "{單位}"
reference_period: "{YYYY-MM}"
geography: "{地理範圍}"
dimensions: "{維度資訊 JSON 字串}"
source_url: "{Statistics Canada 資料表網址}"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
confidence: "{high/medium/low}"
notes: "{備註 (若有)}"
---

# {統計項目標題}

## 基本資訊
- **資料表**: {product_id} — {product_name}
- **統計期間**: {reference_period}
- **地理範圍**: {geography}
- **數值**: {value} {unit}
- **類別**: {category 的中文對應}

## 維度資訊
{列出所有 dimension 欄位，如：}
- Geography: {dimension.Geography}
- Labour force characteristics: {dimension["Labour force characteristics"]}
- Sex: {dimension.Sex}
- Age group: {dimension["Age group"]}
- Statistics: {dimension.Statistics}

## 資料狀態
{若 symbol 或 status 欄位有值，說明其含義：}
- Status: {status} ({A=Actual, P=Preliminary, E=Estimated})
- Symbol: {symbol} ({E=估計值, ..=不適用, ...=無資料})

## 資料來源
- [查看完整資料表]({source_url})
- 資料發布時間: {release_time}
- 資料擷取時間: {fetched_at}
```

## 自我審核 Checklist

輸出前必須逐項確認:

- [ ] **category 值合法** — 必須是 category enum 中定義的英文值之一
- [ ] **必要欄位完整** — title, product_id, value, reference_period, category, fetched_at 皆不為空
- [ ] **source_url 有效** — 格式正確且為 statcan.gc.ca 網域
- [ ] **數值邏輯正確** — value 欄位為數值型態（可含小數點）
- [ ] **category 判定有依據** — 能從 product_id 或 dimension 欄位找到支持該分類的依據
- [ ] **無幻覺內容** — 所有欄位內容皆來自 API 原始資料,無憑空生成
- [ ] **confidence 合理** — 依據資料完整度評估（政府官方 API 結構化資料可信度高 → high；有 symbol "E" 估計值 → medium）
- [ ] **notes 欄位適當使用** — 有異常狀況或重要註記時必須說明
- [ ] **時間序列正確** — reference_period 格式為 YYYY-MM（月度）或 YYYY（年度）
- [ ] **維度資訊保留** — dimensions 欄位保留完整的 dimension 物件（JSON 字串）

**若任一項未通過,必須在檔案開頭加上 `[REVIEW_NEEDED]` 標記。**
