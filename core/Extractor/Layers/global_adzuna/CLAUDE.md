# global_adzuna Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | global_adzuna / 全球職缺與薪資趨勢觀測 |
| **Engineering function** | 從 Adzuna API 擷取全球多國職缺資料與薪資統計，提供跨國勞動市場比較基準 |
| **Collectable data** | 職缺刊登資訊、薪資統計、市場趨勢、技能需求、地區差異 |
| **Data source** | Adzuna API (https://api.adzuna.com/) |
| **API 文件** | https://developer.adzuna.com/docs/search |
| **Automation level** | 90% — REST API 結構化資料，偶爾需確認職業分類對應 |
| **Output value** | 提供全球勞動市場基準資料，支援跨國薪資比較、技能需求變化分析、產業分層觀測 |
| **Risk type** | API 限額管理（每日 5000 requests）、不同國家資料完整度差異、薪資幣別轉換 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

### 輸入格式

每個 JSONL 行是一筆 Adzuna API 回傳的職缺或統計資料，由 fetch.sh 轉換後產生：

#### 職缺資料

```json
{
  "id": "1234567890",
  "title": "Software Engineer",
  "company": "Tech Corp",
  "location": "London",
  "country": "gb",
  "salary_min": 50000,
  "salary_max": 80000,
  "currency": "GBP",
  "description": "Job description...",
  "category": "IT Jobs",
  "contract_type": "permanent",
  "url": "https://www.adzuna.co.uk/details/...",
  "created": "2026-01-28T10:30:00Z",
  "fetched_at": "2026-01-28T10:35:00Z",
  "source": "adzuna_api",
  "data_type": "job_posting"
}
```

#### 薪資統計資料

```json
{
  "country": "gb",
  "occupation": "software engineer",
  "salary_median": 55000,
  "salary_10th_percentile": 40000,
  "salary_90th_percentile": 90000,
  "currency": "GBP",
  "sample_size": 1523,
  "date": "2026-01",
  "fetched_at": "2026-01-28T10:35:00Z",
  "source": "adzuna_api",
  "data_type": "salary_stats"
}
```

### 萃取邏輯

讀取 `docs/Extractor/global_adzuna/raw/` 下的 JSONL 檔案，逐行處理每筆資料：

#### 1. 資料類型判定

根據 `data_type` 欄位判定資料類型：
- `job_posting` → 職缺刊登資料
- `salary_stats` → 薪資統計資料
- `market_trend` → 市場趨勢分析（未來擴充）

#### 2. 欄位映射

##### 職缺資料 (job_posting)

| 輸出欄位 | 來源欄位 | 處理邏輯 |
|----------|----------|----------|
| `title` | `title` | 直接使用 |
| `company` | `company` | 若為空則標註「未提供」 |
| `location` | `location` + `country` | 合併為「{location}, {country_code}」 |
| `salary_min` | `salary_min` | 轉換為整數（USD 等值） |
| `salary_max` | `salary_max` | 轉換為整數（USD 等值） |
| `currency` | `currency` | 直接使用 |
| `description` | `description` | 直接使用 |
| `source_url` | `url` | 直接使用 |

##### 薪資統計資料 (salary_stats)

| 輸出欄位 | 來源欄位 | 處理邏輯 |
|----------|----------|----------|
| `country` | `country` | 直接使用 |
| `occupation` | `occupation` | 直接使用 |
| `salary_median` | `salary_median` | 轉換為整數 |
| `salary_10th` | `salary_10th_percentile` | 轉換為整數 |
| `salary_90th` | `salary_90th_percentile` | 轉換為整數 |
| `currency` | `currency` | 直接使用 |
| `sample_size` | `sample_size` | 樣本數（用於評估 confidence） |

#### 3. 分類判定

根據 `data_type` 和職業類型判定 category：
- 優先使用 API 的 `category` 欄位對應
- 若無，依據職缺標題關鍵字判定
- 薪資統計資料依 `occupation` 欄位判定

#### 4. 技能標籤萃取（僅 job_posting）

從 `description` 欄位識別技能關鍵字：
- 技術技能 (technical_skills): 程式語言、工具、框架、證照等
- 軟實力 (soft_skills): Leadership, Communication, Problem-solving 等

#### 5. 幣別轉換

所有薪資統一轉換為 USD 等值（使用 2026-01 匯率）：
- GBP → USD: 1.27
- EUR → USD: 1.10
- AUD → USD: 0.66
- 其他幣別保留原值並在 notes 標註

## 分類規則 (Category Enum)

**嚴格限制: category 只能使用以下定義的英文值，不可自行新增。**

| 英文 Key | 中文 | 判定條件 |
|----------|------|----------|
| job_posting | 職缺刊登 | data_type == "job_posting" |
| salary_stats | 薪資統計 | data_type == "salary_stats" |
| market_trend | 市場趨勢 | data_type == "market_trend"（未來擴充） |

## WebFetch 補充規則

### WebFetch 策略: 不使用

Adzuna API 已回傳完整結構化資料，包含：
- `title` — 職缺名稱
- `company` — 公司名稱
- `description` — 完整工作描述
- `salary_min` / `salary_max` — 薪資範圍
- `location` — 工作地點
- `category` — 職業分類

無需額外抓取網頁補充資訊。

### API 端點說明

#### 職缺搜尋 (Job Search)

```
GET https://api.adzuna.com/v1/api/jobs/{country}/search/{page}
```

**必要參數**:
- `app_id`: 應用程式 ID（從環境變數 ADZUNA_APP_ID 取得）
- `app_key`: 應用程式 Key（從環境變數 ADZUNA_APP_KEY 取得）

**可選參數**:
- `what`: 搜尋關鍵字（職業名稱）
- `where`: 地點
- `results_per_page`: 每頁結果數（預設 50，最多 50）
- `sort_by`: 排序方式（date, salary, relevance）
- `max_days_old`: 僅顯示 N 天內的職缺

**支援國家代碼**: us, gb, au, de, fr, ca, nl, nz, at, be, br, ch, es, in, it, mx, pl, ru, sg, za

#### 薪資統計 (Salary History)

```
GET https://api.adzuna.com/v1/api/jobs/{country}/history
```

**必要參數**:
- `app_id`: 應用程式 ID
- `app_key`: 應用程式 Key

**可選參數**:
- `location0`: 地區
- `location1`: 城市
- `category`: 職業分類
- `months`: 回溯月份數（預設 6）

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`:

1. **category 無法判定** — data_type 欄位缺失或無法對應到定義的 enum
2. **薪資範圍異常** — salary_min > salary_max（且兩者皆非 0）
3. **必要欄位缺失** — job_posting: title 或 id 為空；salary_stats: country 或 occupation 為空
4. **幣別無法轉換** — 遇到未定義的幣別且無法取得匯率
5. **API 回應異常** — 回傳的 JSON 結構與預期不符

### 以下情況**不觸發** `[REVIEW_NEEDED]`:

- ❌ 僅單一來源（這是此 Layer 的結構性限制，在 confidence 欄位反映）
- ❌ 薪資欄位為 0 或未提供（部分職缺不公開薪資）
- ❌ company 欄位為空（部分職缺不顯示公司名稱）
- ❌ description 欄位簡短（部分職缺僅提供摘要）
- ❌ sample_size 較小（< 100）但 > 0（在 confidence 欄位反映）

## 輸出格式

每筆資料萃取為一個 Markdown 檔案，依 category 存放。

### 檔案命名規則

#### 職缺資料 (job_posting)

```
{country}_{job_id}_{yyyymmdd}.md
```

範例: `gb_1234567890_20260128.md`

#### 薪資統計資料 (salary_stats)

```
{country}_{occupation_slug}_{yyyymm}.md
```

範例: `gb_software-engineer_202601.md`

### Markdown 模板 (job_posting)

```markdown
---
title: "{職缺標題}"
company: "{公司名稱}"
location: "{地點}, {國家代碼}"
country: "{國家代碼}"
category: "job_posting"
salary_min: {最低年薪 (USD 等值)}
salary_max: {最高年薪 (USD 等值)}
salary_min_local: {最低年薪 (當地幣別)}
salary_max_local: {最高年薪 (當地幣別)}
currency: "{幣別}"
contract_type: "{permanent/contract/part_time}"
published_date: "{YYYY-MM-DD}"
source_url: "{Adzuna 職缺連結}"
source_layer: "global_adzuna"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
technical_skills: ["{技能1}", "{技能2}", ...]
soft_skills: ["{軟實力1}", "{軟實力2}", ...]
ai_displacement_vector: "{cognitive_routine/cognitive_nonroutine/physical_routine/physical_nonroutine/interpersonal}"
confidence: "{high/medium/low}"
notes: "{備註 (若有)}"
---

# {職缺標題}

## 基本資訊
- **公司**: {company}
- **地點**: {location}
- **薪資**: {salary_min_local} ~ {salary_max_local} {currency}/年（約 {salary_min} ~ {salary_max} USD）
- **合約類型**: {contract_type}
- **發布日期**: {published_date}

## 工作描述
{完整工作描述 (來自 API description 欄位)}

## 技能需求
### 技術技能
{technical_skills 清單}

### 軟實力
{soft_skills 清單}

## AI 取代風險評估
- **AI 取代向量**: {ai_displacement_vector}
- **評估依據**: {根據職務內容判定，說明為何屬於該向量}

## 資料來源
- [查看原始職缺]({source_url})
- 資料擷取時間: {fetched_at}
- 國家: {country}
```

### Markdown 模板 (salary_stats)

```markdown
---
title: "{職業名稱} 薪資統計 - {國家代碼} ({YYYY-MM})"
country: "{國家代碼}"
occupation: "{職業名稱}"
category: "salary_stats"
salary_median: {中位數 (USD 等值)}
salary_10th: {第 10 百分位數 (USD 等值)}
salary_90th: {第 90 百分位數 (USD 等值)}
salary_median_local: {中位數 (當地幣別)}
salary_10th_local: {第 10 百分位數 (當地幣別)}
salary_90th_local: {第 90 百分位數 (當地幣別)}
currency: "{幣別}"
sample_size: {樣本數}
date: "{YYYY-MM}"
source_layer: "global_adzuna"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
confidence: "{high/medium/low}"
notes: "{備註 (若有)}"
---

# {職業名稱} 薪資統計

## 基本資訊
- **國家**: {country}
- **職業**: {occupation}
- **統計期間**: {date}
- **樣本數**: {sample_size}

## 薪資分布
- **中位數**: {salary_median_local} {currency}/年（約 {salary_median} USD）
- **第 10 百分位數**: {salary_10th_local} {currency}/年（約 {salary_10th} USD）
- **第 90 百分位數**: {salary_90th_local} {currency}/年（約 {salary_90th} USD）

## 數據品質
- **樣本數**: {sample_size}
- **信心程度**: {confidence}
- **備註**: {notes}

## 資料來源
- 資料來源: Adzuna API (Salary History)
- 資料擷取時間: {fetched_at}
```

## 自我審核 Checklist

輸出前必須逐項確認:

- [ ] **category 值合法** — 必須是 category enum 中定義的英文值之一
- [ ] **必要欄位完整** — job_posting: title, id, country; salary_stats: country, occupation
- [ ] **source_url 有效** — 格式正確且為 adzuna.com 或 adzuna.co.* 網域
- [ ] **薪資邏輯正確** — 若有 salary_min 與 salary_max（皆非 0），必須 min ≤ max
- [ ] **幣別轉換正確** — USD 等值已正確計算，若無法轉換則標註在 notes
- [ ] **技能標籤有依據** — technical_skills 與 soft_skills 必須來自 description 欄位
- [ ] **AI 取代向量合理** — 依據職務內容判定，並在正文說明依據
- [ ] **無幻覺內容** — 所有欄位內容皆來自 API 原始資料，無憑空生成
- [ ] **confidence 合理** — 依據 sample_size 和資料完整度評估
  - job_posting: 有完整 description + salary → high；缺少部分欄位 → medium
  - salary_stats: sample_size > 500 → high; 100-500 → medium; < 100 → low
- [ ] **notes 欄位適當使用** — 有異常狀況時必須說明

**若任一項未通過，必須在檔案開頭加上 `[REVIEW_NEEDED]` 標記。**
