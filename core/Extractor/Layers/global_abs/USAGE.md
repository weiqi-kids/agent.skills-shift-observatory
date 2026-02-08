# global_abs Layer 使用說明

## 快速開始

### 1. 測試 API 連線

```bash
# 測試 API 是否可達
curl -s "https://data.api.abs.gov.au/rest/data/ABS,LF,1.0.0/all?dimensionAtObservation=AllDimensions&format=jsondata&startPeriod=2025-01&endPeriod=2025-12" \
  -H "Accept: application/vnd.sdmx.data+json" | jq -r 'keys'
```

預期輸出：
```json
[
  "data",
  "errors",
  "meta"
]
```

### 2. 執行 fetch.sh

```bash
cd /Users/lightman/weiqi.kids/agent.skills-shift-observatory/core/Extractor/Layers/global_abs
./fetch.sh
```

### 3. 檢查輸出

```bash
ls -lh docs/Extractor/global_abs/raw/
```

應該會看到 `labour-force-{timestamp}.jsonl` 檔案。

### 4. 檢視 JSONL 內容（前 3 行）

```bash
head -3 docs/Extractor/global_abs/raw/labour-force-*.jsonl | jq
```

## 調整擷取範圍

若要擷取不同時間範圍的資料，編輯 `fetch.sh`：

```bash
# 改為擷取 2020-2025 年的資料
START_PERIOD="2020-01"
END_PERIOD="2025-12"
```

## 已知限制

1. **SDMX 維度映射**：當前版本僅萃取 observation 的原始資料（dimension_keys + value），詳細的維度映射（如：指標名稱、地區、性別、年齡等）需要在萃取階段解析 `data.structures` 欄位。

2. **資料量**：完整資料流（1978年至今）可能包含數十萬筆觀測值，建議：
   - 首次執行限定 1 年範圍
   - 確認萃取流程正常後再擴大範圍

3. **API 限制**：目前未發現明確的 rate limiting，但建議避免頻繁請求。

## 進階用法

### 萃取特定指標

若要只萃取特定指標（如：失業率），需修改 API URL：

```bash
# 範例：只萃取失業率（需要知道該指標的 dimension key）
# 詳細的 dimension key 可透過 structure API 查詢
```

### 解析 SDMX structure

```bash
# 萃取 structure 資訊（用於映射維度）
curl -s "https://data.api.abs.gov.au/rest/data/ABS,LF,1.0.0/all?dimensionAtObservation=AllDimensions&format=jsondata&startPeriod=2025-01&endPeriod=2025-01" \
  -H "Accept: application/vnd.sdmx.data+json" | jq '.data.structures'
```

## 故障排除

### 問題 1: HTTP 301 重定向

**症狀**：curl 回傳 301 Moved Permanently

**原因**：舊的 API 端點（api.data.abs.gov.au）已重定向到新端點（data.api.abs.gov.au）

**解決**：使用 `-L` 參數讓 curl 自動跟隨重定向，或直接使用新端點

### 問題 2: HTTP 405 Method Not Allowed

**症狀**：使用 `curl -I`（HEAD 請求）時收到 405

**原因**：ABS API 不支援 HEAD 請求

**解決**：使用 GET 請求（`curl` 不帶 `-I` 參數）

### 問題 3: jq 解析失敗

**症狀**：`jq: parse error`

**原因**：API 回傳的 JSON 結構異常或網路問題導致不完整的回應

**解決**：
1. 檢查網路連線
2. 確認 API 狀態：https://www.abs.gov.au/
3. 查看原始回應：`cat raw/temp-*.json`

## 參考資源

- ABS API 文件：https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis
- SDMX 標準：https://sdmx.org/
- Labour Force Survey 說明：https://www.abs.gov.au/statistics/labour/labour-force-survey-australia
