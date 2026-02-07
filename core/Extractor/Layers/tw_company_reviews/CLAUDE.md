# tw_company_reviews Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | tw_company_reviews / 求職天眼通公司評論 |
| **Engineering function** | 從求職天眼通擷取公司評論與面試經驗,提供企業文化與員工觀感的質化資料 |
| **Collectable data** | 公司評價、面試經驗、薪資回報、工作環境描述、管理風格、福利制度評價 |
| **Automation level** | 60% — 需 WebFetch,非結構化文本需 AI 萃取情感與重點,評論主觀性需人工判讀 |
| **Output value** | 提供求職者視角的質化資訊,補充官方職缺資料未涵蓋的企業文化與工作環境真實狀況 |
| **Risk type** | 評論主觀性高、樣本偏差 (多為離職者或不滿者)、網站反爬機制、匿名評論無法驗證真偽 |
| **Reviewer persona** | 使用者誤導風險審核員 |

## 執行指令

### 萃取邏輯

讀取 `docs/Extractor/tw_company_reviews/raw/` 下的 JSONL 檔案,逐行處理每筆評論資料:

1. **基本資訊萃取**
   - 公司名稱 (company_name)
   - 評論標題 (title)
   - 評論類別 (category: company_review/interview_experience/salary_report/work_environment)
   - 發布日期 (published_date)
   - 評分 (rating, 若有)
   - 來源網址 (source_url)

2. **WebFetch 補充**
   - 使用 source_url 抓取完整評論頁面
   - 萃取完整評論內容 (content)
   - 萃取評論者背景 (reviewer_background: 如在職/離職、職位、年資等)
   - 萃取評論時間與地點 (若有)

3. **內容分析**
   - **情感分析** (sentiment): positive/neutral/negative
   - **關鍵主題萃取** (key_topics): 從評論中識別主要討論主題
     - 薪資福利 (compensation)
     - 工作環境 (work_environment)
     - 管理風格 (management_style)
     - 職涯發展 (career_development)
     - 工作生活平衡 (work_life_balance)
     - 公司文化 (company_culture)
   - **重點摘要** (summary): 1-2 句話概括評論重點 (必須基於原文,不可憑空生成)

4. **可信度評估**
   - 評論具體性 (是否有具體事例,而非空泛抱怨)
   - 評論平衡性 (是否同時提及優缺點)
   - 評論者背景完整度 (是否提供職位、年資等資訊)
   - 綜合評估 confidence: high/medium/low

5. **降級處理**
   - 若 WebFetch 失敗,僅基於 JSONL 原始資料萃取 (通常只有標題與評分)
   - 在 notes 欄位標註 "WebFetch 失敗,無完整評論內容"
   - 標記 `[REVIEW_NEEDED]`

## 分類規則 (Category Enum)

**嚴格限制: category 只能使用以下定義的英文值,不可自行新增。**

| 英文 Key | 中文 | 判定條件 |
|----------|------|----------|
| company_review | 公司評價 | 綜合性評論,涵蓋公司整體印象、推薦度等 |
| interview_experience | 面試經驗 | 描述面試流程、面試題目、面試官態度等 |
| salary_report | 薪資回報 | 主要內容為薪資數字、調薪幅度、獎金制度等 |
| work_environment | 工作環境 | 聚焦於辦公環境、工作氛圍、團隊互動等 |

**判定規則:**
- 優先依據評論標題或網站分類標籤判定
- 若無明確標籤,依據內容主要篇幅判定
- 若內容涵蓋多個面向但無明顯主題,優先歸類為 `company_review`

## WebFetch 補充規則

### WebFetch 策略: 必用

求職天眼通無提供 API,評論清單頁面通常僅顯示:
- 評論標題
- 評分 (星級)
- 發布日期

必須透過 WebFetch 抓取完整評論頁面才能取得:
- 完整評論內容
- 評論者背景 (職位、年資、在職/離職狀態)
- 詳細評分項目 (薪資福利、工作環境、管理制度等子項)
- 其他使用者的回應或認同數

### WebFetch 執行流程

1. 從 JSONL 的 `link` 或 `url` 欄位取得評論網址
2. 使用 WebFetch 工具抓取該網址內容
3. 解析 HTML 結構,萃取目標欄位
4. 對評論內容進行情感分析與主題萃取
5. 若 WebFetch 失敗 (timeout、403、驗證碼、網站結構變動等),執行降級處理

### 降級處理

WebFetch 失敗時:
1. 僅基於 JSONL 原始資料萃取 (通常只有標題、公司名稱、評分)
2. 在 `notes` 欄位標註: "⚠️ WebFetch 失敗,無完整評論內容。可能原因: 網站反爬 / 需登入 / 結構變動。"
3. sentiment 與 key_topics 標註為 "無法判定"
4. **必須標記 `[REVIEW_NEEDED]`** (評論內容為核心價值,缺失即失去意義)

### 反爬應對

求職天眼通可能有以下反爬機制:
- 需登入才能查看完整評論
- Cloudflare 或驗證碼驗證
- User-Agent 檢查
- 請求頻率限制

fetch.sh 應包含:
- 適當的 User-Agent 與 Headers
- 請求間隔 (3-5 秒)
- 錯誤重試機制 (最多 3 次)
- 若持續失敗,記錄到日誌並跳過該筆

## `[REVIEW_NEEDED]` 觸發規則

### 以下情況**必須**標記 `[REVIEW_NEEDED]`:

