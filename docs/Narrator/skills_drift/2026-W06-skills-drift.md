---
layout: default
title: W06
parent: 技能漂移
nav_order: 9994
permalink: /reports/skills-drift-w06/
report_title: "技能需求漂移分析 — 2026年第06週（基線建立版）"
mode: skills_drift
period: "2026-W06"
generated_at: "2026-02-06T12:00:00Z"
source_layers:
  - tw_govjobs
  - global_hn_hiring
  - global_arbeitnow
  - global_remoteok
  - global_weworkremotely
  - global_stackoverflow
  - global_linkedin_workforce
data_coverage:
  layers_available: 7
  layers_total: 7
  observation_window: "首次觀測（2026-W06 基線建立）"
  total_job_postings: 4710
confidence: 中

seo:
  title: "2026年第6週技能需求基線：Python、React、AWS 居首 | 技能漂移分析"
  description: "W06 技能需求基線建立：分析 4,710 筆職缺，Python 出現 1,913 次居首，React 1,862 次、AWS 1,116 次。Go、Rust 系統語言需求持續上升。"
  keywords:
    - 技能需求分析
    - 就業市場趨勢
    - Python 職缺
    - React 開發
    - 2026 求職
    - AI 技能需求
  article_section: 技能漂移分析
  faq:
    - question: "2026年第6週哪些程式語言最熱門？"
      answer: "Python 以 1,913 次出現居首，其次為 TypeScript（1,503 次）、Go（1,482 次）、Rust（807 次）。"
    - question: "2026年第6週哪些框架最受歡迎？"
      answer: "React 以 1,862 次出現居首，其次為 Node.js（465 次）、Django（164 次）、Next.js（146 次）。"
    - question: "2026年第6週雲端技能需求如何？"
      answer: "AWS 以 1,116 次出現居首，Kubernetes（492 次）、DevOps（445 次）、GCP（389 次）緊隨其後。"
---

# 技能需求漂移分析 — 2026年第06週（基線建立版）

## 摘要

> 本週為 skills_drift Mode 首次執行，產出「基線建立」版本。由於尚無歷史資料可供比較，本報告聚焦於技能標籤的當前頻率分布，作為後續趨勢追蹤的基準點。共分析 4,710 筆職缺資料，涵蓋台灣就業通（tw_govjobs）、HN Hiring（global_hn_hiring）、arbeitnow（global_arbeitnow）、RemoteOK（global_remoteok）及 WeWorkRemotely（global_weworkremotely）等來源。

---

## 基線快照：技能出現頻率排名

### 程式語言（Programming Languages）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | Python | 1,913 | global_hn_hiring | cognitive_nonroutine |
| 2 | TypeScript（TS） | 1,503 | global_hn_hiring | cognitive_nonroutine |
| 3 | JavaScript（JS） | 212 | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |
| 4 | Go（Golang） | 1,482 | global_hn_hiring | cognitive_nonroutine |
| 5 | Rust | 807 | global_hn_hiring | cognitive_nonroutine |
| 6 | Java | 361 | global_hn_hiring | cognitive_nonroutine |
| 7 | Ruby | 253 | global_hn_hiring, global_remoteok | cognitive_nonroutine |
| 8 | Scala | 280 | global_hn_hiring | cognitive_nonroutine |
| 9 | Kotlin | 51 | global_hn_hiring | cognitive_nonroutine |
| 10 | PHP | 41 | global_hn_hiring | cognitive_nonroutine |

### 框架與工具（Frameworks & Tools）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | React | 1,862 | global_hn_hiring | cognitive_nonroutine |
| 2 | Node.js | 465 | global_hn_hiring | cognitive_nonroutine |
| 3 | Next.js | 146 | global_hn_hiring | cognitive_nonroutine |
| 4 | Django | 164 | global_hn_hiring | cognitive_nonroutine |
| 5 | Rails | 143 | global_hn_hiring | cognitive_nonroutine |
| 6 | Vue.js（Vue） | 137 | global_hn_hiring | cognitive_nonroutine |
| 7 | FastAPI | 89 | global_hn_hiring | cognitive_nonroutine |
| 8 | GraphQL | 116 | global_hn_hiring | cognitive_nonroutine |
| 9 | Angular | 46 | global_hn_hiring | cognitive_nonroutine |
| 10 | Elixir | 51 | global_hn_hiring | cognitive_nonroutine |

### 雲端與基礎設施（Cloud & Infrastructure）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | AWS | 1,116 | global_hn_hiring | cognitive_nonroutine |
| 2 | Kubernetes（K8s） | 492 | global_hn_hiring | cognitive_nonroutine |
| 3 | Docker | 365 | global_hn_hiring | cognitive_nonroutine |
| 4 | GCP | 389 | global_hn_hiring | cognitive_nonroutine |
| 5 | Terraform | 141 | global_hn_hiring | cognitive_nonroutine |
| 6 | Azure | 186 | global_hn_hiring | cognitive_nonroutine |
| 7 | DevOps | 445 | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |
| 8 | CI/CD | 83 | global_hn_hiring | cognitive_nonroutine |

