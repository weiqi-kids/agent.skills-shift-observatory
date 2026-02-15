# Front Matter SEO 規範

本文件定義報告 .md 檔的 front matter SEO 欄位規範，供 Narrator Mode 產出報告時參考。

---

## 一、完整範例

```yaml
---
# === Jekyll 基本欄位 ===
layout: default
title: W07
parent: 技能漂移
nav_order: 9993
permalink: /reports/skills-drift-w07/

# === 報告元資料 ===
report_title: "技能需求漂移分析 — 2026年第07週"
mode: skills_drift
period: "2026-W07"
generated_at: "2026-02-08T16:00:00Z"
source_layers:
  - global_hn_hiring
  - global_arbeitnow
  - tw_govjobs
data_coverage:
  layers_available: 6
  layers_total: 7
  observation_window: "2026-W06 ~ 2026-W07"
  total_job_postings: 2074
confidence: 中
qdrant_search_used: true

# === SEO 欄位（新增）===
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
  og_image: "https://skills.weiqi.kids/assets/images/skills-drift-og.png"
  faq:
    - question: "2026年第7週哪些程式語言需求上升最多？"
      answer: "Go 語言需求大幅上升 142.9%，主要來自歐洲職缺與遠端工作市場。Scala 成長 73.6%，反映金融科技與大數據領域持續擴張。"
    - question: "AI 技能需求現況如何？"
      answer: "AI 技能需求持續主導市場，「AI」一詞在 HN Hiring 中出現 1,328 次。RAG（檢索增強生成）和 Agentic（AI 代理）等新興技術標籤需求顯著成長。"
    - question: "本週技能需求分析涵蓋哪些資料來源？"
      answer: "本週分析涵蓋 6 個資料來源，共 2,074 筆職缺資料，包括 HN Hiring、Arbeitnow、RemoteOK、WeWorkRemotely 等全球職缺平台。"
---
```

---

## 二、SEO 欄位說明

### 必填欄位

| 欄位 | 說明 | 限制 | 範例 |
|------|------|------|------|
| `seo.title` | SEO 標題 | ≤60 字，含核心關鍵字 | `"2026年第7週技能需求變化 \| Skills Shift Observatory"` |
| `seo.description` | Meta description | ≤155 字，含關鍵字 | `"本週技能需求分析：Go 語言需求大幅上升..."` |
| `seo.keywords` | 關鍵字陣列 | 5-8 個 | `["技能需求", "就業市場分析", ...]` |
| `seo.article_section` | 文章分類 | 固定值 | `"技能漂移分析"` |

### 選填欄位

| 欄位 | 說明 | 預設值 |
|------|------|--------|
| `seo.og_image` | OG 圖片 URL | `_data/seo.yml` 中的預設值 |
| `seo.faq` | FAQ 陣列（3-5 題） | 無 |

---

## 三、各欄位撰寫指南

### 3.1 seo.title

**目的**：搜尋結果中顯示的標題

**撰寫原則**：
1. 包含核心關鍵字（如「技能需求」「就業市場」）
2. 包含時間標記（如「2026年第7週」）
3. 包含品牌名（如「Skills Shift Observatory」）
4. 控制在 60 字以內

**格式建議**：
```
{時間標記}{核心主題} | {報告類型} | {品牌名}
```

**範例**：
```yaml
# 好
seo:
  title: "2026年第7週技能需求變化 | 技能漂移分析 | Skills Shift Observatory"

# 差（太長）
seo:
  title: "2026年第7週全球就業市場技能需求變化趨勢完整分析報告 — 技能漂移分析 — Skills Shift Observatory 技能需求變化觀測站"
```

### 3.2 seo.description

**目的**：搜尋結果中顯示的描述片段

**撰寫原則**：
1. 開頭直接陳述核心發現
2. 包含具體數據（增長率、職缺數等）
3. 包含 2-3 個關鍵技能標籤
4. 控制在 155 字以內

**範例**：
```yaml
# 好
seo:
  description: "本週技能需求分析：Go 語言需求大幅上升 142.9%，AI 技能持續主導市場。分析 2,074 筆職缺資料，追蹤 Python、TypeScript、Rust 等技能需求變化趨勢。"

# 差（沒有具體數據）
seo:
  description: "本週技能需求分析報告，追蹤各種程式語言和技能的需求變化。"
```

### 3.3 seo.keywords

**目的**：幫助搜尋引擎理解頁面主題

**撰寫原則**：
1. 5-8 個關鍵字
2. 混合廣泛詞和具體詞
3. 包含時間相關詞（如「2026」「最新」）
4. 包含報告中提到的主要技能

