# global_arbeitnow Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | global_arbeitnow / Arbeitnow 歐洲職缺 |
| **Engineering function** | 從 Arbeitnow API 擷取歐洲地區職缺資訊 |
| **Collectable data** | 歐洲（主要德國、荷蘭等國）的職缺資訊，包含職位名稱、公司、地點、遠端選項、標籤等結構化資料 |
| **Automation level** | 95% — REST API 提供結構化 JSON 資料，無需解析 HTML 或非結構化內容 |
| **Output value** | 提供歐洲市場職缺即時資料，支援跨國人才流動分析與技能需求趨勢追蹤 |
| **Risk type** | 資料來源為單一第三方 API，可能受限於該平台的資料完整性與即時性 |
| **Reviewer persona** | 資料可信度審核員 |
| **Category enum** | tech, design, product, marketing, support, finance, hr, operations, other（見下方詳細定義） |
| **WebFetch 策略** | 不使用 — API 已提供完整結構化資料，無需額外抓取頁面 |

---

## 執行指令

### 資料來源

- **API endpoint**: https://www.arbeitnow.com/api/job-board-api
- **資料格式**: JSON
- **分頁支援**: `?page=1`（每頁 100 筆）
- **免費使用**: 是
- **文件**: https://www.arbeitnow.com/api/job-board-api

### 萃取邏輯

讀取 `docs/Extractor/global_arbeitnow/raw/*.jsonl` 中的每一行 JSON，執行以下處理：

1. **必要欄位驗證**
   - `title`（職位名稱）
   - `company_name`（公司名稱）
   - `location`（地點）
   - `slug`（職缺 ID，用於產生 URL）

2. **Category 判定**
   - 依據 `title` 和 `tags` 欄位進行關鍵字匹配
   - 優先使用 `title`，其次參考 `tags`
   - 預設為 `other`

3. **Markdown 產出**
   - 檔案名稱: `{slug}.md`（使用 API 提供的 slug）
   - 檔案位置: `docs/Extractor/global_arbeitnow/{category}/{slug}.md`

---

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下英文值，不可自行新增。**

| 英文 Key | 中文名稱 | 判定條件（不區分大小寫） |
|----------|----------|--------------------------|
| `tech` | 科技資訊 | title 或 tags 包含: software, engineer, developer, iOS, Android, backend, frontend, full-stack, DevOps, data |
| `design` | 設計創意 | title 或 tags 包含: design, UI, UX, graphic, visual |
| `product` | 產品管理 | title 或 tags 包含: product, manager, PM |
| `marketing` | 行銷業務 | title 或 tags 包含: marketing, sales, SEO, content, growth |
| `support` | 客戶服務 | title 或 tags 包含: support, customer, solution, specialist |
| `finance` | 財務會計 | title 或 tags 包含: finance, accounting, controller |
| `hr` | 人力資源 | title 或 tags 包含: HR, recruiting, people, talent |
| `operations` | 營運管理 | title 或 tags 包含: operations, admin, coordinator |
| `other` | 其他 | 不符合上述任何條件 |

---

## WebFetch 補充規則

**策略：不使用**

Arbeitnow API 已提供完整結構化資料，包含：
- 職位名稱、公司、地點
- 遠端選項、職位描述
- 公司 Logo URL
- 標籤與分類

無需透過 WebFetch 補充資訊。

---

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的情況

以下情況**必須**在 .md 檔開頭加上 `[REVIEW_NEEDED]`：

1. **title 為空或無法解析** — 職位名稱為必要欄位
2. **company_name 為空或無法解析** — 公司名稱為必要欄位

### 不觸發的情況

以下情況**不觸發** `[REVIEW_NEEDED]`：

- ❌ `remote = false` — 這是正常資料，非遠端職缺亦為有效資訊
- ❌ `tags` 為空陣列 — 並非所有職缺都有標籤，不影響資料有效性
- ❌ `description` 過短 — 部分職缺僅提供簡短描述，屬於來源資料特性

---

## 輸出格式

```markdown
---
title: {title}
company: {company_name}
location: {location}
remote: {remote: true/false}
posted_at: {created_at}
source_url: {url}
category: {category}
tags: {tags 陣列轉為逗號分隔字串}
fetched_at: {ISO8601 時間戳}
source_layer: global_arbeitnow
---

# {title}

## 職位資訊

- **公司**: {company_name}
- **地點**: {location}
- **遠端選項**: {remote ? "是" : "否"}
- **發布時間**: {created_at}
- **職位網址**: {url}

## 職位描述

{description}

## 標籤

{tags 陣列，若為空則顯示「無」}

---

**擷取時間**: {fetched_at}
**資料來源**: Arbeitnow API
**原始 Slug**: {slug}
```

---

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] **必要欄位完整** — title, company_name, location, slug 都存在
- [ ] **Category 使用預定義值** — 只使用 tech, design, product, marketing, support, finance, hr, operations, other
- [ ] **URL 格式正確** — source_url 為有效的完整 URL
- [ ] **remote 為布林值** — true 或 false
- [ ] **檔案命名正確** — 使用 `{slug}.md`
- [ ] **REVIEW_NEEDED 正確標記** — 僅在 title 或 company_name 為空時標記
- [ ] **時間格式統一** — fetched_at 使用 ISO8601 格式
- [ ] **tags 格式正確** — 若為陣列，轉為逗號分隔字串；若為空，顯示「無」

---

## 備註

- Arbeitnow 主要收錄歐洲職缺，尤其是德國、荷蘭等國
- API 免費使用，但請注意合理請求頻率（建議每頁間隔 1 秒）
- 職缺資料會隨時更新，建議每日執行 fetch
- 若需要新增 category 值，必須與使用者確認後更新本 CLAUDE.md
