# tw_104_jobs Layer Definition

## ⚠️ API 狀態說明

本 Layer 使用 104 網站的**非官方內部 API**，可能因以下原因失敗：
- IP 被暫時封鎖
- API 結構變動
- 請求頻率限制

**替代方案**：
1. 申請 104 官方開發者 API：https://developers.104.com.tw/
2. 使用 `tw_govjobs` Layer（台灣就業通 Open API）作為部分替代

執行前建議先測試：`./fetch.sh --test`

## Layer Definition Table

| 項目 | 說明 |
|------|------|
| **Layer name** | tw_104_jobs / 104人力銀行職缺觀測 |
| **Engineering function** | 從104人力銀行API擷取台灣職缺資料，追蹤53個職務角色的需求變化 |
| **Collectable data** | 職缺名稱、公司名稱、薪資區間、技能標籤、學歷經驗要求、應徵人數、工作地點 |
| **Data source** | 104 人力銀行內部 API（非官方） |
| **Automation level** | 90% — API 結構化資料，僅需分類判斷（前提：API 可用） |
| **Output value** | 台灣就業市場微觀數據，技能需求第一手資料 |
| **Risk type** | API 非官方可能變動、IP 封鎖風險、資料偏差（僅104平台用戶） |
| **Reviewer persona** | 資料可信度審核員 |

## Category Enum (16 Industry Sectors)

分類依據 roles.json 中定義的 search_role → sector 映射，**不基於職缺內容判斷**。

| Category Key | 中文名稱 | 對應角色 ID |
|--------------|----------|-------------|
| `tech` | 科技與資訊 | #1-5 (軟體工程師、AI工程師、資料分析師、資安工程師、QA工程師) |
| `finance` | 金融與保險 | #6-8 (財務分析師、精算師、銀行櫃員) |
| `legal` | 法律 | #9-10 (律師、法務助理) |
| `healthcare` | 醫療與健康 | #11-14 (醫師、護理師、藥師、營養師) |
| `education` | 教育 | #15-16 (教師、補習班老師) |
| `construction` | 建築與營造 | #17-19 (建築師、土木工程師、工地主任) |
| `manufacturing` | 製造 | #20-22 (機械工程師、作業員、品管工程師) |
| `retail_service` | 零售與服務 | #23-25 (門市人員、客服人員、餐飲服務人員) |
| `logistics` | 運輸與物流 | #26-27 (倉儲人員、貨運司機) |
| `creative` | 創意與媒體 | #28-30 (平面設計師、文案編輯、翻譯人員) |
| `care` | 照護 | #31-32 (照顧服務員、幼教老師) |
| `professional` | 專業服務 | #33-36 (會計師、人力資源管理、產品經理、房仲) |
| `agriculture` | 農業 | #37 (農業技術人員) |
| `public_service` | 公共服務 | #38-39 (行政人員、社工) |
| `management` | 管理層 | #49-53 (總經理、技術主管、財務主管、營運主管、人資主管) |
| `skilled_trade` | 藍領技術工 | #41-48 (水電技師、冷氣技師、汽車修護技師、廚師、美髮師、電焊技師、保全人員、清潔人員) |

**嚴格限制**：category 只能使用上述 16 個英文值，不可自行新增。需要新增時必須與使用者確認後寫入本文件。

## Extraction Logic

### 輸入格式

每個 JSONL 行是一筆 104 API 回傳的職缺資料，由 fetch.sh 注入以下欄位後產生：

```json
{
  "jobName": "...",
  "custName": "...",
  "salaryLow": "0",
  "salaryHigh": "0",
  "salaryDesc": "面議",
  "optionEdu": "大學",
  "periodDesc": "3年以上",
  "applyCnt": "5",
  "applyDesc": "0~5人應徵",
  "appearDate": "2026/01/28",
  "jobAddrNoDesc": "台北市",
  "jobAddress": "信義區...",
  "tags": ["Python", "SQL"],
  "link": {
    "job": "//www.104.com.tw/job/abcde",
    "cust": "..."
  },
  "lon": "...",
  "lat": "...",
  "_meta": {
    "search_role": "software_engineer",
    "sector": "tech",
    "fetch_timestamp": "2026-01-28T10:30:00+08:00"
  }
}
```