**範例**：
```yaml
seo:
  keywords:
    - 技能需求          # 廣泛詞
    - 就業市場分析      # 廣泛詞
    - Go 語言           # 具體技能
    - AI 技能           # 熱門主題
    - 程式語言趨勢      # 主題相關
    - 2026 職缺         # 時間相關
    - 遠端工作技能      # 細分主題
```

### 3.4 seo.article_section

**目的**：文章分類，對應 Mode

**固定值**：

| Mode | article_section |
|------|-----------------|
| climate_index | 景氣溫度計 |
| skills_drift | 技能漂移分析 |
| industry_segments | 產業分層分析 |
| salary_bands | 薪資帶分析 |
| career_strategy | 職涯策略建議 |

### 3.5 seo.faq

**目的**：生成 FAQPage Schema，提高搜尋結果的 Rich Snippet 展示機會

**撰寫原則**：
1. 3-5 個 Q&A
2. 問題必須是使用者可能搜尋的形式
3. 答案必須完整、可被獨立理解
4. 答案控制在 2-3 句話

**範例**：
```yaml
seo:
  faq:
    - question: "2026年哪些程式語言需求最高？"
      answer: "根據本週數據，Python 仍是最熱門語言，出現 1,148 次。Go 語言需求大幅成長 142.9%，TypeScript 穩居第二位。"

    - question: "AI 技能對求職有幫助嗎？"
      answer: "AI 相關技能需求持續增長。本週「AI」一詞出現 1,328 次，RAG 和 Agentic 等新興技術標籤需求顯著成長，建議求職者加強相關技能。"

    - question: "遠端工作職缺技能需求有何特點？"
      answer: "遠端工作職缺偏好 Rails、Go 等成熟技術棧。WeWorkRemotely 平台的 Rails 需求成長 179.7%，反映遠端工作重視穩定性。"
```

---

## 四、各 Mode 的 SEO 重點

### climate_index（景氣溫度計）

**關鍵字重點**：就業市場、景氣指數、失業率、職缺數量、勞動市場趨勢

**FAQ 方向**：
- 目前就業市場景氣如何？
- 哪些產業在擴大招聘？
- 失業率是上升還是下降？

### skills_drift（技能漂移）

**關鍵字重點**：技能需求、程式語言、框架、AI 技能、熱門技術

**FAQ 方向**：
- 哪些程式語言需求上升？
- 哪些技能正在衰退？
- AI 技能需求現況如何？

### industry_segments（產業分層）

**關鍵字重點**：產業趨勢、科技業招聘、金融業職缺、製造業就業

**FAQ 方向**：
- 哪些產業正在擴大招聘？
- 科技業裁員對就業市場影響？
- 各產業薪資差異如何？

### salary_bands（薪資帶）

**關鍵字重點**：薪資趨勢、程式設計師薪水、科技業薪資、薪資中位數

**FAQ 方向**：
- 軟體工程師薪資多少？
- 哪些技能薪資最高？
- 各地區薪資差異如何？

### career_strategy（職涯策略）

**關鍵字重點**：職涯規劃、轉職建議、技能學習、求職策略

**FAQ 方向**：
- 現在該學什麼技能？
- 如何判斷是否該轉職？
- 哪些職業發展前景好？

---

## 五、驗證清單

產出報告前，確認以下項目：

- [ ] `seo.title` 存在且 ≤60 字
- [ ] `seo.title` 包含核心關鍵字和時間標記
- [ ] `seo.description` 存在且 ≤155 字
- [ ] `seo.description` 包含具體數據
- [ ] `seo.keywords` 有 5-8 個關鍵字
- [ ] `seo.article_section` 使用正確的固定值
- [ ] `seo.faq` 有 3-5 個 Q&A（可選）
- [ ] FAQ 問題是使用者會搜尋的形式
- [ ] FAQ 答案可被獨立理解

---

## 六、自動處理說明

以下 Schema 由 Jekyll 模板自動生成，**不需要在 front matter 中手動填寫**：

| Schema | 來源 |
|--------|------|
| WebSite | `_data/seo.yml` |
| Organization | `_data/seo.yml` |
| Person | `_data/seo.yml` |
| WebPage | front matter + 自動計算 |
| Article | front matter `mode` + `report_title` |
| BreadcrumbList | front matter `parent` + `mode` |
| ImageObject | `_data/seo.yml` 預設值或 `seo.og_image` |
| FAQPage | front matter `seo.faq`（若存在） |

---

*最後更新：2026-02-15*
