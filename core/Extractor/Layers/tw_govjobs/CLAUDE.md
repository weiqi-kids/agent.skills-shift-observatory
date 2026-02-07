# tw_govjobs Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | tw_govjobs / 台灣就業通職缺觀測 |
| **Engineering function** | 從台灣就業通 Open API 擷取政府就業服務平台職缺,補充104未覆蓋的傳統產業與公部門職缺 |
| **Collectable data** | 職缺資訊、薪資、地區、產業類別、工作內容、資格條件 |
| **Data source** | 台灣就業通 Open API (https://free.taiwanjobs.gov.tw/webservice_taipei/Webservice.ashx) |
| **API 文件** | https://free.taiwanjobs.gov.tw/webservice_taipei/A17000000J-030144-Taiwanjobs-OpenData.pdf |
| **Automation level** | 95% — API 結構化資料，無需 WebFetch |
| **Output value** | 補足民間求職平台未覆蓋的公部門與傳統產業職缺資訊,完整化勞動市場觀測 |
| **Risk type** | API 欄位可能變動、薪資欄位常為「面議」、職缺分類標準與104不一致 |
| **Reviewer persona** | 資料可信度審核員 |

## 執行指令

### 輸入格式

每個 JSONL 行是一筆台灣就業通 API 回傳的職缺資料，由 fetch.sh 轉換後產生：

```json
{
  "title": "職缺名稱",
  "company": "公司名稱",
  "salary_low": 30000,
  "salary_high": 40000,
  "salary_desc": "30,000~40,000元",
  "city": "台北市",
  "description": "工作內容描述",
  "job_category1": "職業分類1",
  "job_category2": "職業分類2",
  "experience": "經驗要求",
  "education": "學歷要求",
  "job_no": "職缺編號",
  "link": "https://job.taiwanjobs.gov.tw/...",
  "modify_date": "更新日期",
  "fetched_at": "2026-01-28T10:30:00Z",
  "source": "taiwanjobs_api"
}
```

### 萃取邏輯

讀取 `docs/Extractor/tw_govjobs/raw/` 下的 JSONL 檔案,逐行處理每筆職缺資料:

1. **欄位映射**
   | 輸出欄位 | 來源欄位 | 處理邏輯 |
   |----------|----------|----------|
   | `title` | `title` | 直接使用 |
   | `company` | `company` | 直接使用 |
   | `location` | `city` | 直接使用 |
   | `salary_min` | `salary_low` | 轉換為整數 |
   | `salary_max` | `salary_high` | 轉換為整數 |
   | `salary_desc` | `salary_desc` | 直接使用 |
   | `description` | `description` | 直接使用 |
   | `source_url` | `link` | 直接使用 |

2. **分類判定**
   - 優先使用 `job_category1` / `job_category2` 欄位判定
   - 若分類欄位為空，依據職缺標題判定
   - 必須使用 category enum 中定義的英文值
   - 判定優先序：
     1. API 提供的職業分類欄位
     2. 職缺標題關鍵字（如「護理師」→ healthcare）
     3. 工作內容關鍵字

3. **技能標籤萃取**
   - 從 `description` 欄位識別技能關鍵字
   - 技術技能 (technical_skills): 軟體工具、程式語言、專業證照等
   - 軟實力 (soft_skills): 溝通能力、團隊合作、領導能力等

## 分類規則 (Category Enum)

**嚴格限制: category 只能使用以下定義的英文值,不可自行新增。**

| 英文 Key | 中文 | 判定條件 |
|----------|------|----------|
| tech | 科技資訊 | 軟體開發、IT、資訊安全、系統管理、網路工程等 |
| finance | 金融財務 | 銀行、保險、會計、審計、財務分析、稅務等 |
| legal | 法務智財 | 法律顧問、智慧財產、合規、契約管理等 |
| healthcare | 醫療照護 | 醫師、護理師、藥師、醫療技術、長照等 |
| education | 教育研究 | 教師、教保員、研究助理、學術行政等 |
| construction | 營造工程 | 土木、建築、工地管理、測量、工程監造等 |
| manufacturing | 製造生產 | 生產線、品管、製程工程、工廠管理等 |
| retail_service | 零售服務 | 門市、餐飲、客服、美容美髮、旅遊服務等 |
| logistics | 物流運輸 | 倉儲、配送、司機、快遞、供應鏈管理等 |
| creative | 創意設計 | 平面設計、UI/UX、影視製作、編輯、行銷企劃等 |
| care | 社會照顧 | 社工、早療、身障服務、社區營造等 |
| professional | 專業服務 | 人資、行政、總務、採購、專案管理等 |
| agriculture | 農林漁牧 | 農業技術、漁業、畜牧、林業、農產加工等 |
| public_service | 公務行政 | 政府機關約聘僱、公務機關行政支援等 |
| management | 經營管理 | 中高階主管、營運管理、策略規劃等 |
| skilled_trade | 技術工 | 水電、冷氣、機械維修、裝潢、師傅等 |

## WebFetch 補充規則

### WebFetch 策略: 不使用

台灣就業通 Open API 已回傳完整結構化資料，包含：
- `OCCU_DESC` — 職缺名稱
- `COMPNAME` — 公司名稱
- `NT_L` / `NT_U` — 薪資下限/上限
- `CITYNAME` — 工作地點
- `JOB_DETAIL` — 工作內容
- `CJOB_NAME1` / `CJOB_NAME2` — 職業分類
- `EXPERIENCE` — 經驗要求
- `EDGRDESC` — 學歷要求

無需額外抓取網頁補充資訊。

### API 參數說明

| 參數 | 說明 |
|------|------|
| `count` | 回傳筆數（最多 1000） |
| `zipno` | 郵遞區號（3 碼，可選） |
| `jobno` | 通俗職業代碼（可選） |

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`:

1. **category 無法判定** — 職缺標題過於籠統 (如「工讀生」) 且 `job_category1`/`job_category2` 欄位也無法判定
2. **category 判定衝突** — 職缺內容同時符合多個 category 且無明確主要職能 (如「行政兼會計兼客服」)
3. **薪資範圍異常** — salary_low > salary_high（且兩者皆非 0）
4. **必要欄位缺失** — title、company、job_no 任一為空
5. **API 結構變動** — 回傳 XML 格式與預期不符

### 以下情況**不觸發** `[REVIEW_NEEDED]`:

- ❌ 僅單一來源 (這是此 Layer 的結構性限制,在 confidence 欄位反映)
- ❌ 薪資欄位為 0 或「面議」(公部門職缺常見)
- ❌ description 欄位為空 (部分職缺不提供)
- ❌ 職缺已過期 (仍保留作為歷史資料)
- ❌ experience/education 欄位為空 (部分職缺未標示)

## 輸出格式

每筆職缺萃取為一個 Markdown 檔案,檔名格式: `{job_id}_{yyyymmdd}.md`

### Markdown 模板

```markdown
---
title: "{職缺標題}"
company: "{公司/機關名稱}"
location: "{工作地點}"
category: "{category_enum_value}"
salary_min: {最低月薪 (整數, 單位:元)}
salary_max: {最高月薪 (整數, 單位:元)}
published_date: "{YYYY-MM-DD}"
source_url: "{原始職缺網址}"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
technical_skills: ["{技能1}", "{技能2}", ...]
soft_skills: ["{軟實力1}", "{軟實力2}", ...]
confidence: "{high/medium/low}"
notes: "{備註 (若有)}"
---

# {職缺標題}

## 基本資訊
- **公司/機關**: {company}
- **地點**: {location}
- **薪資**: {salary_min} ~ {salary_max} 元/月 (若為空則標註「面議」)
- **類別**: {category 的中文對應}
- **發布日期**: {published_date}

## 工作內容
{完整工作內容描述 (來自 WebFetch)}

## 資格條件
{資格條件清單 (來自 WebFetch)}

## 福利待遇
{福利待遇說明 (來自 WebFetch, 若無則標註「未提供」)}

## 技能標籤
### 技術技能
{technical_skills 清單}

### 軟實力
{soft_skills 清單}

## 資料來源
- [查看原始職缺]({source_url})
- 資料擷取時間: {fetched_at}
```

## 自我審核 Checklist

輸出前必須逐項確認:

- [ ] **category 值合法** — 必須是 category enum 中定義的英文值之一
- [ ] **必要欄位完整** — title, company, job_no, category, fetched_at 皆不為空
- [ ] **source_url 有效** — 格式正確且為 taiwanjobs.gov.tw 網域
- [ ] **薪資邏輯正確** — 若有 salary_min 與 salary_max（皆非 0）,必須 min ≤ max
- [ ] **category 判定有依據** — 能從 job_category1/job_category2 或職缺標題找到支持該分類的關鍵字
- [ ] **技能標籤有依據** — technical_skills 與 soft_skills 必須來自 description 欄位
- [ ] **無幻覺內容** — 所有欄位內容皆來自 API 原始資料,無憑空生成
- [ ] **confidence 合理** — 依據資料完整度評估 (政府 API 結構化資料可信度高 → high；欄位缺失較多 → medium)
- [ ] **notes 欄位適當使用** — 有異常狀況時必須說明

**若任一項未通過,必須在檔案開頭加上 `[REVIEW_NEEDED]` 標記。**
