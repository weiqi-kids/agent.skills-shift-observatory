# Layer: global_abs

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_abs / 澳洲統計局勞動力調查 |
| **Engineering function** | 從澳洲統計局（ABS）API 擷取就業統計數據 |
| **Collectable data** | 勞動力統計、就業人數、失業率、勞動參與率 |
| **Data source** | Australian Bureau of Statistics (ABS) Data API |
| **Automation level** | 90% — 官方 REST API，結構化 SDMX-JSON 格式 |
| **Output value** | 澳洲勞動市場趨勢，亞太區域對比參考 |
| **Risk type** | API 結構變更、SDMX 格式解析複雜度 |
| **Reviewer persona** | 資料可信度審核員 |

## 資料來源

- **API 端點**: https://api.data.abs.gov.au/data
- **資料格式**: SDMX-JSON
- **認證需求**: 無需 API key
- **更新頻率**: 每月（勞動力調查）
- **涵蓋範圍**: 澳洲全國及各州/領地

## 主要資料流

| Dataflow ID | 說明 | 更新頻率 |
|-------------|------|----------|
| ABS,LF,1.0.0 | 勞動力調查 | 月度 |

## 分類規則（Category Enum）

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `labour_force` | 勞動力統計 | 勞動力人數、勞動參與率 |
| `employment` | 就業數據 | 就業人數、就業率 |
| `unemployment` | 失業數據 | 失業人數、失業率 |

## WebFetch 策略：不使用

ABS API 直接提供結構化的 SDMX-JSON 數據。

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記
1. 無法判定 category
2. 數值異常（空或非數值）
3. API 結構變更

### 不觸發
- 季節性波動
- 部分州數據缺失

## 自我審核 Checklist

- [ ] category 值為預定義 enum
- [ ] 觀測期間明確標示
- [ ] source_url 可追溯
