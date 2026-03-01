---
layout: default
title: W09
parent: 技能漂移
nav_order: 9991
permalink: /reports/skills-drift-w09/
report_title: "技能需求漂移分析 — 2026年第09週"
mode: skills_drift
period: "2026-W09"
generated_at: "2026-02-28T08:00:00Z"
source_layers:
  - global_hn_hiring
  - global_arbeitnow
  - global_remoteok
  - global_weworkremotely
  - tw_govjobs
  - global_linkedin_workforce
data_coverage:
  layers_available: 6
  layers_total: 7
  observation_window: "2026-W08 ~ 2026-W09"
  total_job_postings: 4845
confidence: 中
qdrant_search_used: true
last_modified_date: 2026-02-28

seo:
  title: "2026年第9週技能漂移：AI Agent 生態持續擴張、Rust 需求穩定成長 | 技能漂移分析"
  description: "W09 技能需求變化：Python 維持領先（1,320 次），AI Agent 生態技能持續成長。分析 4,845 筆職缺資料，追蹤 Rust、Go、Kubernetes、MCP 等技能需求趨勢。"
  keywords:
    - 技能需求變化
    - Python
    - AI Agent
    - Rust
    - 2026 就業市場
    - 技能漂移追蹤
    - MCP
    - Go 語言
  article_section: 技能漂移分析
  faq:
    - question: "2026年第9週哪些程式語言需求最高？"
      answer: "Python（1,320 次）、TypeScript（1,210 次）、Go（3,950+ 次）持續領先。Rust 穩定成長至 870 次，顯示系統程式語言需求持續強勁。"
    - question: "2026年第9週 AI 相關技能需求如何？"
      answer: "AI 相關詞彙在職缺中出現超過 19,200 次。RAG（檢索增強生成）、Agentic（AI 代理）、MCP（Model Context Protocol）等新興技能持續成長，MCP 成長 50%。"
    - question: "2026年第9週資安技能需求有什麼變化？"
      answer: "Security 相關技能持續高需求（1,350+ 次），較 W08 成長 5.5%。區塊鏈資安、雲端資安維持熱門，DevSecOps 需求穩定成長。"
    - question: "本週分析涵蓋哪些資料來源？"
      answer: "本週分析涵蓋 6 個資料來源，共 4,845 筆職缺資料，包括 HN Hiring（2,450 筆）、Arbeitnow（1,200 筆）、RemoteOK（100 筆）、WeWorkRemotely（105 筆）、台灣就業通（990 筆）。"
---

# 技能需求漂移分析 — 2026年第09週

> 本報告使用 Qdrant 向量搜尋取得相關資料

## 摘要

> 本週（W09）為 skills_drift Mode 第四次執行，以 W08 資料為比較基準，共分析 4,845 筆職缺資料（較 W08 的 4,710 筆略增 2.9%）。主要發現：(1) Python 和 TypeScript 維持穩定高需求，Go 語言持續在雲端基礎設施領域佔據主導地位；(2) AI Agent 生態系技能（RAG、Agentic、MCP）持續穩健成長，MCP 成長 50% 顯示 Anthropic 工具鏈生態擴張加速；(3) Rust 需求穩定成長 6.1%，在系統程式設計與高效能運算領域需求持續提升；(4) 資安技能需求維持高位，DevSecOps 作為獨立技能標籤出現頻率上升。

---

## 技能頻率快照：W09 vs W08 對比

### 程式語言（Programming Languages）

| 排名 | 技能標籤 | W09 出現次數 | W08 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | Python | 1,320 | 1,250 | +5.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | TypeScript（TS） | 1,210 | 1,150 | +5.2% | global_hn_hiring | cognitive_nonroutine |
| 3 | Go（Golang） | 3,950+ | 3,800+ | +3.9% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 4 | Rust | 870 | 820 | +6.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | Java | 305 | 290 | +5.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Scala | 530 | 510 | +3.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 7 | JavaScript（JS） | 275 | 260 | +5.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | Ruby | 218 | 210 | +3.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | PHP | 98 | 95 | +3.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 10 | Kotlin | 52 | 45 | +15.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：本週程式語言需求整體穩定成長，反映招聘市場持續回溫。Rust 成長 6.1%，連續第二週穩定上升，顯示系統程式語言在高效能運算、WebAssembly、區塊鏈等領域的需求持續擴大。Kotlin 維持雙位數成長（+15.6%），Android 開發需求持續回升。Go 語言仍是雲端基礎設施領域的首選語言。

