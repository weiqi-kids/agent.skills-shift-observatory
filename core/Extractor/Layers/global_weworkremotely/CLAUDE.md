# global_weworkremotely Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_weworkremotely / WeWorkRemotely 遠端職缺 |
| **Engineering function** | 從 WeWorkRemotely RSS 擷取全球遠端職缺資訊 |
| **Collectable data** | 遠端職缺標題、公司、職位類型、技能需求、地區、國家、發布日期、職缺連結 |
| **Automation level** | 90% — RSS 提供結構化資料，欄位豐富且格式穩定 |
| **Output value** | 全球遠端職缺情報，可用於技能趨勢分析、地區需求分析、職位類型分布 |
| **Risk type** | 低風險 — 純資料擷取與結構化，無需複雜判斷 |
| **Reviewer persona** | 資料可信度審核員 |
| **Category enum** | programming, design, marketing, support, copywriting, devops, management, product, other |
| **WebFetch 策略** | 不使用（RSS 已提供完整職缺描述） |

## 執行指令

### 萃取邏輯

從 WeWorkRemotely RSS (https://weworkremotely.com/remote-jobs.rss) 擷取職缺資訊，萃取以下結構化欄位：

- **title**: 職缺標題（含公司名稱）
- **link**: 職缺詳細頁面連結
- **pubDate**: 發布日期
- **region**: 地區（如 US Only, Europe, Anywhere 等）
- **country**: 國家（可能為空）
- **skills**: 技能需求（逗號分隔）
- **category**: WeWorkRemotely 原始分類
- **type**: 職位類型（Full-Time, Contract 等）
- **description**: 職缺描述（HTML 格式）

### 輸出格式

每筆職缺萃取為一個獨立的 Markdown 檔案，檔名格式：`{sanitized_title}_{timestamp}.md`

## 分類規則（Category Enum）

**嚴格限制：category 只能使用以下定義的英文值，不可自行新增。**

| 英文值 | 中文名稱 | 判定條件 |
|--------|----------|----------|
| `programming` | 程式開發 | WeWorkRemotely category 包含 "Programming", "Software", "Back-End", "Front-End", "Full-Stack" |
| `design` | 設計創意 | WeWorkRemotely category 包含 "Design" |
| `marketing` | 行銷業務 | WeWorkRemotely category 包含 "Marketing", "Sales" |
| `support` | 客戶服務 | WeWorkRemotely category 包含 "Customer Support", "Customer Success" |
| `copywriting` | 文案寫作 | WeWorkRemotely category 包含 "Copywriting", "Content" |
| `devops` | DevOps/SRE | WeWorkRemotely category 包含 "DevOps", "Sysadmin" |
| `management` | 管理職 | WeWorkRemotely category 包含 "Management", "Finance", "Executive" |
| `product` | 產品管理 | WeWorkRemotely category 包含 "Product" |
| `other` | 其他 | WeWorkRemotely category 為 "All Other Remote" 或無法歸類 |

## WebFetch 補充規則

### 策略：不使用

WeWorkRemotely RSS 已提供完整的職缺描述（HTML 格式），包含公司介紹、職位要求、應徵方式等，無需額外抓取原始頁面。

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的情況

1. **title 為空** — 職缺標題缺失，無法識別
2. **無法判定 category** — 無法對應到預定義的分類值
3. **link 格式異常** — 不是有效的 URL 格式

### 不觸發的情況

- ❌ **country 為空** — 許多全球職缺不限國家，這是正常情況
- ❌ **skills 為空** — 部分職缺未列出技能標籤，應在 notes 註記即可
- ❌ **description 包含 HTML** — 這是 RSS 提供的原始格式，正常現象

## 輸出格式模板

```markdown
---
source_url: {link}
fetched_at: {ISO 8601 timestamp}
title: {職缺標題}
company: {公司名稱（從 title 萃取）}
category: {category enum 值}
region: {地區}
country: {國家（可能為空）}
skills: {技能需求（陣列）}
type: {職位類型}
published_date: {發布日期}
---

# {職缺標題}

## 基本資訊

- **公司**: {公司名稱}
- **職位類型**: {type}
- **地區**: {region}
- **國家**: {country 或 "不限"}
- **發布日期**: {published_date}

## 技能需求

{將 skills 欄位轉換為條列式}

## 職缺描述

{description 內容（保留 HTML 或轉為 Markdown）}

## 應徵連結

{link}

---

**資料來源**: WeWorkRemotely RSS
**擷取時間**: {fetched_at}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] title 不為空
- [ ] link 是有效的 URL
- [ ] category 使用預定義的 enum 值（不可自創）
- [ ] 無法歸類時標記 `[REVIEW_NEEDED]`
- [ ] country 為空時不觸發 REVIEW_NEEDED
- [ ] 公司名稱正確從 title 萃取（格式通常為 "公司名: 職位名稱"）
- [ ] skills 正確解析為陣列（若為空則註記）
- [ ] published_date 格式為 ISO 8601 或人類可讀格式
- [ ] 輸出檔案格式符合模板
