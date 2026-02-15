# Narrator SEO 整合指引

本文件定義 Narrator Mode 產出報告時的 SEO 整合規則。

---

## 一、整合架構

```
Mode CLAUDE.md（輸出框架）
        ↓
報告 .md 檔（含 SEO front matter）
        ↓
Jekyll 模板（自動生成 JSON-LD）
        ↓
最終 HTML（含結構化資料）
```

**核心原則**：SEO 元資料在報告產出時就包含在 front matter 中，Jekyll 模板負責轉換為 JSON-LD。

---

## 二、報告產出流程修改

### 原有流程

```markdown
---
layout: default
title: W07
parent: 技能漂移
report_title: "技能需求漂移分析 — 2026年第07週"
mode: skills_drift
period: "2026-W07"
generated_at: "2026-02-08T16:00:00Z"
...
---
```

### 修改後流程

```markdown
---
# === Jekyll 基本欄位（不變）===
layout: default
title: W07
parent: 技能漂移
nav_order: 9993
permalink: /reports/skills-drift-w07/

# === 報告元資料（不變）===
report_title: "技能需求漂移分析 — 2026年第07週"
mode: skills_drift
period: "2026-W07"
generated_at: "2026-02-08T16:00:00Z"
...

# === SEO 欄位（新增）===
seo:
  title: "{SEO 標題}"
  description: "{Meta 描述}"
  keywords:
    - {關鍵字1}
    - {關鍵字2}
    ...
  article_section: "{文章分類}"
  faq:
    - question: "{問題1}"
      answer: "{答案1}"
    ...
---
```

---

## 三、各 Mode 的 SEO 欄位產出規則

### 通用規則

所有 Mode 都必須產出以下 SEO 欄位：

| 欄位 | 產出規則 |
|------|----------|
| `seo.title` | `{時間標記}{核心發現} \| {Mode 中文名} \| Skills Shift Observatory` |
| `seo.description` | 摘要前 155 字，包含核心數據 |
| `seo.keywords` | 從報告內容中提取 5-8 個關鍵字 |
| `seo.article_section` | 使用 Mode 對應的固定值 |

### Mode 對應的 article_section

| Mode | article_section |
|------|-----------------|
| climate_index | 景氣溫度計 |
| skills_drift | 技能漂移分析 |
| industry_segments | 產業分層分析 |
| salary_bands | 薪資帶分析 |
| career_strategy | 職涯策略建議 |

### FAQ 產出規則（可選）

從報告內容中提取 3-5 個 Q&A：

1. **問題來源**：
   - 報告中的 H2 標題轉換為問題形式
   - 報告摘要中的核心發現轉換為問題
   - 使用者可能搜尋的問題

2. **答案來源**：
   - 報告中的核心數據
   - 報告摘要
   - 各章節的關鍵結論

---

## 四、各 Mode 的 SEO 產出範例

### climate_index

```yaml
seo:
  title: "2026年第7週就業市場景氣 | 景氣溫度計 | Skills Shift Observatory"
  description: "本週就業市場景氣指數為 68，較上週微升 2 點。科技業招聘持續回暖，金融業穩定成長。總體職缺數達 15,234 筆，年增 8.3%。"
  keywords:
    - 就業市場景氣
    - 景氣指數
    - 職缺數量
    - 科技業招聘
    - 2026 勞動市場
  article_section: 景氣溫度計
  faq:
    - question: "2026年第7週就業市場景氣如何？"
      answer: "本週景氣指數為 68，較上週微升 2 點，處於溫和擴張區間。科技業和金融業為主要成長動力。"
    - question: "哪些產業正在擴大招聘？"
      answer: "科技業招聘持續回暖，職缺年增 12%。金融業穩定成長，新增職缺集中在數位轉型相關職位。"
```

### skills_drift

```yaml
seo:
  title: "2026年第7週技能需求變化 | 技能漂移分析 | Skills Shift Observatory"
  description: "本週技能需求分析：Go 語言需求大幅上升 142.9%，AI 技能持續主導市場。分析 2,074 筆職缺資料，追蹤 Python、TypeScript、Rust 等技能需求變化趨勢。"
  keywords:
    - 技能需求
    - 就業市場分析
    - Go 語言
    - AI 技能
    - 程式語言趨勢
    - 2026 職缺
  article_section: 技能漂移分析
  faq:
    - question: "2026年第7週哪些程式語言需求上升最多？"
      answer: "Go 語言需求大幅上升 142.9%，主要來自歐洲職缺與遠端工作市場。Scala 成長 73.6%，反映金融科技領域擴張。"
    - question: "AI 技能需求現況如何？"
      answer: "AI 技能需求持續主導市場，「AI」一詞出現 1,328 次。RAG 和 Agentic 等新興技術標籤需求顯著成長。"
```

### industry_segments