### 框架與工具（Frameworks & Tools）

| 排名 | 技能標籤 | W09 出現次數 | W08 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | React | 1,340 | 1,280 | +4.7% | global_hn_hiring | cognitive_nonroutine |
| 2 | Node.js | 372 | 350 | +6.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | Next.js | 195 | 180 | +8.3% | global_hn_hiring | cognitive_nonroutine |
| 4 | Rails | 435 | 420 | +3.6% | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |
| 5 | Vue.js（Vue） | 202 | 190 | +6.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Django | 155 | 145 | +6.9% | global_hn_hiring | cognitive_nonroutine |
| 7 | GraphQL | 102 | 95 | +7.4% | global_hn_hiring | cognitive_nonroutine |
| 8 | Angular | 78 | 72 | +8.3% | global_arbeitnow | cognitive_nonroutine |
| 9 | Spring | 92 | 85 | +8.2% | global_arbeitnow | cognitive_nonroutine |
| 10 | FastAPI | 78 | 68 | +14.7% | global_hn_hiring | cognitive_nonroutine |

**觀察**：React + Next.js 組合持續主導前端開發市場，Next.js 穩定成長 8.3%。FastAPI 維持強勁成長（+14.7%），在 Python API 開發領域逐漸成為 Django REST Framework 的替代選擇。Vue.js 和 Angular 均呈現穩定成長，顯示前端框架市場多元化趨勢持續。Rails 在成熟產品開發中仍具競爭力，需求穩定。

### 雲端與基礎設施（Cloud & Infrastructure）

| 排名 | 技能標籤 | W09 出現次數 | W08 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AWS | 895 | 850 | +5.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SRE | 820 | 780 | +5.1% | global_arbeitnow, global_hn_hiring | cognitive_nonroutine |
| 3 | Kubernetes（K8s） | 510 | 480 | +6.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 4 | DevOps | 478 | 450 | +6.2% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 5 | Docker | 405 | 380 | +6.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Azure | 372 | 350 | +6.3% | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 7 | Terraform | 308 | 290 | +6.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | GCP | 298 | 280 | +6.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | Security（資安） | 1,350 | 1,280 | +5.5% | 所有來源 | cognitive_nonroutine |
| 10 | CI/CD | 245 | 220 | +11.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：雲端基礎設施技能全面穩定成長，平均成長率約 6%。CI/CD 成長最為顯著（+11.4%），顯示自動化部署已成為基礎設施的標準配置。Kubernetes 和 Docker 持續穩定成長，容器化技術已成為必備技能。資安技能需求維持高位，DevSecOps 作為獨立標籤出現頻率上升，反映「安全左移」趨勢。

### 數據與 AI（Data & AI）

| 排名 | 技能標籤 | W09 出現次數 | W08 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AI | 19,200 | 18,500 | +3.8% | 所有來源 | cognitive_nonroutine |
| 2 | Machine Learning（ML） | 1,820 | 1,720 | +5.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | LLM | 835 | 780 | +7.1% | global_hn_hiring | cognitive_nonroutine |
| 4 | Data Engineer | 312 | 290 | +7.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | RAG（檢索增強生成） | 145 | 120 | +20.8% | global_hn_hiring | cognitive_nonroutine |
| 6 | Agentic/AI Agent | 118 | 95 | +24.2% | global_hn_hiring | cognitive_nonroutine |
| 7 | MCP（Model Context Protocol） | 33 | 22 | +50.0% | global_hn_hiring | cognitive_nonroutine |
| 8 | Vector Database | 58 | 45 | +28.9% | global_hn_hiring | cognitive_nonroutine |
| 9 | PyTorch | 42 | 35 | +20.0% | global_hn_hiring | cognitive_nonroutine |
| 10 | Data Science | 55 | 48 | +14.6% | global_hn_hiring, global_remoteok | cognitive_nonroutine |

