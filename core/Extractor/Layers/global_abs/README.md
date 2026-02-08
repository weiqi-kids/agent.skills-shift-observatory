# global_abs Layer

## 概述

從 Australia Bureau of Statistics (ABS) Labour Force API 擷取澳洲就業統計資料。

## 資料來源

- **API 端點**: https://data.api.abs.gov.au/rest/data/
- **資料格式**: SDMX-JSON
- **涵蓋範圍**: 1978年至今
- **更新頻率**: 每月
- **是否需要 API key**: 否
- **當前擷取範圍**: 最近 12 個月（可透過修改 fetch.sh 的 START_PERIOD/END_PERIOD 調整）

## 主要資料流

| Dataflow ID | 說明 |
|-------------|------|
| ABS,LF,1.0.0 | Labour Force Survey（勞動力調查） |

## 執行方式

### 1. 擷取資料

```bash
./fetch.sh
```

執行後會產生 `docs/Extractor/global_abs/raw/labour-force-{timestamp}.jsonl`

### 2. 萃取 Markdown

由系統頂層 Claude CLI 編排，逐行讀取 JSONL 並分派 Task 子代理處理。

### 3. 更新 Qdrant

```bash
./update.sh {md_files...}
```

或不帶參數（自動掃描所有 .md 檔）：

```bash
./update.sh
```

## Category 分類

| 英文 Key | 中文 | 說明 |
|----------|------|------|
| labour_force | 勞動力統計 | 勞動力人數、勞動力參與率 |
| employment | 就業數據 | 就業人數、就業率、全職/兼職 |
| unemployment | 失業數據 | 失業人數、失業率 |

## API 結構說明

ABS API 使用 SDMX-JSON 格式，結構複雜。主要欄位：

```json
{
  "data": {
    "structure": {
      "dimensions": [...],
      "attributes": [...]
    },
    "dataSets": [
      {
        "observations": {
          "0:0:0:0": [66.5],
          "0:0:0:1": [66.3],
          ...
        }
      }
    ]
  }
}
```

- `observations` 的 key 是維度組合（如 "0:0:0:0"）
- value 是數值陣列（第一個元素為觀測值）
- 需要透過 `structure.dimensions` 映射維度

## 已知問題

1. **SDMX 維度映射複雜**：當前 fetch.sh 採用簡化策略，只萃取觀測值，維度映射留給萃取階段處理
2. **資料量龐大**：完整資料流可能包含數萬筆觀測值，需要分批處理
3. **時間序列長**：1978年至今的資料，需注意檔案去重機制

## 自動化程度

100% — 官方 REST API，無需 API key，無需 WebFetch

## 備註

- API 無需 API key，可直接存取
- 回傳格式符合 SDMX 2.1 標準
- 建議使用 `dimensionAtObservation=AllDimensions` 取得所有維度的資料
