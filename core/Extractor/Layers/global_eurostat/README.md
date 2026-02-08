# global_eurostat Layer

歐盟統計局（Eurostat）就業市場數據擷取層

## 概覽

- **資料來源**: Eurostat REST API (JSON-stat 格式)
- **涵蓋範圍**: 歐盟 27 國
- **更新頻率**: 每日兩次
- **自動化程度**: 100%（官方 Open API）
- **無需認證**: 不需要 API key

## 資料集

| 資料集代碼 | 名稱 | 頻率 | Category |
|-----------|------|------|----------|
| `une_rt_m` | 失業率 | 月度 | unemployment_rate |
| `lfsi_emp_a` | 就業率 | 年度 | employment_rate |
| `earn_ses_annual` | 薪資結構統計 | 年度 | wage_statistics |

## 執行方式

### 測試連線

```bash
# 測試 API 連線
curl -s "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/une_rt_m?format=JSON&geo=EU27_2020&sinceTimePeriod=2024M01" | jq . | head -50
```

### 執行 fetch

```bash
cd core/Extractor/Layers/global_eurostat
./fetch.sh
```

預期輸出：
- `docs/Extractor/global_eurostat/raw/unemployment-YYYYMMDD.json`
- `docs/Extractor/global_eurostat/raw/unemployment-YYYYMMDD.jsonl`
- `docs/Extractor/global_eurostat/raw/employment-YYYYMMDD.json`
- `docs/Extractor/global_eurostat/raw/employment-YYYYMMDD.jsonl`
- `docs/Extractor/global_eurostat/raw/wage-YYYYMMDD.json`
- `docs/Extractor/global_eurostat/raw/wage-YYYYMMDD.jsonl`

### 執行萃取

萃取流程由頂層 Claude CLI 編排，逐行處理 JSONL 檔案。

### 執行 update

```bash
./update.sh
```

功能：
- 寫入 Qdrant 向量資料庫（by source_url 去重）
- 檢查 `[REVIEW_NEEDED]` 標記
- 產生統計報告

## API 文件

- **API 端點**: https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/
- **官方文件**: https://ec.europa.eu/eurostat/web/json-and-unicode-web-services
- **資料瀏覽器**: https://ec.europa.eu/eurostat/databrowser/
- **JSON-stat 格式**: https://json-stat.org/

## JSON-stat 格式說明

Eurostat 使用 JSON-stat 標準格式，結構如下：

```json
{
  "version": "2.0",
  "class": "dataset",
  "dimension": {
    "time": {
      "category": {
        "index": {"2024M01": 0, "2024M02": 1, ...}
      }
    },
    "geo": {
      "category": {
        "index": {"EU27_2020": 0},
        "label": {"EU27_2020": "European Union - 27 countries (from 2020)"}
      }
    }
  },
  "value": [6.5, 6.4, ...],
  "id": ["time", "geo"]
}
```

fetch.sh 會將此格式展開為 JSONL（每個時間點一筆記錄）。

## 已知限制

1. **API 請求限制**: 單次查詢資料點數有上限，建議分批查詢
2. **資料延遲**: 月度資料延遲 1-2 個月，年度資料延遲 6-12 個月
3. **部分資料集需額外參數**: 如年齡、性別等 dimension

## 相關資源

- [Eurostat Labour Market Statistics](https://ec.europa.eu/eurostat/web/labour-market/overview)
- [Data Navigation Tree](https://ec.europa.eu/eurostat/data/database)
- [Metadata](https://ec.europa.eu/eurostat/cache/metadata/en/employ_esms.htm)

## 建立日期

2026-02-08
