# global_remoteok Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_remoteok / RemoteOK 遠端職缺 |
| **Engineering function** | 從 RemoteOK API 擷取全球遠端職缺資訊 |
| **Collectable data** | REST API (https://remoteok.com/api)，免費公開，JSON 格式，涵蓋職位名稱、公司、薪資、技能標籤、地區限制等結構化資料 |
| **Automation level** | 95% — REST API 提供完整結構化資料，唯一需要人工介入的是判定 category 邏輯不明確的職缺（如 tags 為空或過於泛化） |
| **Output value** | 全球遠端職缺即時資料，涵蓋軟體工程、產品管理、設計、行銷等職類，可用於技能趨勢分析、薪資水平追蹤、遠端工作市場洞察 |
| **Risk type** | 資料時效性（職缺可能已關閉但 API 未更新）、分類模糊（部分職缺 tags 不明確） |
| **Reviewer persona** | 資料可信度審核員、邏輯一致性審核員 |
| **Category enum** | tech / design / product / marketing / support / finance / hr / operations / other（詳見下方分類規則） |
| **WebFetch 策略** | 不使用（API 已提供完整資料，包含 description、tags、salary 等欄位） |

---

## 執行指令

### 萃取邏輯

每行 JSONL 代表一筆職缺，必須萃取以下欄位並轉換為 Markdown：

1. **基礎資訊**：position（職位名稱）、company（公司名稱）、company_logo（公司 Logo URL）
2. **職缺細節**：description（職位描述，HTML 格式）、tags（技能標籤陣列）、location（地區限制，若為空則為 "Worldwide"）
3. **薪資與福利**：salary（薪資範圍，可能為空）、apply_url（應徵連結）
4. **時間戳**：epoch（發布時間，Unix timestamp，需轉換為 ISO 8601）

### 輸出格式

```markdown
---
id: {id}
title: {position}
company: {company}
category: {category}
date: {發布日期 ISO 8601}
location: {location 或 "Worldwide"}
salary: {salary 或 "未公開"}
tags: [{tag1}, {tag2}, ...]
source_url: https://remoteok.com/remote-jobs/{slug}
fetched_at: {擷取時間 ISO 8601}
confidence: 高
---

# {position} @ {company}

## 職位描述

{description 的 Markdown 轉換版本}

## 技能要求

{從 tags 陣列中提取，以列表呈現}

## 應徵資訊

- **應徵連結**: {apply_url}
- **地區限制**: {location 或 "全球遠端"}
- **薪資範圍**: {salary 或 "未公開"}

## 資料來源

- **來源**: RemoteOK API
- **擷取時間**: {fetched_at}
- **原始 ID**: {id}

## 備註

{若有任何萃取異常或資料缺失，在此說明}
```

---

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下九個值之一，不可自行新增。**

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `tech` | 科技資訊 | tags 或 position 包含：software, engineer, developer, devops, data, AI, ML, backend, frontend, fullstack, cloud, security, QA, testing |
| `design` | 設計創意 | tags 或 position 包含：design, UI, UX, graphic, visual, web design, product design |
| `product` | 產品管理 | tags 或 position 包含：product, manager, owner, PM, product lead |
| `marketing` | 行銷業務 | tags 或 position 包含：marketing, sales, growth, SEO, SEM, content, social media, brand |
| `support` | 客戶服務 | tags 或 position 包含：support, customer, success, service, help desk |
| `finance` | 財務會計 | tags 或 position 包含：finance, accounting, payroll, CFO, financial analyst |
| `hr` | 人力資源 | tags 或 position 包含：HR, recruiting, people, talent, recruiter |
| `operations` | 營運管理 | tags 或 position 包含：operations, admin, executive, COO, project manager, scrum master |
| `other` | 其他 | 無法歸類於以上八類，或 tags 為空 / 過於泛化 |

**判定邏輯**：
1. 優先檢查 `tags` 陣列，若無則檢查 `position` 欄位
2. 若同時符合多個 category，依據優先序：tech > product > design > marketing > support > operations > finance > hr > other
3. 若完全無法判定（如 tags 和 position 都為空），分類為 `other` 並標記 `[REVIEW_NEEDED]`

---

## WebFetch 補充規則

**策略：不使用**

RemoteOK API 已提供完整的結構化資料，包含 description（HTML 格式）、tags、salary、apply_url 等欄位。無需透過 WebFetch 補充資料。

---

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的情況

1. **position 或 company 為空** — 核心欄位缺失，無法產生有效職缺資訊
2. **tags 為空且 position 無法判定 category** — 無法正確分類，需人工確認
3. **description 包含非 HTML 格式的異常內容** — 如明顯的垃圾資料或格式錯誤

### 不觸發的情況

- ❌ **salary 為空** — 部分職缺本就不公開薪資，這是常態，直接標註「未公開」即可
- ❌ **location 為空** — 表示「全球遠端」，不影響資料品質
- ❌ **company_logo 為空** — 非關鍵欄位，不影響職缺本身的有效性

---

## 輸出位置

萃取結果依 category 分類儲存：

```
docs/Extractor/global_remoteok/
├── tech/
├── design/
├── product/
├── marketing/
├── support/
├── finance/
├── hr/
├── operations/
└── other/
```

檔案命名格式：`{id}-{slug}.md`

---

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] **資料完整性**：position、company、apply_url、epoch 必填欄位是否齊全？
- [ ] **分類正確性**：category 是否符合 enum 定義，且判定邏輯清晰？
- [ ] **時間格式**：epoch 是否正確轉換為 ISO 8601 格式？
- [ ] **HTML 轉換**：description 是否正確轉換為 Markdown，無殘留 HTML 標籤？
- [ ] **標記一致性**：是否遵循 `[REVIEW_NEEDED]` 觸發規則，未過度標記？
- [ ] **檔案命名**：是否使用 `{id}-{slug}.md` 格式，且符合檔案系統規範（無特殊字元）？

---

## 資料來源說明

- **API Endpoint**: https://remoteok.com/api
- **文件**: https://remoteok.com/api
- **更新頻率**: 即時（API 回傳當前所有公開職缺）
- **資料量**: 約 1000+ 筆職缺（視市場狀況浮動）
- **費用**: 免費公開 API（需遵守 User-Agent 規範）

---

## 備註

1. RemoteOK API 的第一筆回應是 API 條款說明（`{"legal": ...}`），fetch.sh 已自動跳過
2. 若職缺已關閉但仍出現在 API 中，目前無法自動判定，依賴人工審核時發現
3. description 欄位為 HTML 格式，萃取時需轉換為 Markdown 以保持一致性
