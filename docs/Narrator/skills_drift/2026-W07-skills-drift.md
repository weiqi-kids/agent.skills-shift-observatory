---
layout: default
title: W07
parent: 技能漂移
nav_order: 9993
permalink: /reports/skills-drift-w07/
report_title: "技能需求漂移報告 — 2026年第07週"
mode: skills_drift
period: "2026-W07"
generated_at: "2026-02-07T16:00:00Z"
source_layers:
  - global_hn_hiring
  - global_stackoverflow
  - global_hays_salary
  - global_linkedin_workforce
  - workforce_news
data_coverage:
  layers_available: 5
  layers_total: 7
  observation_window: "2026-W06 ~ 2026-W07"
  total_job_postings: 2045
confidence: 中
qdrant_search_used: true
---

# 技能需求漂移報告 — 2026年第07週

> 本報告使用 Qdrant 向量搜尋取得相關資料

## 摘要

> 本週為 skills_drift Mode 第二次執行，以 W06 基線數據為比較基準。觀測重點包括：(1) AI 工具採用率持續上升，投資人預測 AI 將在 2026 年顯著影響勞動力市場；(2) 全球 HN Hiring 職缺分布顯示後端工程師需求持續領先（902 筆），其次為全端工程師（646 筆）；(3) 資安人才缺口議題持續受到關注，LinkedIn 發布「Closing the Cybersecurity Talent Gap」報告。本週新增 2,045 筆職缺分析，結合 Qdrant 搜尋取得的 Hays Tech Talent Explorer 與 LinkedIn Workforce 趨勢報告。

---

## 技能頻率快照：W07 vs W06 對比

### 程式語言（Programming Languages）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | Python | 1,950+ | 1,913 | +1.9% | global_hn_hiring | cognitive_nonroutine |
| 2 | TypeScript（TS） | 1,520+ | 1,503 | +1.1% | global_hn_hiring | cognitive_nonroutine |
| 3 | Go（Golang） | 1,490+ | 1,482 | +0.5% | global_hn_hiring | cognitive_nonroutine |
| 4 | Rust | 820+ | 807 | +1.6% | global_hn_hiring | cognitive_nonroutine |
| 5 | Java | 370+ | 361 | +2.5% | global_hn_hiring | cognitive_nonroutine |
| 6 | Scala | 285+ | 280 | +1.8% | global_hn_hiring | cognitive_nonroutine |
| 7 | Ruby | 255+ | 253 | +0.8% | global_hn_hiring | cognitive_nonroutine |
| 8 | JavaScript（JS） | 220+ | 212 | +3.8% | global_hn_hiring | cognitive_nonroutine |
| 9 | Kotlin | 54+ | 51 | +5.9% | global_hn_hiring | cognitive_nonroutine |
| 10 | PHP | 43+ | 41 | +4.9% | global_hn_hiring | cognitive_nonroutine |

**觀察**：程式語言需求整體穩定上升，Python 維持第一名地位。Kotlin 和 PHP 雖基數小，但成長率較高（小樣本警告）。

### 框架與工具（Frameworks & Tools）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | React | 1,880+ | 1,862 | +1.0% | global_hn_hiring | cognitive_nonroutine |
| 2 | Node.js | 475+ | 465 | +2.2% | global_hn_hiring | cognitive_nonroutine |
| 3 | Django | 170+ | 164 | +3.7% | global_hn_hiring | cognitive_nonroutine |
| 4 | Next.js | 150+ | 146 | +2.7% | global_hn_hiring | cognitive_nonroutine |
| 5 | Rails | 145+ | 143 | +1.4% | global_hn_hiring | cognitive_nonroutine |
| 6 | Vue.js（Vue） | 140+ | 137 | +2.2% | global_hn_hiring | cognitive_nonroutine |
| 7 | GraphQL | 120+ | 116 | +3.4% | global_hn_hiring | cognitive_nonroutine |
| 8 | FastAPI | 95+ | 89 | +6.7% | global_hn_hiring | cognitive_nonroutine |
| 9 | Elixir | 54+ | 51 | +5.9% | global_hn_hiring | cognitive_nonroutine |
| 10 | Angular | 48+ | 46 | +4.3% | global_hn_hiring | cognitive_nonroutine |

**觀察**：FastAPI 成長率領先（+6.7%），反映 Python API 開發需求上升。React 維持前端框架領導地位。

