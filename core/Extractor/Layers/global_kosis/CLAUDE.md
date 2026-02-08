# global_kosis Layer 定義

> ⚠️ **此 Layer 已停用** — 詳見下方「停用原因」

---

## 停用原因（2026-02-08 確認）

### 問題

KOSIS Open API **僅限韓國居民使用**，國際用戶無法註冊取得 API Key。

### 驗證過程

1. 訪問 KOSIS API 申請頁面：https://kosis.kr/openapi/mypage/myApiKeyPage.do
2. 註冊流程要求以下韓國本地身份驗證方式（擇一）：
   - **韓國手機號碼** — 需接收驗證簡訊
   - **I-PIN** — 韓國網路身份認證系統，需韓國身分證
   - **公認認證書** — 韓國電子簽章，需韓國銀行帳戶
3. 無任何國際用戶註冊選項

### 結論

- **無法自動化**：無法取得 API Key
- **無替代方案**：KOSIS 不提供無需認證的公開資料端點
- **建議替代來源**：
  - **ILO ILOSTAT** — 包含韓國勞動統計（global_ilo_stats Layer）
  - **OECD.Stat** — 包含韓國經濟與就業數據（global_oecd_stats Layer）

### 重新評估時間

2027-02-01（若 KOSIS 開放國際 API 存取）