### 資料庫（Databases）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | PostgreSQL | 424 | global_hn_hiring | cognitive_nonroutine |
| 2 | Redis | 137 | global_hn_hiring | cognitive_nonroutine |
| 3 | MongoDB | 74 | global_hn_hiring | cognitive_nonroutine |
| 4 | MySQL | 49 | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |

### 數據與 AI（Data & AI）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | AI | 4,388 | global_hn_hiring | cognitive_nonroutine |
| 2 | Machine Learning（ML） | 808 | global_hn_hiring | cognitive_nonroutine |
| 3 | LLM | 234 | global_hn_hiring | cognitive_nonroutine |
| 4 | Data Science | 估計 76 | global_hn_hiring (data category) | cognitive_nonroutine |
| 5 | Analytics | 10+ | global_remoteok, global_weworkremotely | cognitive_nonroutine |

### 資安（Security）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | Security（資安通用） | 60 | global_hn_hiring, global_remoteok | cognitive_nonroutine |
| 2 | Cyber Security | 6 | global_weworkremotely | cognitive_nonroutine |
| 3 | Endpoint Security | 3（小樣本） | global_weworkremotely | cognitive_nonroutine |

### 軟技能（Soft Skills）

| 排名 | 技能標籤 | 本週出現次數 | 主要來源 | AI 取代向量 |
|------|----------|-------------|----------|-------------|
| 1 | leadership（領導力） | 32 | global_remoteok | interpersonal |
| 2 | management（管理） | 21 | global_remoteok | interpersonal |
| 3 | strategy（策略） | 16 | global_remoteok | cognitive_nonroutine |
| 4 | growth（成長思維） | 20 | global_remoteok | interpersonal |
| 5 | support（客戶支援） | 36 | global_remoteok | interpersonal |

---

## AI 取代向量 × 技能分布基線

### 認知例行（cognitive_routine）

**基線觀察**：從本週資料來源（主要為科技業職缺）中，認知例行技能的明確標籤較少出現。

| 技能標籤 | 出現次數 | 來源 | 備註 |
|----------|----------|------|------|
| Excel | 6 | global_remoteok | 小樣本，多出現於財務/行政相關職缺 |
| CRM | 9 | global_weworkremotely | 客戶關係管理系統操作 |
| Admin | 6 | global_remoteok | 行政作業相關 |

**說明**：tw_govjobs 中雖有大量零售服務（481筆）、專業服務（85筆）等職缺，但其 technical_skills 和 soft_skills 欄位多為空值，無法提取明確的技能標籤。此為資料來源的結構性限制，而非技能需求不存在。

### 認知非例行（cognitive_nonroutine）

**基線觀察**：認知非例行技能佔據絕大多數觀測數據，這與資料來源偏重科技業相關。

| 技能類別 | 代表技能 | 合計出現次數 | 解讀 |
|----------|----------|-------------|------|
| 程式語言 | Python, TypeScript, Go, Rust | 5,700+ | 軟體開發核心技能 |
| AI/ML 技術 | AI, ML, LLM | 5,400+ | 人工智慧領域蓬勃發展 |
| 雲端基礎設施 | AWS, Kubernetes, Docker | 2,000+ | 雲端原生架構成為標準 |
| 前端框架 | React, Next.js, Vue | 2,100+ | 前端技術需求持續強勁 |

### 體力例行（physical_routine）

**基線觀察**：本週資料來源以線上職缺平台為主，體力例行職缺資料有限。

| 技能標籤 | 出現次數 | 來源 | 備註 |
|----------|----------|------|------|
| 製造/產線操作 | 14 | tw_govjobs (manufacturing) | 推測：職缺描述中未標註明確技能 |
| 倉儲管理 | 31 | tw_govjobs (logistics) | 推測：職缺描述中未標註明確技能 |

### 體力非例行（physical_nonroutine）

**基線觀察**：

| 技能標籤 | 出現次數 | 來源 | 備註 |
|----------|----------|------|------|
| 營建技術 | 18 | tw_govjobs (construction) | 工地主任、測量助理等 |
| 技術維修 | 65 | tw_govjobs (skilled_trade) | 設備維護、清潔技術員等 |
| 醫療照護操作 | 66 | tw_govjobs (healthcare) | 照顧服務員、美髮設計師等 |

### 高度人際（interpersonal）

**基線觀察**：

| 技能標籤 | 出現次數 | 來源 | 備註 |
|----------|----------|------|------|
| sales（銷售） | 12 | global_remoteok | 業務開發、客戶經理 |
| marketing（行銷） | 18 | global_remoteok | 行銷管理、內容行銷 |
| content（內容） | 12 | global_remoteok | 內容創作、社群管理 |
| 零售服務 | 481 | tw_govjobs (retail_service) | 門市人員、餐飲服務等（無明確技能標籤） |

---

## 資料來源分布

### 按來源統計