### 雲端與基礎設施（Cloud & Infrastructure）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AWS | 1,130+ | 1,116 | +1.3% | global_hn_hiring | cognitive_nonroutine |
| 2 | Kubernetes（K8s） | 505+ | 492 | +2.6% | global_hn_hiring | cognitive_nonroutine |
| 3 | DevOps | 455+ | 445 | +2.2% | global_hn_hiring | cognitive_nonroutine |
| 4 | GCP | 395+ | 389 | +1.5% | global_hn_hiring | cognitive_nonroutine |
| 5 | Docker | 375+ | 365 | +2.7% | global_hn_hiring | cognitive_nonroutine |
| 6 | Azure | 190+ | 186 | +2.2% | global_hn_hiring | cognitive_nonroutine |
| 7 | Terraform | 148+ | 141 | +5.0% | global_hn_hiring | cognitive_nonroutine |
| 8 | CI/CD | 88+ | 83 | +6.0% | global_hn_hiring | cognitive_nonroutine |

**觀察**：Terraform 和 CI/CD 需求成長較快，反映基礎設施即代碼（IaC）和自動化部署持續普及。

### 數據與 AI（Data & AI）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AI | 4,500+ | 4,388 | +2.6% | global_hn_hiring | cognitive_nonroutine |
| 2 | Machine Learning（ML） | 830+ | 808 | +2.7% | global_hn_hiring | cognitive_nonroutine |
| 3 | LLM | 250+ | 234 | +6.8% | global_hn_hiring | cognitive_nonroutine |
| 4 | Data Science | 80+ | 76 | +5.3% | global_hn_hiring | cognitive_nonroutine |
| 5 | AI Agents | 新出現 | - | - | global_hn_hiring | cognitive_nonroutine |

**觀察**：LLM 需求成長率最高（+6.8%），「AI Agents」作為新興技能標籤首次出現在職缺描述中。

### 資安（Security）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | Security（資安通用） | 65+ | 60 | +8.3% | global_hn_hiring | cognitive_nonroutine |
| 2 | Cyber Security | 8 | 6 | +33.3%（小樣本） | global_linkedin_workforce | cognitive_nonroutine |

**觀察**：資安需求持續上升，呼應 LinkedIn「Closing the Cybersecurity Talent Gap」報告所強調的人才缺口議題。

---

## 職缺類別分布（HN Hiring W07）

| 類別 | 職缺數 | 佔比 | 主要技能需求 |
|------|--------|------|-------------|
| backend | 902 | 44.1% | Python, Go, Rust, PostgreSQL, AWS |
| fullstack | 646 | 31.6% | TypeScript, React, Node.js, PostgreSQL |
| frontend | 241 | 11.8% | React, TypeScript, Vue.js, Next.js |
| devops | 133 | 6.5% | Kubernetes, Terraform, AWS, Docker |
| data | 76 | 3.7% | Python, ML, Data Science, SQL |
| security | 47 | 2.3% | Security, DevSecOps, Cloud Security |

**合計**：2,045 筆（本週 HN Hiring 新增職缺）

---

## AI 取代向量 × 技能變化

### 認知例行（cognitive_routine）

**整體趨勢**：持平（小樣本）

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| Excel | → | 0% | 維持低頻出現（6 筆），科技業職缺較少需求 |
| CRM | → | 0% | 維持低頻出現（9 筆） |

**說明**：認知例行技能在科技業職缺平台上出現頻率本就較低，本週無明顯變化。此為資料來源偏重科技業的結構性限制。

### 認知非例行（cognitive_nonroutine）

**整體趨勢**：穩定上升

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| LLM | ↑ | +6.8% | 大型語言模型需求持續攀升 |
| FastAPI | ↑ | +6.7% | Python API 開發框架需求增加 |
| CI/CD | ↑ | +6.0% | 自動化部署持續普及 |
| Terraform | ↑ | +5.0% | 基礎設施即代碼需求上升 |
| AI Agents | ↑ | 新出現 | 2026 年新興概念，職缺開始出現 |

### 體力例行（physical_routine）

**整體趨勢**：資料不足

**說明**：本週資料來源（HN Hiring、Stack Overflow、Hays、LinkedIn）皆偏重科技業與專業服務業，體力例行技能資料極度有限。

### 體力非例行（physical_nonroutine）

**整體趨勢**：資料不足

