# Extractor 角色定義與通用規則

## 角色概述

**Extractor**（資料萃取員）負責從外部資料源擷取原始資料，並透過萃取邏輯轉換為結構化的 Markdown 文件。

本系統的 Extractor 由以下元件組成：

- **fetch.sh** — 下載原始資料（RSS XML、API JSON 等）並轉換為 JSONL
- **萃取邏輯** — 由 Claude CLI 透過 Task tool 分派子代理執行，讀取 JSONL 逐行處理
- **update.sh** — 將萃取結果寫入 Qdrant 向量資料庫，並檢查 `[REVIEW_NEEDED]` 標記

---

## 通用規則（所有 Layer 必須遵守）

### 1. JSONL 處理規範

#### ⛔ 禁止行為

**禁止使用 Read 工具直接讀取 `.jsonl` 檔案**

JSONL 檔案可能數百 KB，直接讀取會超出 token 上限。

#### ✅ 正確流程

```bash
# 1. 取得總行數
wc -l < {jsonl_file}

# 2. 逐行讀取（N = 1, 2, 3, ...）
sed -n '{N}p' {jsonl_file}

# 3. 每行獨立交由一個 Task 子代理處理
# 4. 子代理透過 Write tool 寫出 .md 檔（不用 Bash heredoc）
```

#### 子代理接收格式

每個萃取 Task 接收：

- **單一 JSON 字串**（sed 取出的該行內容）
- **Layer CLAUDE.md 的萃取邏輯**（作為 Task prompt 的一部分）
- **core/Extractor/CLAUDE.md 的通用規則**（本文件）

#### 萃取前去重

在萃取前，應檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同 `source_url` 或 ID 的 `.md` 檔：

- 若存在且內容相同（同一筆資料重複擷取），**跳過**該筆
- 若存在但內容不同（同一來源的更新版本），依 Layer 策略決定**覆蓋**或**保留兩版**
- 去重檢查由頂層編排邏輯執行（在分派 Task 前），不由子代理自行判斷

---

### 2. WebFetch 補充機制

#### 2.1 通用原則

RSS 的 `description` 欄位資訊量有限。萃取 Task 可透過 WebFetch 工具抓取 JSON 中 `link` 欄位指向的原始公告頁面，以取得完整內容。

- 各 Layer 的 CLAUDE.md 定義該 Layer 的 WebFetch 使用策略
- WebFetch 失敗**不阻斷**萃取流程，應降級為僅基於 RSS 資料萃取
- 降級時需在 `notes` 欄位標註
- 依各 Layer 的 `[REVIEW_NEEDED]` 觸發規則判定是否標記

#### 2.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含 WebFetch 策略宣告：

| WebFetch 策略 | 說明 | 適用場景 |
|---------------|------|----------|
| **必用** | 一律使用 WebFetch 抓取原始頁面 | RSS description 幾乎無資訊 |
| **按需** | description 不足時才使用 | RSS description 有時完整有時不足 |
| **不使用** | 完全基於 RSS 資料萃取 | RSS 本身已包含完整結構化資料 |

按需策略的觸發條件（由各 Layer CLAUDE.md 定義），例如：

- description 內容不足 100 字
- 缺少特定關鍵欄位（職位、薪資、技能需求等）

#### 2.3 WebFetch 失敗處理

```
若 WebFetch 失敗：
  1. 降級為僅基於 RSS 資料萃取
  2. 在 notes 欄位標註：「WebFetch 失敗，僅基於 RSS description 萃取」
  3. 依 Layer 的 [REVIEW_NEEDED] 觸發規則判定是否標記
  4. 不阻斷萃取流程
```

---

### 3. `[REVIEW_NEEDED]` 標記規範

#### 3.1 統一原則

| 概念 | 含義 | 標記方式 |
|------|------|----------|
| `[REVIEW_NEEDED]` | 萃取結果**可能有誤**，需要人工確認 | 在 .md 檔開頭加上 |
| `confidence: 低` | 資料來源有**結構性限制**（如單一來源、無交叉驗證） | 在 confidence 欄位反映 |