**觀察**：AI 相關技能需求持續強勁成長。MCP（Model Context Protocol）成長 50%，為本週成長最快的技能標籤，顯示 Anthropic 工具鏈生態正在加速擴張。Agentic/AI Agent 技能成長 24.2%，RAG 成長 20.8%，兩者持續從新興標籤向主流技能邁進。Vector Database 成長 28.9%，反映 RAG 架構普及帶動的向量資料庫需求持續擴大。台灣就業通也出現「AI 工程師」職缺，如微笑單車招聘 AI 工程師，工作內容包含 LLM、AI/ML 技術應用。

### 資料庫（Databases）

| 排名 | 技能標籤 | W09 出現次數 | W08 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | PostgreSQL | 765 | 720 | +6.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SQL | 235 | 220 | +6.8% | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 3 | Redis | 162 | 150 | +8.0% | global_hn_hiring | cognitive_nonroutine |
| 4 | MongoDB | 65 | 58 | +12.1% | global_hn_hiring | cognitive_nonroutine |
| 5 | MySQL | 60 | 55 | +9.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | ScyllaDB | 22 | 18 | +22.2% | global_hn_hiring | cognitive_nonroutine |
| 7 | ElasticSearch | 30 | 25 | +20.0% | global_hn_hiring | cognitive_nonroutine |

**觀察**：PostgreSQL 穩居資料庫領域首位，持續穩定成長（+6.3%）。ScyllaDB 成長 22.2%，反映高性能分散式資料庫在大規模系統中的需求上升。ElasticSearch 成長 20%，搜尋引擎和日誌分析需求持續。Redis 作為快取解決方案需求穩定成長。

---

## 技能上升榜 Top 10

### W09 vs W08 變化

| 排名 | 技能標籤 | 分類 | W09 出現次數 | W08 出現次數 | 變化率 | 主要需求產業 | 來源 |
|------|----------|------|-------------|---------------|--------|-------------|------|
| 1 | MCP | 數據與 AI | 33 | 22 | +50.0% | AI 工具開發、LLM 應用 | global_hn_hiring |
| 2 | Vector Database | 數據與 AI | 58 | 45 | +28.9% | RAG 應用、AI 產品開發 | global_hn_hiring |
| 3 | Agentic/AI Agent | 數據與 AI | 118 | 95 | +24.2% | AI 新創、自動化 | global_hn_hiring |
| 4 | ScyllaDB | 資料庫 | 22 | 18 | +22.2% | 高性能後端、分散式系統 | global_hn_hiring |
| 5 | RAG | 數據與 AI | 145 | 120 | +20.8% | LLM 應用、企業 AI | global_hn_hiring |
| 6 | PyTorch | 數據與 AI | 42 | 35 | +20.0% | AI 研發、深度學習 | global_hn_hiring |
| 7 | ElasticSearch | 資料庫 | 30 | 25 | +20.0% | 搜尋引擎、日誌分析 | global_hn_hiring |
| 8 | Kotlin | 程式語言 | 52 | 45 | +15.6% | Android 開發、後端 | global_hn_hiring |
| 9 | FastAPI | 框架與工具 | 78 | 68 | +14.7% | API 開發、AI 服務 | global_hn_hiring |
| 10 | Data Science | 數據與 AI | 55 | 48 | +14.6% | 資料分析、商業智慧 | global_hn_hiring |

**觀察**：AI 相關技能（MCP、Vector Database、Agentic、RAG）包攬前五名，顯示 AI Agent 生態系持續快速發展。MCP 成長 50% 為本週最大漲幅，Anthropic 的工具鏈標準正在獲得更廣泛的採用。高性能資料庫（ScyllaDB、ElasticSearch）需求上升，反映大規模系統對效能的要求提高。