```yaml
seo:
  title: "2026年第7週產業招聘趨勢 | 產業分層分析 | Skills Shift Observatory"
  description: "本週產業招聘分析：科技業職缺年增 12%，金融業穩定成長 8%。AI 相關職位集中在科技和金融產業，製造業數位轉型需求持續。"
  keywords:
    - 產業招聘趨勢
    - 科技業職缺
    - 金融業招聘
    - 製造業就業
    - 產業分析
  article_section: 產業分層分析
  faq:
    - question: "2026年哪些產業招聘最活躍？"
      answer: "科技業職缺年增 12%，為最活躍產業。金融業穩定成長 8%，新增職位集中在數位轉型和 AI 應用。"
```

### salary_bands

```yaml
seo:
  title: "2026年第7週薪資趨勢 | 薪資帶分析 | Skills Shift Observatory"
  description: "本週薪資分析：軟體工程師月薪中位數達 85,000 元，年增 5%。AI 工程師薪資突破 120,000 元，為最高薪職位。各產業薪資差距分析。"
  keywords:
    - 薪資趨勢
    - 軟體工程師薪水
    - AI 工程師薪資
    - 科技業薪資
    - 2026 薪資
  article_section: 薪資帶分析
  faq:
    - question: "2026年軟體工程師薪資多少？"
      answer: "軟體工程師月薪中位數達 85,000 元，年增 5%。資深工程師（5年以上）可達 120,000 元以上。"
```

### career_strategy

```yaml
seo:
  title: "2026年第7週職涯建議 | 求職策略 | Skills Shift Observatory"
  description: "本週職涯策略建議：建議加強 AI 和雲端技能，Go 語言為高成長技能。轉職建議：傳統後端可轉向雲端架構師，前端可發展全端能力。"
  keywords:
    - 職涯規劃
    - 轉職建議
    - 技能學習
    - AI 技能
    - 求職策略
    - 2026 職涯
  article_section: 職涯策略建議
  faq:
    - question: "2026年該學什麼技能？"
      answer: "建議優先學習 AI/ML 基礎和雲端技術。Go 語言需求成長快速，適合後端開發者進修。Python 仍是 AI 領域必備技能。"
```

---

## 五、實作步驟

### 5.1 修改 Mode CLAUDE.md

在每個 Mode 的 CLAUDE.md 中，將「輸出框架」section 的 front matter 模板擴展，加入 SEO 欄位。

**範例（以 skills_drift 為例）**：

在 `core/Narrator/Modes/skills_drift/CLAUDE.md` 的「輸出框架」section：

```markdown
## 輸出框架

```markdown
---
layout: default
title: W{WW}
parent: 技能漂移
nav_order: {10000 - WW}
permalink: /reports/skills-drift-w{ww}/

report_title: "技能需求漂移分析 — {YYYY}年第{WW}週"
mode: skills_drift
period: "{YYYY}-W{WW}"
generated_at: "{ISO 8601 timestamp}"
source_layers:
  - {layer_1}
  - {layer_2}
  ...
data_coverage:
  layers_available: {N}
  layers_total: {M}
  observation_window: "{start} ~ {end}"
  total_job_postings: {N}
confidence: {高/中/低}
qdrant_search_used: true

# === SEO 欄位 ===
seo:
  title: "{YYYY}年第{WW}週技能需求變化 | 技能漂移分析 | Skills Shift Observatory"
  description: "{從摘要中提取，包含核心數據，≤155字}"
  keywords:
    - 技能需求
    - 就業市場分析
    - {本週熱門技能1}
    - {本週熱門技能2}
    - {本週熱門技能3}
    - {YYYY} 職缺
  article_section: 技能漂移分析
  faq:
    - question: "{YYYY}年第{WW}週哪些程式語言需求上升？"
      answer: "{從報告中提取答案}"
    - question: "{其他常見問題}"
      answer: "{答案}"
    - question: "{其他常見問題}"
      answer: "{答案}"
---
```

### 5.2 自我審核 Checklist 擴展

在每個 Mode 的「自我審核 Checklist」section 加入：

```markdown
### SEO 審核
- [ ] `seo.title` 存在且 ≤60 字
- [ ] `seo.description` 存在且 ≤155 字，包含核心數據
- [ ] `seo.keywords` 有 5-8 個關鍵字
- [ ] `seo.article_section` 使用正確的固定值
- [ ] `seo.faq` 有 3-5 個 Q&A（問題為使用者會搜尋的形式）
```

---

## 六、參考文件

| 文件 | 說明 |
|------|------|
| `seo/CLAUDE.md` | SEO 規則庫（Schema 定義） |
| `seo/front-matter-spec.md` | Front matter SEO 欄位規範 |
| `seo/integration-design.md` | SEO 整合設計文件 |
| `_data/seo.yml` | 全站 SEO 設定 |
| `_includes/seo-schema.html` | JSON-LD 生成器 |

---

## 七、驗證方式

報告發布後，可使用以下工具驗證 JSON-LD：

1. **Google Rich Results Test**
   ```
   https://search.google.com/test/rich-results
   ```

2. **Schema.org Validator**
   ```
   https://validator.schema.org/
   ```

**預期通過項目**：
- Article
- BreadcrumbList
- FAQPage（若有 FAQ）
- WebPage
- Organization
- Person

---

*最後更新：2026-02-15*