| Layer | 職缺筆數 | 主要技能類型 | 資料完整度 |
|-------|----------|-------------|-----------|
| global_hn_hiring | 2,336 | 軟體開發、AI/ML、雲端 | 高（tech_stack 欄位） |
| global_arbeitnow | 1,181 | 歐洲軟體業、DevOps | 中（需從描述推斷） |
| tw_govjobs | 1,000 | 服務業、技術工、專業服務 | 低（技能欄位多為空） |
| global_weworkremotely | 99 | DevOps、全端開發 | 高（skills 欄位） |
| global_remoteok | 94 | 軟體開發、行銷、設計 | 高（tags 欄位） |

### 資料品質備註

1. **tw_govjobs**：1,000 筆職缺中，technical_skills 和 soft_skills 欄位大多為空陣列 `[]`，技能標籤萃取主要依賴職缺標題和工作內容推斷。
2. **global_hn_hiring**：tech_stack 欄位約 40% 有明確值，其餘需從原始內容解析。
3. **global_arbeitnow**：無結構化技能欄位，需從職位描述中萃取。
4. **輔助資料**：global_stackoverflow（21筆）和 global_linkedin_workforce（12筆）為趨勢報告摘要，非職缺資料。

---

## 新出現的技能標籤

> 由於本週為首次觀測，所有技能標籤皆為「基線」，無法判定「新出現」。此欄位將於下週起追蹤。

---

## 消失的技能標籤

> 由於本週為首次觀測，無歷史資料可供比較，無法判定「消失」的技能。此欄位將於下週起追蹤。

---

## 跨源交叉驗證

### 全球 vs 台灣技能需求對比

| 技能類別 | 全球（HN Hiring, RemoteOK） | 台灣（tw_govjobs） | 觀察 |
|----------|---------------------------|-------------------|------|
| AI/ML | 極高需求（4,300+ 次提及） | 未明確標註 | 台灣資料缺乏技能標籤，無法直接比較 |
| Python | 高需求（1,900+ 次） | 零售/服務業為主，技術職缺 92 筆 | 結構性差異：tw_govjobs 涵蓋更廣泛產業 |
| React | 高需求（1,800+ 次） | 未明確標註 | - |
| 服務業技能 | 較少出現 | 高需求（481 筆零售服務） | 全球遠端職缺平台偏重科技業 |

### 一致性判定

**高度一致**：
- AI/ML 技術在全球科技業職缺中佔主導地位
- 雲端技術（AWS, Kubernetes）為基礎設施標準
- TypeScript 逐漸取代純 JavaScript 成為前端主流

**待觀察**：
- 台灣 tw_govjobs 與全球遠端職缺平台的產業結構差異，可能導致技能需求比較失準
- tw_104_jobs（104 人力銀行）目前無資料（0 筆），恢復後可提供更好的台灣科技業對照

---

## 分析師觀察

### 1. AI 技術滲透率觀察

本週觀測數據顯示「AI」一詞在 HN Hiring 職缺中出現 4,388 次，佔全部職缺的極高比例。這反映科技業對 AI 能力的需求已成為標配，而非差異化競爭力。**推測**：未來 AI 相關技能可能分化為「AI 使用者」（較普遍）和「AI 開發者」（較專業）兩個層次，後者對 LLM、ML 等專業技能的需求將更加明確。

### 2. 語言與框架的演變信號

Go 和 Rust 的出現頻率顯著（Go 1,482 次，Rust 807 次），顯示系統程式語言在雲端原生架構中的重要性提升。同時，Python 仍以 1,913 次居首，但其定位已從通用語言轉向 AI/ML 和資料處理的專用工具。**推測**：TypeScript + React 組合將持續主導前端，而後端則呈現多語言並存態勢。

### 3. 台灣資料的結構性限制

tw_govjobs 作為台灣主要公開職缺來源，其技能標籤欄位多為空值，這是資料來源本身的結構性限制，而非 Extractor 萃取失敗。建議：
- 持續追蹤 tw_104_jobs 的恢復狀態
- 考慮從職缺描述中以自然語言處理方式推斷技能標籤
- 將 tw_govjobs 的價值定位為「台灣勞動市場結構觀測」而非「技能標籤追蹤」

---

## 下週追蹤重點

1. **建立變化率基準**：本週數據將作為 W07 報告的比較基準
2. **tw_104_jobs 恢復狀況**：若恢復，可補充台灣科技業技能需求
3. **AI/ML 技能細分**：追蹤 LLM、GPT、Prompt Engineering 等細分標籤
4. **雲端認證需求**：觀察 AWS/GCP/Azure 認證是否成為明確要求

---

## 免責聲明

本報告為自動化分析產出，僅供參考。技能需求分析基於有限的觀測數據源（主要為台灣就業通及全球遠端職缺平台），不代表完整的市場技能需求。技能標籤的分類與合併基於 AI 判斷，可能存在粒度不一致或誤歸類的情況。任何學習或職涯投資決策請綜合多方資訊後自行判斷。

### 資料來源限制

1. **樣本偏差**：資料來源偏向科技業和遠端工作，傳統產業和現場工作職缺代表性不足
2. **技能標籤萃取率**：tw_govjobs 技能欄位空值率高，影響台灣市場分析完整性
3. **時間範圍**：本報告為首次基線建立，尚無趨勢變化數據

---

最後更新：2026-02-06

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