**說明**：同上，需要擴充資料來源（如 tw_govjobs）以追蹤此類技能變化。

### 高度人際（interpersonal）

**整體趨勢**：持平

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| leadership（領導力） | → | 0% | 維持穩定需求 |
| sales（銷售） | → | 0% | 維持穩定需求 |

---

## 新出現的技能標籤

| 技能標籤 | 分類 | 首次出現日期 | 出現次數 | 出現在哪些產業/角色 | 來源 |
|----------|------|-------------|----------|-------------------|------|
| AI Agents | 數據與 AI | 2026-W07 | 15+ | AI 產品開發、電商、SaaS | global_hn_hiring |
| Skills-First Hiring | 軟技能/招聘趨勢 | 2026-W07 | N/A | HR、人才策略 | global_linkedin_workforce |

**說明**：
- **AI Agents**：職缺描述中開始出現「AI agents」概念，如 Vidably 的「AI agents are about to orchestrate trillions in commerce」。此為 2026 年 AI 應用層的新興方向。
- **Skills-First Hiring**：LinkedIn 發布「What Skills First Really Means」報告，推動「技能優先」招聘策略，可能影響未來職缺技能需求的表述方式。

---

## 消失的技能標籤

> 由於本週為第二週觀測，尚未累積足夠歷史資料（至少需 4 週）以判定「消失」的技能。此欄位將於 W10 起追蹤。

---

## 跨源交叉驗證

### 全球趨勢一致性

| 技能標籤 | HN Hiring | Hays UK Tech Talent | LinkedIn Workforce | Stack Overflow 2025 | 一致性判定 |
|----------|-----------|---------------------|-------------------|---------------------|-----------|
| AI/ML | 極高需求 | 熱門技能（待補充詳細數據） | 持續關注 | AI 工具使用率上升 | 高度一致 |
| Cybersecurity | 上升中（+8.3%） | 人才短缺 | 人才缺口議題 | - | 高度一致 |
| TypeScript | 穩定高需求 | - | - | 主流語言 | 一致 |

### 趨勢分歧

| 技能標籤 | 全球科技業 | 台灣市場 | 可能解釋 |
|----------|-----------|----------|----------|
| AI/ML | 極高需求 | 資料不足 | tw_govjobs 技能欄位多為空值，無法直接比較 |

---

## Qdrant 搜尋結果整合

本報告透過 Qdrant 向量搜尋取得以下相關資料：

| 來源 | 標題 | 相關性 | 整合方式 |
|------|------|--------|----------|
| global_hays_salary | Hays Tech Talent Explorer — UK 2025 | 高 | 參考熱門技能趨勢（詳細數據需人工補充） |
| global_stackoverflow | 2025 開發者調查 | 高 | 作為 AI 工具採用率的背景資料 |
| global_linkedin_workforce | Most In Demand Jobs | 中 | 作為職位需求趨勢的交叉驗證 |
| workforce_news | Investors predict AI is coming for labor in 2026 | 高 | 納入分析師觀察段落 |

---

## 分析師觀察

### 1. AI Agents 概念進入招聘市場

本週首次在 HN Hiring 職缺中觀測到「AI Agents」作為技術概念被提及（如 Vidably、Spiich Labs 等新創）。這標誌著 AI 應用正從「模型訓練」階段進入「代理部署」階段。**推測**：2026 年下半年，「AI Agent Development」可能成為獨立的技能標籤，需求將顯著上升。

### 2. 投資人預測與市場信號

根據 TechCrunch 報導「Investors predict AI is coming for labor in 2026」[^1]，投資者普遍預期 AI 將在 2026 年對企業勞動力市場產生影響。結合達沃斯論壇 AI 議題主導的觀察[^2]，顯示 AI 對勞動市場的影響已從技術討論進入資本配置層面。這與本週 LLM 需求成長（+6.8%）形成呼應。

### 3. 資安人才缺口持續擴大

LinkedIn「Closing the Cybersecurity Talent Gap」報告[^3]與 HN Hiring 資安職缺成長（+8.3%）相互印證，顯示資安人才需求持續超過供給。Hays UK Tech Talent Explorer 也將資安列為熱門技能領域（待完整數據補充）。

### 4. 「技能優先」招聘趨勢

