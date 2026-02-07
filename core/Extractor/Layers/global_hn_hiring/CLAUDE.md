# global_hn_hiring Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_hn_hiring / HackerNews 徵才帖 |
| **Engineering function** | 從 HackerNews 月度 "Who is hiring" 帖子擷取科技業職缺 |
| **Collectable data** | HN Algolia API (https://hn.algolia.com/api/v1/) — 每月第一個工作日發布的 "Ask HN: Who is hiring?" 帖子 |
| **Automation level** | 70% — API 擷取全自動，但職缺內容為非結構化文字，需 AI 解析公司名、職位、技能、薪資等欄位 |
| **Output value** | 北美科技業即時職缺，薪資透明度高（約 50% 揭露薪資範圍），反映矽谷與遠端工作市場趨勢 |
| **Risk type** | 資料來源結構性限制 — 單一來源，無法交叉驗證；部分留言格式不規則 |
| **Reviewer persona** | 自動化邊界審核員 — 關注 AI 解析非結構化文字的邊界 |
| **Category enum** | backend, frontend, fullstack, mobile, devops, data, security, management, other |
| **WebFetch 策略** | 不使用 — HN Algolia API 已提供完整留言內容 |

---

## 執行指令

對每筆 JSONL（HN 留言），萃取以下欄位並產出 Markdown：

### 必萃欄位

| 欄位 | 說明 | 範例 |
|------|------|------|
| `hn_id` | HN 留言 ID | 42345678 |
| `company` | 公司名稱 | Anthropic |
| `positions` | 職位清單（逗號分隔） | Backend Engineer, ML Engineer |
| `location` | 地點 | San Francisco, CA / Remote |
| `category` | 職位類別（單一，見分類規則） | backend |
| `remote_friendly` | 是否遠端友善 | true / false |
| `visa_sponsorship` | 是否贊助簽證 | true / false / unknown |
| `salary_range` | 薪資範圍（若有） | $150k - $200k |
| `tech_stack` | 技術棧（逗號分隔） | Python, Rust, PostgreSQL |
| `date` | 留言發布時間（ISO 8601） | 2025-01-01T12:00:00Z |
| `source_url` | HN 留言連結 | https://news.ycombinator.com/item?id=42345678 |
| `fetched_at` | 擷取時間（ISO 8601） | 2025-01-15T08:00:00Z |
| `confidence` | 萃取信心度 | 高 / 中 / 低 |
| `notes` | 萃取備註（若有異常） | 無法判定主要職位，已分類為 other |

### 解析邏輯

HN "Who is hiring" 帖子的留言格式通常為：

```
<公司名> | <職位> | <地點> | <遠端資訊> | <薪資>

<詳細描述...>
<技術棧...>
<申請方式...>
```

**解析規則：**
1. 公司名通常在第一行開頭
2. 職位可能有多個（如 "Backend / Frontend / ML Engineer"）
3. 地點可能為城市或 "Remote" 或 "Remote (US only)"
4. 薪資格式多樣（如 "$150k-200k", "$150-200k", "150k-200k USD"）
5. 技術棧通常在描述段落中
6. Visa 資訊常見關鍵字：H1B, visa sponsorship, no sponsorship required

**信心度判定：**
- 高：公司名、主要職位、地點皆可明確識別
- 中：缺少薪資或部分欄位，但核心資訊完整
- 低：格式不規則，需要大量推測

---

## 分類規則（enum）

Category 只能使用以下固定值，不可自行新增。

| 英文值 | 中文 | 判定條件 |
|--------|------|----------|
| `backend` | 後端工程 | 關鍵字：backend, server, API, Go, Rust, Python, Java, Scala, Elixir |
| `frontend` | 前端工程 | 關鍵字：frontend, React, Vue, Angular, TypeScript, JavaScript, CSS |
| `fullstack` | 全端工程 | 明確標註 fullstack / full-stack / full stack |
| `mobile` | 行動開發 | 關鍵字：iOS, Android, mobile, React Native, Flutter, Swift, Kotlin |
| `devops` | DevOps/SRE | 關鍵字：DevOps, SRE, infrastructure, Kubernetes, Docker, AWS, GCP, Terraform |
| `data` | 資料工程 | 關鍵字：data engineer, data scientist, ML, AI, machine learning, analytics |
| `security` | 資安工程 | 關鍵字：security, infosec, cybersecurity, penetration testing |
| `management` | 工程管理 | 關鍵字：engineering manager, tech lead, CTO, VP Engineering |
| `other` | 其他 | 無法歸類或非工程職位（如 Designer, PM） |

**分類原則：**
- 若留言包含多個職位，取主要職位（通常為第一個）
- 若無法判定，使用 `other` 並在 `notes` 說明
- 嚴格限制：category 只能使用上述英文值，不可自行新增

---

## WebFetch 補充規則

**策略：不使用**

HN Algolia API 已提供完整留言內容（包含 HTML 格式的文字），無需額外 WebFetch。

---

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記 `[REVIEW_NEEDED]` 的場景

1. **無法解析公司名稱** — 留言格式過於不規則，無法識別公司名
2. **無法解析主要職位** — 留言未明確列出職位名稱
3. **信心度為「低」** — 大量欄位需要推測

### 不觸發 `[REVIEW_NEEDED]` 的場景

- 薪資未揭露（HN 約 50% 揭露薪資，這是資料來源的結構性限制，在 `confidence` 欄位反映即可）
- Visa 資訊不明確（標記為 `unknown` 即可）
- 技術棧不完整（基於可見資訊萃取即可）

---

## 輸出格式

### 檔案命名

```
docs/Extractor/global_hn_hiring/{category}/hn-{hn_id}.md
```

範例：`docs/Extractor/global_hn_hiring/backend/hn-42345678.md`

### Markdown 模板

```markdown
---
hn_id: {hn_id}
company: {company}
positions: {positions}
location: {location}
category: {category}
remote_friendly: {true/false}
visa_sponsorship: {true/false/unknown}
salary_range: {salary_range 或空}
tech_stack: {tech_stack}
date: {date}
source_url: {source_url}
fetched_at: {fetched_at}
confidence: {高/中/低}
notes: {notes 或空}
---

# {company} - {positions}

## 職位資訊

- 職位：{positions}
- 地點：{location}
- 遠端：{remote_friendly}
- 簽證：{visa_sponsorship}
- 薪資：{salary_range}
- 技術：{tech_stack}

## 原始內容

{留言原文（HTML 轉 Markdown）}

## 來源

- HN 留言：{source_url}
- 發布時間：{date}
- 擷取時間：{fetched_at}
```

---

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] `hn_id` 正確對應來源 JSON
- [ ] `company` 和 `positions` 非空（若為空，標記 `[REVIEW_NEEDED]`）
- [ ] `category` 只使用定義的 enum 值
- [ ] `remote_friendly` 為 true/false（不可為空）
- [ ] `visa_sponsorship` 為 true/false/unknown（不可為空）
- [ ] `salary_range` 保留原始格式（如 "$150k-200k"），不轉換為數值
- [ ] `tech_stack` 為逗號分隔字串（不使用陣列）
- [ ] `date` 和 `fetched_at` 為 ISO 8601 格式
- [ ] `source_url` 為 `https://news.ycombinator.com/item?id={hn_id}`
- [ ] `confidence` 基於可識別欄位數量判定
- [ ] 原始內容完整保留（不截斷）
- [ ] 若觸發 `[REVIEW_NEEDED]`，在檔案開頭加上標記
- [ ] 檔案路徑符合 `docs/Extractor/global_hn_hiring/{category}/hn-{hn_id}.md`