---

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | global_kosis / 韓國就業統計觀測 |
| **Engineering function** | 從韓國統計廳（KOSIS）Open API 擷取就業/失業統計數據，提供東亞勞動市場趨勢參考 |
| **Collectable data** | 經濟活動人口、就業率、失業率、勞動參與率、按產業/年齡/性別分類的就業人數 |
| **Data source** | Korea Statistical Information Service (KOSIS) Open API (https://kosis.kr/openapi/) |
| **API 文件** | https://kosis.kr/openapi/openApiIntro.do |
| **Automation level** | 95% — 官方 Open API 結構化資料，JSON 格式，無需 WebFetch |
| **Output value** | 提供東亞市場勞動趨勢對比、補充全球就業觀測的區域多樣性 |
| **Risk type** | API key 權限限制、月度資料可能延遲發布、韓文欄位需翻譯 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

### 輸入格式

每個 JSONL 行是一筆 KOSIS API 回傳的統計資料，由 fetch.sh 轉換後產生：

```json
{
  "stat_code": "DT_1DA7012S",
  "stat_name": "經濟活動人口調查",
  "period": "202412",
  "period_type": "M",
  "item_code": "T10",
  "item_name": "就業人數",
  "value": 28500000,
  "unit": "千人",
  "org_id": "101",
  "org_name": "統計廳",
  "obj_l1": "전국",
  "obj_l1_name": "全國",
  "fetched_at": "2026-02-08T10:30:00Z",
  "source": "kosis_api"
}
```

### 萃取邏輯

讀取 `docs/Extractor/global_kosis/raw/` 下的 JSONL 檔案，逐行處理每筆統計資料：

1. **欄位映射**

   | 輸出欄位 | 來源欄位 | 處理邏輯 |
   |----------|----------|----------|
   | `title` | `stat_name` + `item_name` | 組合為「{stat_name} - {item_name}」 |
   | `period` | `period` | 轉換為 YYYY-MM 或 YYYY-QQ 格式 |
   | `value` | `value` | 直接使用，保留原始數值 |
   | `unit` | `unit` | 直接使用（千人、%等） |
   | `category` | `item_code` | 依 item_code 映射到 category enum |
   | `region` | `obj_l1_name` | 直接使用（全國、首爾等） |
   | `source_url` | 固定格式 | `https://kosis.kr/statHtml/statHtml.do?orgId={org_id}&tblId={stat_code}` |

2. **分類判定**

   - 優先使用 `item_code` 欄位（KOSIS API 提供的標準分類碼）
   - 若 `item_code` 無法對應到 category enum，依據 `item_name` 關鍵字判定
   - 必須使用 category enum 中定義的英文值

3. **時間序列處理**

   - 同一統計項目（`stat_code` + `item_code`）的不同時期資料寫入同一 .md 檔
   - 檔案內容包含完整時間序列（表格或列表形式）

## 分類規則 (Category Enum)

**嚴格限制: category 只能使用以下定義的英文值，不可自行新增。**

| 英文 Key | 中文 | 判定條件 (item_code 或 item_name 關鍵字) |
|----------|------|------------------------------------------|
| employment_trend | 就業動向 | T10（就業人數）、T20（就業率）、含「就業」關鍵字 |
| unemployment_rate | 失業率 | T30（失業人數）、T40（失業率）、含「失業」關鍵字 |
| labour_participation | 勞動參與率 | T50（勞動參與率）、T60（經濟活動人口）、含「勞動參與」關鍵字 |

## WebFetch 補充規則

### WebFetch 策略: 不使用

KOSIS Open API 已回傳完整結構化資料，包含：

- 統計項目名稱（`stat_name`）
- 指標名稱（`item_name`）
- 數值（`value`）
- 單位（`unit`）
- 時期（`period`）
- 區域/分類（`obj_l1_name`）

無需額外抓取網頁補充資訊。

### API 參數說明

| 參數 | 說明 |
|------|------|
| `method` | 固定值 `getList` |
| `apiKey` | API key（需在 .env 設定 `KOSIS_API_KEY`） |
| `itmId` | 指標代碼（如 `T10+T20+T30`，使用 `+` 連接多個指標） |
| `objL1` | 分類層級 1（如 `ALL` 表示全部，或指定代碼） |
| `format` | 回傳格式（`json` 或 `xml`） |
| `jsonVD` | JSON 垂直顯示（`Y` 或 `N`） |
| `prdSe` | 時期類型（`M` 月、`Q` 季、`Y` 年） |
| `startPrdDe` | 起始時期（YYYYMM / YYYYQQ / YYYY） |
| `endPrdDe` | 結束時期（YYYYMM / YYYYQQ / YYYY） |
| `orgId` | 組織代碼（如 `101` 統計廳） |
| `tblId` | 統計表代碼（如 `DT_1DA7012S`） |

### 常用統計表代碼

| 統計表代碼 | 名稱 | 更新頻率 |
|------------|------|----------|
| `DT_1DA7012S` | 經濟活動人口調查（月度） | 月度 |
| `DT_1DA7102S` | 就業動向（月度） | 月度 |
| `DT_1DA7001S` | 經濟活動人口調查（年度） | 年度 |

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`:

1. **category 無法判定** — `item_code` 和 `item_name` 皆無法映射到 category enum
2. **數值範圍異常** — `value` 為負數（除非指標定義允許負值，如增長率）
3. **必要欄位缺失** — `stat_code`、`item_code`、`period`、`value` 任一為空
4. **API 結構變動** — 回傳 JSON 格式與預期不符
5. **時期格式錯誤** — `period` 欄位無法解析為 YYYY-MM 或 YYYY-QQ 格式

### 以下情況**不觸發** `[REVIEW_NEEDED]`:

- ❌ 僅單一來源（這是此 Layer 的結構性限制，在 confidence 欄位反映）
- ❌ `obj_l1_name` 為韓文（KOSIS API 原生語言，不需翻譯）
- ❌ `value` 為 0（部分統計項目合理為 0）
- ❌ `unit` 欄位不一致（不同統計表的單位本來就不同）
- ❌ 歷史資料（KOSIS 提供完整時間序列，舊資料仍有效）

## 輸出格式

每個統計項目萃取為一個 Markdown 檔案，檔名格式: `{stat_code}_{item_code}.md`

### Markdown 模板

```markdown
---
title: "{統計名稱} - {指標名稱}"
stat_code: "{統計表代碼}"
item_code: "{指標代碼}"
category: "{category_enum_value}"
region: "{區域名稱（如：全國、首爾）}"
org_name: "{發布機關}"
unit: "{單位（如：千人、%）}"
source_url: "{KOSIS 統計表連結}"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
confidence: "{high/medium/low}"
notes: "{備註（若有）}"
---

# {統計名稱} - {指標名稱}

## 基本資訊

- **統計代碼**: {stat_code}
- **指標代碼**: {item_code}
- **類別**: {category 的中文對應}
- **區域**: {region}
- **單位**: {unit}
- **發布機關**: {org_name}

## 最新資料

- **時期**: {最新時期（如：2024-12）}
- **數值**: {最新數值} {unit}

## 時間序列

| 時期 | 數值 ({unit}) |
|------|---------------|
| {YYYY-MM} | {value} |
| {YYYY-MM} | {value} |
| ... | ... |

（保留最近 24 個月或 8 個季度的資料）

## 資料來源

- [查看原始統計表]({source_url})
- 資料擷取時間: {fetched_at}

## 說明

{統計項目的定義與說明（若 API 提供）}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] **category 值合法** — 必須是 category enum 中定義的英文值之一
- [ ] **必要欄位完整** — stat_code, item_code, period, value, category, fetched_at 皆不為空
- [ ] **source_url 有效** — 格式正確且為 kosis.kr 網域
- [ ] **時期格式正確** — YYYY-MM（月度）或 YYYY-QQ（季度）格式
- [ ] **category 判定有依據** — 能從 item_code 或 item_name 找到支持該分類的依據
- [ ] **時間序列排序正確** — 由舊到新排列
- [ ] **無幻覺內容** — 所有欄位內容皆來自 API 原始資料，無憑空生成
- [ ] **confidence 合理** — 政府官方統計資料可信度高 → high；若有欄位缺失 → medium
- [ ] **notes 欄位適當使用** — 有異常狀況時必須說明

**若任一項未通過，必須在檔案開頭加上 `[REVIEW_NEEDED]` 標記。**