1. **WebFetch 失敗** — 無法取得完整評論內容
2. **情感分析衝突** — AI 萃取的 sentiment 與評論明確陳述矛盾 (如評論說「非常推薦」但 sentiment 被標為 negative)
3. **公司名稱無法驗證** — 評論中提及的公司名稱與已知企業名單不符 (拼音錯誤、暱稱等)
4. **必要欄位缺失** — company_name、source_url、category 任一為空
5. **source_url 無效** — 網址格式錯誤或非 qollie.com 網域
6. **極端評論** — 全篇情緒化字眼 (如「垃圾公司」「血汗工廠」) 且無具體事例,可能為惡意攻擊

### 以下情況**不觸發** `[REVIEW_NEEDED]`:

- ❌ 評論主觀 (這是此 Layer 的本質,在 notes 或 confidence 欄位說明)
- ❌ 僅單一評論者觀點 (這是結構性限制,在 confidence 欄位標註 low)
- ❌ 樣本偏差 (多為離職者) — 這是平台特性,不影響個別評論的萃取正確性
- ❌ reviewer_background 欄位為空 (部分評論者不提供背景)
- ❌ rating 欄位為空 (部分評論僅文字無評分)
- ❌ key_topics 僅有 1-2 項 (短評正常現象)

## 輸出格式

每筆評論萃取為一個 Markdown 檔案,檔名格式: `{company_slug}_{review_id}_{yyyymmdd}.md`

### Markdown 模板

```markdown
---
company_name: "{公司名稱}"
title: "{評論標題}"
category: "{category_enum_value}"
rating: {整體評分 (1-5, 若無則為 null)}
published_date: "{YYYY-MM-DD}"
source_url: "{原始評論網址}"
fetched_at: "{YYYY-MM-DD HH:mm:ss}"
reviewer_background:
  status: "{在職/離職/其他}"
  position: "{職位 (若有)}"
  tenure: "{年資 (若有)}"
sentiment: "{positive/neutral/negative}"
key_topics: ["{topic1}", "{topic2}", ...]
confidence: "{high/medium/low}"
notes: "{備註 (若有)}"
---

# {評論標題}

## 基本資訊
- **公司**: {company_name}
- **評論類別**: {category 的中文對應}
- **整體評分**: {rating} / 5 (若無則標註「未提供」)
- **發布日期**: {published_date}
- **評論者背景**: {status} | {position} | 年資 {tenure}

## 評論內容
{完整評論內容 (來自 WebFetch, 保持原文)}

## 內容分析
### 情感傾向
{sentiment 的中文對應: 正面/中性/負面}

### 關鍵主題
{key_topics 清單, 附註各主題在評論中的具體內容摘要}

### 重點摘要
{1-2 句話概括評論重點, 必須基於原文}

## 可信度評估
**Confidence: {confidence}**

評估依據:
- 具體性: {是否有具體事例 (高/中/低)}
- 平衡性: {是否同時提及優缺點 (是/否)}
- 背景完整度: {評論者是否提供職位、年資等資訊 (完整/部分/缺失)}
- 樣本限制: 單一評論者觀點, 可能存在個人偏見或特殊情境

## 資料來源
- [查看原始評論]({source_url})
- 資料擷取時間: {fetched_at}

---

**⚠️ 使用提醒**
- 本評論為匿名網路評論, 無法驗證真偽
- 評論內容代表評論者個人觀點, 不代表企業整體狀況
- 建議搭配多筆評論與官方資訊交叉參考
- 評論平台可能存在樣本偏差 (離職者、不滿者比例較高)
```

## 自我審核 Checklist

輸出前必須逐項確認:

- [ ] **category 值合法** — 必須是 category enum 中定義的英文值之一
- [ ] **必要欄位完整** — company_name, title, source_url, category, fetched_at 皆不為空
- [ ] **source_url 有效** — 格式正確且為 qollie.com 網域
- [ ] **sentiment 有依據** — 若標註為 positive/negative, 必須能從評論內容找到支持證據
- [ ] **key_topics 有依據** — 所有 topics 必須在評論中被明確提及
- [ ] **summary 基於原文** — 重點摘要不可包含評論中未出現的資訊
- [ ] **無情感衝突** — sentiment 與評論明確陳述 (如「推薦」「不推薦」) 不矛盾
- [ ] **WebFetch 狀態正確** — 若失敗, 已標記 `[REVIEW_NEEDED]` 並在 notes 說明
- [ ] **confidence 合理** — 依據具體性、平衡性、背景完整度評估
- [ ] **notes 欄位適當使用** — 有異常狀況 (如 WebFetch 失敗、評論疑似惡意) 時必須說明
- [ ] **包含使用提醒** — 每筆評論必須附上風險提醒 (匿名評論、無法驗證、樣本偏差)
- [ ] **無過度推論** — 不可從單一評論推導該公司的整體狀況 (如「此公司普遍...」)

**若任一項未通過, 必須在檔案開頭加上 `[REVIEW_NEEDED]` 標記。**

---

## 倫理與法律注意事項

1. **匿名評論限制** — 所有評論皆為匿名, 無法驗證真偽, 必須在輸出中明確標註
2. **誹謗風險** — 若評論包含明顯誹謗性言論 (指名道姓攻擊個人、無依據的違法指控), 應標記 `[REVIEW_NEEDED]` 並在 notes 註明法律風險
3. **樣本偏差揭露** — 必須在每筆評論說明「評論平台可能存在樣本偏差」
4. **不做整體推論** — 從個別評論萃取資訊時, 不可推論該公司的整體狀況
5. **隱私保護** — 若評論中出現真實姓名、員工編號等個人識別資訊, 應遮蔽處理