> **兩者不等價。子任務不可自行擴大判定範圍。**

#### 3.2 Layer CLAUDE.md 必須宣告

每個 Layer 的 CLAUDE.md 必須包含明確的觸發規則表：

```markdown
### `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. {具體場景 1 — 萃取結果可能有誤}
2. {具體場景 2}
...

以下情況**不觸發** `[REVIEW_NEEDED]`：
- ❌ {場景 A — 這是結構性限制,應在 confidence 欄位反映}
- ❌ {場景 B}
...
```

#### 3.3 子任務合規

- 子任務必須**嚴格遵循** Layer CLAUDE.md 定義的觸發規則
- 不可因「僅單一來源、無交叉驗證」而自行標記 REVIEW_NEEDED
- 不可因「欄位為空」（資料來源本身不提供該欄位）而標記 REVIEW_NEEDED

#### 3.4 標記格式

在 .md 檔開頭第一行加上：

```markdown
[REVIEW_NEEDED]

---
title: ...
```

---

### 4. 輸出格式

所有萃取結果必須為 Markdown 格式，並包含 YAML frontmatter。

#### 4.1 必要欄位

```yaml
---
title: 標題（繁體中文或英文）
source_url: 原始資料來源 URL（必須唯一，用於去重）
source_layer: Layer 名稱（如：104_job_market）
category: 分類（必須為該 Layer CLAUDE.md 定義的 enum 值之一）
date: 資料日期（YYYY-MM-DD）
fetched_at: 擷取時間（YYYY-MM-DD HH:MM:SS）
confidence: 信心程度（高/中/低）
severity: 影響程度（高/中/低，若適用）
---
```

#### 4.2 confidence 欄位指引

| 信心程度 | 判定條件 |
|----------|----------|
| **高** | 資料來自官方一手來源、包含完整結構化資訊、無需推測 |
| **中** | 資料來自可信二手來源、部分欄位需要推斷但有明確依據 |
| **低** | 資料來源為單一媒體報導、大量欄位缺失、需要大量推測 |

> **重要**：`confidence: 低` 不等於 `[REVIEW_NEEDED]`。前者是資料來源的結構性限制，後者是萃取結果可能有誤。

#### 4.3 severity 欄位指引

適用於事件追蹤 Layer（如：AI_displacement_news、labor_market_shocks）。

| 影響程度 | 判定條件 |
|----------|----------|
| **高** | 影響人數 > 1000 人，或影響整個產業，或政策性變動 |
| **中** | 影響人數 100-1000 人，或影響單一企業，或區域性變動 |
| **低** | 影響人數 < 100 人，或個案性質，或技術性調整 |

#### 4.4 檔案命名規則

```
docs/Extractor/{layer_name}/{category}/{YYYY-MM-DD}_{slug}.md
```

- `{YYYY-MM-DD}` — 資料日期（不是擷取日期）
- `{slug}` — 標題的 URL-safe 版本（小寫、空格改 `-`、移除特殊字元）

範例：

```
docs/Extractor/104_job_market/software_engineer/2026-01-15_senior-backend-engineer.md
```

---

### 5. Write Tool 強制規定

所有萃取子代理**必須**使用 Write tool 寫入 .md 檔，**禁止**使用 Bash heredoc。

#### ❌ 禁止

```bash
cat > file.md <<'EOF'
...
EOF
```

#### ✅ 正確

```
使用 Write tool，參數：
- file_path: 絕對路徑
- content: 完整 Markdown 內容（包含 YAML frontmatter）
```

---

### 6. Category Enum 嚴格限制

- **Category 只能使用定義的英文值，不可自行新增**
- 每個 Layer 的 CLAUDE.md 必須列舉所有可能的 category 值
- 需要新增 category 時必須與使用者確認後寫入 CLAUDE.md

範例（104_job_market Layer）：

```yaml
category_enum:
  software_engineer: 軟體工程師
  data_scientist: 資料科學家
  product_manager: 產品經理
  sales: 業務
  customer_service: 客服
  # ... 其他固定值