### 萃取欄位

| 輸出欄位 | 來源欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `jobName` | 直接使用 |
| `company` | `custName` | 直接使用 |
| `location` | `jobAddrNoDesc` + `jobAddress` | 組合為「{jobAddrNoDesc} {jobAddress}」 |
| `salary_low` | `salaryLow` | 轉換為整數（若為"0"則保持0） |
| `salary_high` | `salaryHigh` | 轉換為整數 |
| `salary_desc` | `salaryDesc` | 直接使用（如「月薪 40,000~50,000元」或「面議」） |
| `education` | `optionEdu` | 直接使用 |
| `experience` | `periodDesc` | 直接使用 |
| `apply_count` | `applyCnt` | 轉換為整數 |
| `tags` | `tags` | 陣列，直接使用 |
| `job_url` | `link.job` | 加上協議 `https:` + 原始值 |
| `appear_date` | `appearDate` | 轉換為 YYYY-MM-DD 格式 |
| `role_key` | `_meta.search_role` | 直接使用 |
| `category` | `_meta.sector` | 直接使用（由 roles.json 預先映射） |
| `fetched_at` | `_meta.fetch_timestamp` | 直接使用 |

### Category Assignment

**不需要判斷**。category 由 fetch.sh 根據 roles.json 中的 sector 欄位預先注入到 `_meta.sector`，萃取時直接使用。

### WebFetch Strategy

**不使用**。104 API 已回傳結構化資料，無需補充抓取原始頁面。

## `[REVIEW_NEEDED]` Trigger Rules

### 必須標記的情況

以下情況**必須**在 .md 檔開頭加上 `[REVIEW_NEEDED]`：

1. **薪資異常**：`salary_low > salary_high`（且兩者皆非 0）
2. **技能標籤異常**：`tags` 陣列為空 **且** `jobName` 包含無法識別的術語（非中文且非常見英文職稱）
3. **API 結構變動**：缺少預期欄位（jobName、custName、link.job 任一為空）

### 不觸發的情況

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ 單一來源限制（所有資料僅來自 104 平台）— 這是結構性限制，在 `confidence` 欄位反映
- ❌ 薪資為「面議」（`salaryDesc` = "面議" 且 `salary_low` = `salary_high` = 0）— 這是正常現象
- ❌ 應徵人數過少（`apply_count` < 5）— 這是正常的市場現象
- ❌ `tags` 陣列為空但 `jobName` 為常見職稱（如「行政助理」「會計」）— 某些傳統職務本就無特定技能標籤

## Output Format

每筆職缺產出一個 `.md` 檔案，檔名格式：`{YYYYMMDD}_{role_key}_{5_digit_hash}.md`

```markdown
---
title: "{jobName}"
source_url: "{job_url}"
source_layer: tw_104_jobs
category: "{sector}"
date: "{appear_date}"
fetched_at: "{fetch_timestamp}"
role_key: "{search_role}"
company: "{custName}"
location: "{jobAddrNoDesc} {jobAddress}"
salary_low: {number}
salary_high: {number}
salary_desc: "{salaryDesc}"
education: "{optionEdu}"
experience: "{periodDesc}"
apply_count: {number}
tags: [{comma_separated_tags}]
confidence: 高
severity: info
---

# {jobName} — {custName}

## 基本資訊

- **公司**：{custName}
- **地點**：{jobAddrNoDesc} {jobAddress}
- **薪資**：{salaryDesc}
- **學歷**：{optionEdu}
- **經驗**：{periodDesc}
- **應徵人數**：{applyCnt} 人
- **刊登日期**：{appearDate}

## 技能需求

{如果 tags 陣列非空，列出為 bullet list；若為空，寫「本職缺未標註特定技能需求」}

## 備註

{如果有以下情況，在此說明：}
- 薪資異常（salary_low > salary_high）
- 技能標籤異常
- 其他需要說明的項目

{如無異常，寫「無」或省略本節}
```