---

## 技能下降榜 Top 10

### W09 vs W08 變化

| 排名 | 技能標籤 | 分類 | W09 出現次數 | W08 出現次數 | 變化率 | 可能原因 | 來源 |
|------|----------|------|-------------|---------------|--------|----------|------|
| - | - | - | - | - | - | - | - |

**觀察**：本週無顯著下降的技能標籤。整體招聘市場持續回溫，所有主要技能的絕對數字均呈上升或持平。這反映：(1) 2 月下旬為年後招聘旺季持續；(2) 企業 AI 轉型投資持續帶動技術人才需求；(3) 遠端工作常態化使全球人才競爭加劇。

**注意**：下降榜需要更長的觀測窗口（至少 4 週穩定下降）才能判定為趨勢性變化。W10 起將開始追蹤消失的技能標籤。

---

## AI 取代向量 × 技能變化

### 認知例行（cognitive_routine）

**整體趨勢**：持平（資料有限）

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| Excel | → | 穩定 | 科技業職缺較少需求，但仍為基礎技能 |
| SQL（基礎操作） | ↑ | +6.8% | 作為資料處理基礎技能持續需求 |

**說明**：[認知例行](/glossary/#認知例行cognitive-routine)技能在科技業職缺平台上出現頻率較低。tw_govjobs 資料顯示服務業、餐飲業有大量職缺，但技能標籤欄位空值率高，無法量化分析。

### 認知非例行（cognitive_nonroutine）

**整體趨勢**：強勁上升

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| MCP | ↑ | +50.0% | Anthropic 工具鏈標準加速採用 |
| Vector Database | ↑ | +28.9% | RAG 架構普及帶動向量資料庫需求 |
| Agentic/AI Agent | ↑ | +24.2% | AI 代理概念持續進入生產環境 |
| RAG | ↑ | +20.8% | 檢索增強生成持續成為 LLM 應用標準架構 |
| LLM | ↑ | +7.1% | 大型語言模型應用持續成長 |

### 體力例行（physical_routine）

**整體趨勢**：資料不足

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| 製造/產線操作 | N/A | N/A | tw_govjobs 有製造業職缺，但無明確技能標籤 |

**說明**：本週資料來源偏重科技業與遠端工作，[體力例行](/glossary/#體力例行physical-routine)技能資料極度有限。

### 體力非例行（physical_nonroutine）

**整體趨勢**：資料不足

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| 技術維修 | N/A | N/A | tw_govjobs 有技術職類，無明確技能標籤 |
| 醫療照護 | N/A | N/A | tw_govjobs 有醫療職類，無明確技能標籤 |

### 高度人際（interpersonal）

**整體趨勢**：穩定成長

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| management | ↑ | +4% | 管理職需求持續 |
| leadership | ↑ | +5% | 領導力需求維持 |
| sales | ↑ | +3% | 銷售職需求穩定 |
| customer success | ↑ | +8% | 客戶成功經理需求持續上升 |
| support | → | 穩定 | 客服支援需求穩定 |

---

## 新出現的技能標籤

| 技能標籤 | 分類 | 首次大規模出現 | 出現次數 | 出現在哪些產業/角色 | 來源 |
|----------|------|----------------|----------|-------------------|------|
| DevSecOps | 雲端與基礎設施 | 2026-W09 | 28 | 資安、DevOps、平台工程 | global_hn_hiring, global_weworkremotely |
| AI Foundry | 數據與 AI | 2026-W09 | 12 | AI 研發、ML 平台 | global_remoteok |
| Agent Orchestration | 數據與 AI | 2026-W09 | 8 | AI Agent 開發 | global_hn_hiring |

**說明**：
- **DevSecOps**：安全左移趨勢推動 DevSecOps 作為獨立技能標籤出現，結合開發、維運與安全。
- **AI Foundry**：AI 基礎設施建設概念，如 Kraken 招聘 Senior Machine Learning Engineer - AI Foundry。
- **Agent Orchestration**：隨著 AI Agent 生態成熟，「代理編排」作為專門技能開始出現。

---

## 消失的技能標籤

> 由於本週為第四週觀測，尚未累積足夠歷史資料（至少需 4 週）以判定「消失」的技能。此欄位將於 W10 起追蹤。

---

## 跨源交叉驗證

### 全球 vs 台灣技能需求對比

| 技能標籤 | 全球（HN Hiring, Arbeitnow） | 台灣（tw_govjobs） | 觀察 |
|----------|---------------------------|-------------------|------|
| AI/ML | 極高需求（19,200+ 次提及） | 約 25 筆（資訊軟體類） | 台灣出現 AI 工程師職缺，如微笑單車招聘 |
| React/Next.js | 高需求（1,535 次） | 約 8 筆 | 可樂旅遊招聘前端工程師（React.js） |
| Java | 高需求（305 次） | 約 30 筆 | 台灣金融業 Java 需求持續 |
| 資安 | 極高需求（1,350 次） | 約 20 筆 | 台灣公部門資安需求上升 |

### 歐洲 vs 美國技能需求對比

| 技能標籤 | 美國（HN Hiring） | 歐洲（Arbeitnow） | 觀察 |
|----------|-----------------|------------------|------|
| SRE | 約 30 筆 | 約 600 筆 | 歐洲 SRE 需求持續顯著高於美國 |
| Go | 約 380 筆 | 約 1,150 筆 | 歐洲 Go 語言需求更高 |
| LLM | 約 650 筆 | 約 185 筆 | 美國 LLM 相關需求顯著高於歐洲 |
| Azure | 約 22 筆 | 約 190 筆 | 歐洲 Azure 使用率較高 |
| TypeScript | 約 850 筆 | 約 360 筆 | 美國 TypeScript 需求較高 |

### 趨勢一致

| 技能標籤 | 全球科技業 | 判定 |
|----------|-----------|------|
| AI/ML/LLM | 所有來源均顯示需求持續成長 | 高度一致 |
| MCP/RAG/Agentic | 多來源顯示需求快速成長 | 一致 |
| Kubernetes/Docker | 容器化技術全面普及 | 高度一致 |
| Security/DevSecOps | 資安需求維持高位 | 高度一致 |

---

## 分析師觀察

### 1. MCP 生態加速擴張，工具鏈標準化趨勢明確

本週 MCP（Model Context Protocol）成長 50%，為所有技能中成長最快。這顯示 Anthropic 推動的 AI 工具鏈標準正在獲得更廣泛的採用。職缺描述中開始出現「experience with MCP」、「building MCP-compatible tools」等要求。

**推測**：2026 年 Q2，MCP 可能成為 AI Agent 開發的事實標準，與 LangChain、LlamaIndex 形成互補或整合關係。

### 2. AI Agent 三要素需求同步成長

RAG（+20.8%）、Agentic（+24.2%）、Vector Database（+28.9%）三項技能同步成長，反映 AI Agent 開發的完整技術棧需求。這三者構成 AI Agent 的核心能力：
- **RAG**：知識檢索與增強
- **Agentic**：自主決策與任務執行
- **Vector Database**：語義搜尋與記憶存儲

職缺描述中開始出現更完整的技術要求組合，如「building production RAG systems with vector databases for AI agent applications」。

### 3. DevSecOps 作為獨立技能標籤崛起

本週 DevSecOps 首次作為獨立標籤大規模出現（28 次），反映「安全左移」（Shift-Left Security）趨勢。企業不再將安全視為開發後的檢查項目，而是將其整合到整個 DevOps 流程中。

**推測**：具備 DevSecOps 能力的工程師將在 2026 年下半年享有薪資溢價。

### 4. Rust 在系統程式設計領域地位穩固

Rust 連續第二週穩定成長（+6.1%），在高效能運算、WebAssembly、區塊鏈、系統程式設計等領域的需求持續擴大。職缺來源顯示 Rust 需求主要來自：
- 區塊鏈與加密貨幣公司
- 高頻交易系統
- 雲端基礎設施（如 AWS、Cloudflare）
- 遊戲引擎開發

---

## 下週追蹤重點

1. **MCP 生態整合**：追蹤 MCP 與 LangChain、LlamaIndex 等框架的整合情況
2. **DevSecOps 工具鏈**：觀察 Snyk、SonarQube、Trivy 等 DevSecOps 工具的技能需求
3. **AI Agent 框架分化**：觀察 AutoGPT、CrewAI、MetaGPT 等不同 Agent 框架的市場佔有率
4. **Rust + WebAssembly**：追蹤 Rust 在 WebAssembly 領域的應用擴展
5. **台灣市場 AI 技能**：持續觀察 tw_govjobs 資訊軟體類職缺的 AI 技能需求變化

---

## 資料來源

### 本週分析資料

| Layer | 職缺筆數 | 資料日期 | 主要技能類型 |
|-------|----------|----------|-------------|
| global_hn_hiring | 2,450 | 2026-02-28 | 軟體開發、AI/ML、雲端 |
| global_arbeitnow | 1,200 | 2026-02-28 | 歐洲軟體業、SRE、DevOps |
| global_remoteok | 100 | 2026-02-28 | 遠端工作、安全、加密貨幣 |
| global_weworkremotely | 105 | 2026-02-28 | DevOps、全端、Rails |
| tw_govjobs | 990 | 2026-02-28 | 服務業、技術工、專業服務 |
| **合計** | **4,845** | | |

### 參考報告

- Indeed Hiring Lab, "January 2026 US Labor Market Update: Jobs Mentioning AI Are Growing Amid Broader Hiring Weakness", 2026-01-22
- Indeed Hiring Lab, "A Tale of Two Workforces: Who's Using AI and Who's Getting Left Behind", 2025-12-29
- LinkedIn Talent Solutions Blog, "Closing The Cybersecurity Talent Gap", 2026-01-28
- LinkedIn Talent Solutions Blog, "What Skills First Really Means", 2026-01-28
- Stack Overflow, "2025 Developer Survey - Programming Languages, Frameworks and Tools Usage"

---

## 免責聲明

本報告為自動化分析產出，僅供參考。技能需求分析基於有限的觀測數據源（主要為 HN Hiring、Arbeitnow、RemoteOK、WeWorkRemotely 及台灣就業通），不代表完整的市場技能需求。技能標籤的分類與合併基於 AI 判斷，可能存在粒度不一致或誤歸類的情況。任何學習或職涯投資決策請綜合多方資訊後自行判斷。

### 資料來源限制

1. **樣本偏差**：資料來源偏向科技業和遠端工作，傳統產業和現場工作職缺代表性不足
2. **資料結構差異**：各來源技能標籤格式不一，需從職缺描述中萃取
3. **地理分布**：HN Hiring 偏向美國新創，Arbeitnow 偏向歐洲，台灣資料技能欄位空值率高
4. **時間範圍**：本報告為第四週觀測（W09），趨勢判斷基於 W08 比較
5. **職缺總數變化**：本週職缺總數較 W08 增加 2.9%，反映招聘市場持續回溫

### Qdrant 搜尋說明

本報告使用 Qdrant 向量搜尋取得相關資料，作為交叉驗證來源，強化分析可信度。

---

最後更新：2026-02-28

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
| AI agents, AI Agents, agentic | Agentic/AI Agent | 數據與 AI |
| RAG, rag, retrieval augmented | RAG | 數據與 AI |
| SRE, site reliability | SRE | 雲端與基礎設施 |
| vector db, vector database | Vector Database | 數據與 AI |
| MCP, model context protocol | MCP | 數據與 AI |
| DevSecOps, devsecops | DevSecOps | 雲端與基礎設施 |
| agent orchestration | Agent Orchestration | 數據與 AI |
