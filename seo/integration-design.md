# SEO 整合設計文件（方案 A+C）

## 概述

本文件定義 Skills Shift Observatory 網站的 SEO 整合架構，採用：

- **方案 A**：Mode 層級整合 — 報告產出時在 front matter 包含 SEO 元資料
- **方案 C**：Jekyll 模板處理 — 根據 front matter 自動生成 JSON-LD

---

## 一、架構總覽

```
┌─────────────────────────────────────────────────────────────┐
│                    報告產出流程                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ Mode        │ -> │ front matter│ -> │ Jekyll      │     │
│  │ CLAUDE.md   │    │ SEO 欄位    │    │ 模板渲染    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│        ↓                  ↓                  ↓              │
│  定義輸出規則        報告 .md 檔        最終 HTML           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    Jekyll 處理層                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ _data/      │    │ _includes/  │    │ _layouts/   │     │
│  │ seo.yml     │    │ seo-schema  │    │ default     │     │
│  └─────────────┘    │ .html       │    │ .html       │     │
│        ↓            └─────────────┘    └─────────────┘     │
│  全站 SEO 設定           ↓                  ↓              │
│  （Organization）   JSON-LD 生成器    引入 seo-schema      │
└─────────────────────────────────────────────────────────────┘
```

---

## 二、檔案結構

```
/
├── _config.yml                    # Jekyll 設定（新增 SEO 預設值）
├── _data/
│   └── seo.yml                    # 全站 SEO 設定 [新建]
├── _includes/
│   └── seo-schema.html            # JSON-LD 生成器 [新建]
├── _layouts/
│   └── default.html               # 覆寫主題 layout [新建]
├── seo/
│   ├── CLAUDE.md                  # SEO 規則庫（已存在）
│   ├── writer/CLAUDE.md           # Writer 角色（已存在）
│   ├── review/CLAUDE.md           # Reviewer 角色（已存在）
│   ├── integration-design.md      # 本文件 [新建]
│   └── front-matter-spec.md       # Front matter 規範 [新建]
└── core/Narrator/
    └── seo-integration.md         # Narrator SEO 整合指引 [新建]
```

---

## 三、各層職責

### 3.1 _data/seo.yml — 全站 SEO 設定

定義不變的全站資訊：

| 欄位 | 說明 |
|------|------|
| `organization` | 出版者資訊（Organization Schema） |
| `default_author` | 預設作者資訊（Person Schema） |
| `site_info` | 網站基本資訊（WebSite Schema） |
| `image_defaults` | 預設圖片授權資訊 |

### 3.2 _includes/seo-schema.html — JSON-LD 生成器

根據頁面 front matter + 全站設定，生成：

| Schema | 來源 | 條件 |
|--------|------|------|
| WebPage | front matter + site | 所有頁面 |
| Article | front matter | 有 `report_title` 的頁面 |
| Person | _data/seo.yml | 連結 author |
| Organization | _data/seo.yml | 連結 publisher |
| BreadcrumbList | Jekyll 自動計算 | 所有頁面 |
| FAQPage | front matter `faq` | 有 FAQ 的頁面 |

### 3.3 Front Matter — 報告層級 SEO

每個報告 .md 檔的 front matter 需包含：

| 欄位 | 必填 | 說明 |
|------|------|------|
| `seo.title` | 是 | SEO 標題（≤60字） |
| `seo.description` | 是 | Meta description（≤155字） |
| `seo.keywords` | 是 | 關鍵字陣列 |
| `seo.article_section` | 是 | 文章分類 |
| `seo.faq` | 否 | FAQ 陣列（3-5 題） |

### 3.4 Mode CLAUDE.md — 產出規則

每個 Mode 的輸出框架需包含 SEO front matter 欄位定義，確保報告產出時自動包含 SEO 元資料。

---

## 四、適用範圍

### 適用的 Schema（本站需要）

| Schema | 適用場景 | 自動化程度 |
|--------|----------|-----------|
| **WebPage** | 所有頁面 | 100% 自動 |
| **Article** | 所有報告 | 100% 自動 |
| **Person** | 作者資訊 | 全站設定 |
| **Organization** | 出版者 | 全站設定 |
| **BreadcrumbList** | 導航 | 100% 自動 |
| **FAQPage** | 報告 FAQ | 需 front matter |

### 不適用的 Schema

| Schema | 原因 |
|--------|------|
| Recipe | 非食譜類內容 |
| Product | 非商品頁面 |
| LocalBusiness | 非實體店家 |
| Event | 非活動頁面 |
| Course | 非課程頁面 |
| Review | 非評測類內容 |
| HowTo | 報告非操作教學 |
| VideoObject | 無影片內容 |

### SGE 標記（部分適用）

| 標記 | 適用 | 說明 |
|------|------|------|
| `.key-answer` | 否 | 報告非 Q&A 格式 |
| `.key-takeaway` | 是 | 報告摘要可用 |
| `.expert-quote` | 否 | 無專家引言 |
| `.actionable-steps` | 是 | 職涯建議章節可用 |
| `.comparison-table` | 是 | 比較表格可用 |

---

## 五、實作步驟

### Step 1: 建立全站 SEO 設定

建立 `_data/seo.yml`，定義 Organization 和預設 Person。

### Step 2: 建立 JSON-LD 生成器

建立 `_includes/seo-schema.html`，根據 front matter 生成結構化資料。

### Step 3: 覆寫 Layout

建立 `_layouts/default.html`，在 `<head>` 中引入 `seo-schema.html`。

### Step 4: 定義 Front Matter 規範

建立 `seo/front-matter-spec.md`，供 Narrator Mode 參考。

### Step 5: 更新 Mode CLAUDE.md

在每個 Mode 的輸出框架中加入 SEO front matter 欄位。

### Step 6: 驗證

使用 Google Rich Results Test 驗證生成的 JSON-LD。

---

## 六、維護規則

### 新增報告時

1. 確保 front matter 包含所有必填 SEO 欄位
2. 撰寫 155 字內的 description
3. 選擇 3-5 個相關 keywords
4. 可選：加入 3-5 個 FAQ

### 修改全站設定時

1. 修改 `_data/seo.yml`
2. 重新 build 網站驗證

### 新增 Mode 時

1. 在 Mode CLAUDE.md 中定義 SEO front matter 欄位
2. 確保輸出框架包含必填欄位

---

## 七、與現有系統的整合點

### CLAUDE.md 步驟五：發布到 GitHub Pages

現有流程：
```
3. **提交並推送**：
   git add docs/Narrator/ index.md
   git commit -m "更新報告: {YYYY}-W{WW}"
   git pull --rebase && git push
```

不需修改。SEO 元資料已包含在 front matter 中，Jekyll 會自動處理。

### Mode 報告產出

現有流程會在 front matter 中包含必要欄位，只需擴展欄位定義。

---

## 附錄：簡化後的 SEO Checklist

針對本站報告的簡化版檢查清單：

### Front Matter 必填

- [ ] `seo.title`：SEO 標題（≤60字，含核心關鍵字）
- [ ] `seo.description`：Meta description（≤155字）
- [ ] `seo.keywords`：關鍵字陣列（5-8 個）
- [ ] `seo.article_section`：文章分類

### 自動處理（不需手動）

- [x] WebPage Schema
- [x] Article Schema
- [x] Person/Organization Schema（全站設定）
- [x] BreadcrumbList Schema
- [x] Open Graph 標籤
- [x] Twitter Card 標籤

### 可選增強

- [ ] `seo.faq`：FAQ 陣列（3-5 題）

---

*最後更新：2026-02-15*