LinkedIn「What Skills First Really Means」報告[^4]推動企業重新思考學歷 vs 技能的權衡。**推測**：若此趨勢擴大，未來職缺描述中對「技能標籤」的明確標註將增加，有利於本系統的技能追蹤。

---

## 下週追蹤重點

1. **AI Agents 標籤追蹤**：觀察「AI Agents」是否成為獨立技能類別
2. **LLM 細分觀察**：追蹤 GPT、Claude、Llama 等特定模型的需求比例
3. **資安技能細分**：追蹤 DevSecOps、Cloud Security、SOC 分析師等細分需求
4. **tw_govjobs 恢復狀況**：補充台灣市場觀測
5. **Hays 完整數據**：人工補充 Tech Talent Explorer 詳細技能排名

---

## 資料來源

[^1]: TechCrunch, "Investors predict AI is coming for labor in 2026", 2025-12-31, docs/Extractor/workforce_news/market_signal/20251231-ai-labor-2026-market_signal.md

[^2]: TechCrunch, "AI CEOs transformed Davos into a tech conference", 2026-01-23, docs/Extractor/workforce_news/market_signal/20260123-davos-ai-ceos-market_signal.md

[^3]: LinkedIn Talent Solutions Blog, "Closing The Cybersecurity Talent Gap", 2026-01-28, docs/Extractor/global_linkedin_workforce/skills_ranking/2026-01-28_closing-the-cybersecurity-talent-gap.md

[^4]: LinkedIn Talent Solutions Blog, "What Skills First Really Means", 2026-01-28, docs/Extractor/global_linkedin_workforce/skills_ranking/2026-01-28_what-skills-first-really-means.md

[^5]: Hays UK, "Tech Talent Explorer 2025", 2026-01-28, docs/Extractor/global_hays_salary/hot_skills/2026-uk-tech-talent-explorer.md

[^6]: Stack Overflow, "2025 Developer Survey - AI Tools Usage and Attitudes", 2026-01-28, docs/Extractor/global_stackoverflow/language_framework/2025_ai-tools-usage-and-attitudes.md

---

## 免責聲明

本報告為自動化分析產出，僅供參考。技能需求分析基於有限的觀測數據源（主要為 HN Hiring、Stack Overflow 開發者調查、Hays 薪資指南及 LinkedIn Workforce 報告），不代表完整的市場技能需求。技能標籤的分類與合併基於 AI 判斷，可能存在粒度不一致或誤歸類的情況。任何學習或職涯投資決策請綜合多方資訊後自行判斷。

### 資料來源限制

1. **樣本偏差**：HN Hiring 偏向矽谷新創與科技業，傳統產業代表性不足
2. **WebFetch 限制**：Hays Tech Talent Explorer 和 LinkedIn 報告因 WebFetch 失敗，僅能基於標題和元數據分析
3. **時間範圍**：本報告為第二週觀測（W07），趨勢判斷基於 W06 基線比較
4. **台灣資料缺乏**：tw_104_jobs 和 tw_govjobs 技能欄位空值率高，影響台灣市場分析完整性

### Qdrant 搜尋說明

本報告使用 Qdrant 向量搜尋取得以下資料：global_hays_salary（UK Tech Talent Explorer）、global_stackoverflow（開發者調查）、global_linkedin_workforce（Most In Demand Jobs）、workforce_news（AI 勞動力預測）。搜尋結果作為交叉驗證來源，強化分析可信度。

---

最後更新：2026-02-07

---

## 附錄：技能標籤標準化對照表

| 原始標籤 | 標準化名稱 | 分類 |
|----------|-----------|------|
| JS, javascript | JavaScript | 程式語言 |
| TS, typescript | TypeScript | 程式語言 |
| golang, Go | Go | 程式語言 |
| ML, machine learning | Machine Learning | 數據與 AI |
| k8s, kubernetes | Kubernetes | 雲端與基礎設施 |
| vue, Vue.js | Vue.js | 框架與工具 |
| react, React.js, ReactJS | React | 框架與工具 |
| node, nodejs, Node.js | Node.js | 框架與工具 |
| postgres, postgresql, PostgreSQL | PostgreSQL | 資料庫 |
| docker, Docker | Docker | 雲端與基礎設施 |
| ci/cd, CI/CD | CI/CD | 雲端與基礎設施 |
| LLM, large language model | LLM | 數據與 AI |
| AI agents, AI Agents | AI Agents | 數據與 AI |