### 檔案路徑

產出位置：`docs/Extractor/tw_104_jobs/{category}/{filename}.md`

例如：
- `docs/Extractor/tw_104_jobs/tech/20260128_software_engineer_a3f9d.md`
- `docs/Extractor/tw_104_jobs/finance/20260128_financial_analyst_b2e7c.md`

### Frontmatter 欄位說明

| 欄位 | 型別 | 說明 |
|------|------|------|
| `title` | string | 職缺名稱 |
| `source_url` | string | 職缺連結（完整 URL） |
| `source_layer` | string | 固定值 `tw_104_jobs` |
| `category` | string | 16 個 enum 值之一 |
| `date` | string | 刊登日期（YYYY-MM-DD） |
| `fetched_at` | string | 擷取時間戳（ISO 8601） |
| `role_key` | string | 搜尋角色 key（如 `software_engineer`） |
| `company` | string | 公司名稱 |
| `location` | string | 工作地點 |
| `salary_low` | integer | 薪資下限（0 表示未提供） |
| `salary_high` | integer | 薪資上限 |
| `salary_desc` | string | 薪資描述（如「月薪 40,000~50,000元」） |
| `education` | string | 學歷要求 |
| `experience` | string | 經驗要求 |
| `apply_count` | integer | 應徵人數 |
| `tags` | array | 技能標籤 |
| `confidence` | string | 固定值「高」（API 結構化資料） |
| `severity` | string | 固定值「info」 |

## Self-Review Checklist

產出 .md 檔案前，必須逐項確認：

- [ ] `category` 是否為 16 個 enum 值之一？
- [ ] `source_url` 是否為有效的 104 職缺連結（https://www.104.com.tw/job/...）？
- [ ] `salary_low` ≤ `salary_high`（或兩者皆為 0）？
- [ ] `tags` 陣列是否正確萃取（若 JSON 中的 tags 為空陣列，Markdown 中也應為空）？
- [ ] `role_key` 是否與 `_meta.search_role` 一致？
- [ ] `date` 格式是否為 YYYY-MM-DD？
- [ ] `fetched_at` 格式是否為 ISO 8601？
- [ ] 檔名中的 `role_key` 是否與 frontmatter 一致？
- [ ] 若觸發 `[REVIEW_NEEDED]` 條件，是否已在檔案開頭加上標記？
- [ ] 若未觸發 `[REVIEW_NEEDED]` 條件，是否確實沒有加上標記？

## Notes

### Confidence 設定

本 Layer 的 `confidence` 固定為「高」，理由：
- 資料來自 104 官方 API，結構化程度高
- 萃取過程無推測成分（直接映射欄位）

**但這不代表資料本身無偏差**。104 平台僅反映該平台用戶的職缺，不代表全台就業市場全貌。此為結構性限制，不觸發 `[REVIEW_NEEDED]`。

### Severity 設定

本 Layer 的 `severity` 固定為「info」，因為：
- 職缺資訊本身無威脅等級
- 此為觀測性資料，非資安事件

### Deduplication Strategy

- 以 `source_url` 為主鍵去重（由 update.sh 執行）
- 若同一職缺在不同時間擷取，視為**不同版本**（刊登日期、應徵人數可能變動），保留兩版
- 若完全相同（同一筆資料重複擷取），跳過寫入

### Rate Limiting

fetch.sh 在每次 API 請求間隨機暫停 3-5 秒，避免被 104 封鎖。

### Error Handling

- API 回應非 200：記錄錯誤但不中斷流程，繼續處理下一個角色
- JSON 解析失敗：跳過該筆，記錄錯誤
- 必要欄位缺失：標記 `[REVIEW_NEEDED]` 並產出不完整的 .md 檔（便於事後檢查）