```

---

### 7. 資料來源架構

本系統觀測**14 個產業 × 53 個職業角色 × 5 個 AI 取代向量**。

#### 5 個 AI 取代向量

| 向量 | 說明 | 典型職業 |
|------|------|----------|
| **cognitive_routine** | 認知例行工作 | 資料輸入員、客服專員、基層會計 |
| **cognitive_nonroutine** | 認知非例行工作 | 律師、醫師、研究員 |
| **physical_routine** | 體力例行工作 | 生產線作業員、倉儲搬運員 |
| **physical_nonroutine** | 體力非例行工作 | 水電工、廚師、美容師 |
| **interpersonal** | 人際互動工作 | 業務、諮商師、教師 |

萃取時應根據職業特性標註對應的 AI 取代向量（在 YAML frontmatter 或正文中）。

---

### 8. 自我審核 Checklist

每個萃取子代理在輸出前必須逐項確認：

- [ ] 已使用 Write tool 寫入 .md 檔（不是 Bash heredoc）
- [ ] YAML frontmatter 包含所有必要欄位
- [ ] `source_url` 是唯一的（用於去重）
- [ ] `category` 值在該 Layer CLAUDE.md 定義的 enum 中
- [ ] `confidence` 欄位正確反映資料來源的結構性限制
- [ ] 若 WebFetch 失敗，已在 `notes` 欄位標註
- [ ] 僅在萃取結果**可能有誤**時標記 `[REVIEW_NEEDED]`（嚴格遵循 Layer 定義的觸發規則）
- [ ] 正文內容無幻覺（無中生有的資訊）
- [ ] 所有推測明確標註為推測
- [ ] 檔案命名符合 `{YYYY-MM-DD}_{slug}.md` 格式

---

## 禁止行為

1. **不可使用 Read 工具讀取 `.jsonl` 檔案** — 必須透過 `sed -n '{N}p'` 逐行讀取
2. **不可使用 Bash heredoc 寫檔** — 必須使用 Write tool
3. **不可自行新增 category enum 值** — 必須與使用者確認後寫入 Layer CLAUDE.md
4. **不可自行擴大 `[REVIEW_NEEDED]` 判定範圍** — 嚴格遵循 Layer CLAUDE.md 的觸發規則
5. **不可因 WebFetch 失敗而阻斷萃取流程** — 應降級為僅基於 RSS 資料萃取
6. **不可跳過去重檢查** — 萃取前必須檢查 `source_url` 是否已存在
7. **不可產生幻覺內容** — 所有資訊必須來自原始資料或明確標註為推測

---

## 依賴工具

### Shell 腳本依賴（fetch.sh 和 update.sh 使用）

| 檔案 | 用途 |
|------|------|
| `lib/args.sh` | 命令列參數解析 |
| `lib/core.sh` | 通用工具函式（路徑、日誌等） |
| `lib/time.sh` | 時間與日期計算 |
| `lib/rss.sh` | RSS 下載（`rss_fetch`）、XML 轉 JSONL（`rss_extract_items_jsonl`） |
| `lib/chatgpt.sh` | OpenAI API 呼叫（text-embedding-3-small） |
| `lib/qdrant.sh` | Qdrant 向量資料庫 CRUD、去重（by source_url） |

### Claude CLI 工具（萃取子代理使用）

- **Write tool** — 寫入 .md 檔（強制使用）
- **WebFetch tool** — 抓取原始網頁內容（按 Layer 策略使用）
- **Bash tool** — 僅用於檔案檢查（如：檢查 source_url 是否已存在）

---

## 參考文件

- 完整系統規格：根目錄 `CLAUDE.md`
- Architect 角色說明：`core/Architect/CLAUDE.md`
- Narrator 角色說明：`core/Narrator/CLAUDE.md`
- 各 Layer 定義：`core/Extractor/Layers/{layer_name}/CLAUDE.md`
