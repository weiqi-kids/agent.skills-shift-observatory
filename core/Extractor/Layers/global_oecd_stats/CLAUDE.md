# global_oecd_stats Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_oecd_stats / OECD 勞動統計 |
| **Engineering function** | 從 OECD.Stat SDMX-JSON API 擷取 OECD 成員國勞動市場統計 |
| **Collectable data** | 失業率、就業率、勞動參與率（按國家、性別、年齡分組） |
| **Data source** | OECD.Stat API (https://stats.oecd.org/SDMX-JSON/) |
| **API 文件** | https://data.oecd.org/api/ |
| **Automation level** | 95% — 官方 SDMX-JSON API，結構化資料，無需 WebFetch |
| **Output value** | OECD 成員國勞動市場數據，與 ILO 資料交叉比對，提供已開發國家趨勢 |
| **Risk type** | API 結構變動、部分國家資料延遲發布 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

### 輸入格式

每個 JSONL 行是一筆 OECD 統計資料：

```json
{
  "dataset": "LFS_SEXAGE_I_R",
  "indicator": "UNE_RATE",
  "indicator_name": "Unemployment rate",
  "category": "unemployment_rate",
  "country": "KOR",
  "country_name": "South Korea",
  "time_period": "2024",
  "value": 2.8,
  "unit": "%",
  "age_group": "Y15T64",
  "sex": "Total",
  "fetched_at": "2026-02-08T10:00:00Z",
  "source": "oecd_stat"
}
```

### 資料範圍

- **涵蓋國家**：KOR, JPN, USA, DEU, GBR, FRA, CAN, AUS（8 個主要經濟體）
- **年齡組**：Y15T64（15-64 歲勞動人口）
- **性別**：Total（不分性別）
- **時間範圍**：1960 年至今（依 OECD 資料可用性）

### 萃取邏輯

1. 解析 JSON 欄位
2. 依 indicator 分類到對應 category
3. 產生結構化 Markdown

## 分類規則（Category Enum）

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `unemployment_rate` | 失業率 | indicator = UNE_RATE |
| `employment_rate` | 就業率 | indicator = EMP_RATIO |
| `participation_rate` | 勞動參與率 | indicator = LF_RATE |

**嚴格限制：category 只能使用上述英文值，不可自行新增。**

## WebFetch 補充規則

### 策略：不使用

OECD SDMX-JSON API 提供完整結構化數據。

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的場景

1. **JSON 結構異常** — 回傳格式與預期不符
2. **國家代碼無效** — country 非 ISO 3166-1 alpha-3 代碼
3. **指標無法分類** — indicator 不在 category enum 中

### 不觸發的場景

- ❌ 數據延遲（OECD 資料發布有時滯）
- ❌ 特定國家缺失（並非所有國家都有全部指標）
- ❌ 數值為 null（部分時期無資料）

## 輸出格式

```markdown
---
source_layer: global_oecd_stats
category: {category_enum_value}
indicator: {指標代碼}
indicator_name: {指標名稱}
country: {國家代碼}
country_name: {國家名稱}
time_period: {YYYY 或 YYYY-QQ}
value: {數值}
fetched_at: {YYYY-MM-DD HH:MM:SS}
source_url: https://stats.oecd.org/
confidence: 高
---

# {指標名稱} — {國家名稱} ({time_period})

## 數據摘要

- **指標**：{indicator_name}
- **國家**：{country_name} ({country})
- **時期**：{time_period}
- **數值**：{value}%

## 資料來源

- **來源**：OECD.Stat
- **資料集**：{dataset}
- **擷取時間**：{fetched_at}
```

## 自我審核 Checklist

- [ ] category 為定義的 3 個 enum 值之一
- [ ] country 為有效 ISO 3166-1 alpha-3 代碼
- [ ] time_period 格式正確（YYYY 或 YYYY-QQ）
- [ ] value 為數值或 null
- [ ] 無幻覺內容
- [ ] 若無法分類已標記 `[REVIEW_NEEDED]`
