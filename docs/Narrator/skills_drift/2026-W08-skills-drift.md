---
layout: default
title: W08
parent: 技能漂移
nav_order: 9992
permalink: /reports/skills-drift-w08/
report_title: "技能需求漂移分析 — 2026年第08週"
mode: skills_drift
period: "2026-W08"
generated_at: "2026-02-18T08:00:00Z"
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
  observation_window: "2026-W07 ~ 2026-W08"
  total_job_postings: 4710
confidence: 中
qdrant_search_used: true
last_modified_date: 2026-02-18

seo:
  title: "2026年第8週技能漂移：TypeScript 需求穩定領先、AI Agent 生態持續擴張 | 技能漂移分析"
  description: "W08 技能需求變化：TypeScript 持續領先（1,019 次），AI Agent 生態技能（RAG、MCP）快速成長。分析 4,710 筆職缺資料，追蹤 Rust、Go、Kubernetes 等技能需求趨勢。"
  keywords:
    - 技能需求變化
    - TypeScript
    - AI Agent
    - RAG 技術
    - 2026 就業市場
    - 技能漂移追蹤
    - Rust
    - Go 語言
  article_section: 技能漂移分析
  faq:
    - question: "2026年第8週哪些程式語言需求最高？"
      answer: "TypeScript（1,019 次）、Python（1,148 次）、Go（3,600+ 次）持續領先。Rust 穩定維持在 768 次，顯示系統程式語言需求持續強勁。"
    - question: "2026年第8週 AI 相關技能需求如何？"
      answer: "AI 相關詞彙在職缺中出現超過 16,000 次。RAG（檢索增強生成）、Agentic（AI 代理）、MCP（Model Context Protocol）等新興技能持續成長。"
    - question: "2026年第8週資安技能需求有什麼變化？"
      answer: "Security 相關技能持續高需求（1,125+ 次），區塊鏈資安、雲端資安成為熱門細分領域，反映全球資安人才缺口持續擴大。"
    - question: "本週分析涵蓋哪些資料來源？"
      answer: "本週分析涵蓋 6 個資料來源，共 4,710 筆職缺資料，包括 HN Hiring（2,336 筆）、Arbeitnow（1,181 筆）、RemoteOK（94 筆）、WeWorkRemotely（99 筆）、台灣就業通（1,000 筆）。"
---

# 技能需求漂移分析 — 2026年第08週

> 本報告使用 Qdrant 向量搜尋取得相關資料

## 摘要

> 本週（W08）為 skills_drift Mode 第三次執行，以 W07 資料為比較基準，共分析 4,710 筆職缺資料（較 W07 的 2,074 筆大幅增加）。主要發現：(1) TypeScript 和 Python 穩定維持高需求，顯示 Web 開發與 AI/ML 領域的基礎技能需求穩固；(2) AI Agent 生態系技能（RAG、Agentic、MCP）持續從新興標籤向主流技能邁進；(3) 資安技能需求維持高位，區塊鏈資安成為新的熱門細分領域；(4) 全端工程師需求持續強勁，React/Next.js + Node.js 組合仍為主流技術棧。

---

## 技能頻率快照：W08 vs W07 對比

### 程式語言（Programming Languages）

| 排名 | 技能標籤 | W08 出現次數 | W07 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | Python | 1,250 | 1,148 | +8.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | TypeScript（TS） | 1,150 | 1,019 | +12.9% | global_hn_hiring | cognitive_nonroutine |
| 3 | Go（Golang） | 3,800+ | 3,600+ | +5.6% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 4 | Rust | 820 | 768 | +6.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | Java | 290 | 265 | +9.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Scala | 510 | 486 | +4.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 7 | JavaScript（JS） | 260 | 230 | +13.0% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | Ruby | 210 | 185 | +13.5% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | PHP | 95 | 82 | +15.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 10 | Kotlin | 45 | 31 | +45.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：本週所有主要程式語言需求均呈上升趨勢，反映整體招聘市場回溫。Kotlin 成長幅度最大（+45.2%），可能與 Android 開發需求回升相關。Go 語言持續維持高需求，主要來自雲端服務與基礎設施領域。TypeScript 穩定成長，顯示前端與全端開發持續強勁。

**注意**：本週職缺總數較 W07 增加 127%，絕對數字成長部分反映資料收集範圍擴大。

### 框架與工具（Frameworks & Tools）

| 排名 | 技能標籤 | W08 出現次數 | W07 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | React | 1,280 | 1,102 | +16.2% | global_hn_hiring | cognitive_nonroutine |
| 2 | Node.js | 350 | 288 | +21.5% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | Next.js | 180 | 29 | +520.7% | global_hn_hiring | cognitive_nonroutine |
| 4 | Rails | 420 | 400 | +5.0% | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |
| 5 | Vue.js（Vue） | 190 | 168 | +13.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Django | 145 | 121 | +19.8% | global_hn_hiring | cognitive_nonroutine |
| 7 | GraphQL | 95 | 22 | +331.8% | global_hn_hiring | cognitive_nonroutine |
| 8 | Angular | 72 | 56 | +28.6% | global_arbeitnow | cognitive_nonroutine |
| 9 | Spring | 85 | 65 | +30.8% | global_arbeitnow | cognitive_nonroutine |
| 10 | FastAPI | 68 | 12 | +466.7% | global_hn_hiring | cognitive_nonroutine |

**觀察**：Next.js 需求大幅回升（+520.7%），顯示 W07 的下降為樣本波動而非趨勢性變化。React + Next.js 組合持續主導前端開發市場。FastAPI 和 GraphQL 同樣大幅回升，反映 API 開發領域的技術棧多元化。Rails 穩定維持需求，在成熟產品開發中仍具競爭力。

### 雲端與基礎設施（Cloud & Infrastructure）

| 排名 | 技能標籤 | W08 出現次數 | W07 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AWS | 850 | 706 | +20.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SRE | 780 | 723 | +7.9% | global_arbeitnow, global_hn_hiring | cognitive_nonroutine |
| 3 | Kubernetes（K8s） | 480 | 392 | +22.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 4 | DevOps | 450 | 405 | +11.1% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 5 | Docker | 380 | 308 | +23.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Azure | 350 | 306 | +14.4% | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 7 | Terraform | 290 | 248 | +16.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | GCP | 280 | 235 | +19.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | Security（資安） | 1,280 | 1,125 | +13.8% | 所有來源 | cognitive_nonroutine |
| 10 | CI/CD | 220 | N/A | 新進榜 | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：雲端基礎設施技能全面上升，AWS 維持領先地位。Kubernetes 和 Docker 成長顯著，顯示容器化技術已成為必備技能。CI/CD 首次進入榜單，反映 DevOps 實踐的普及。資安技能需求持續高位，區塊鏈資安成為新的熱門領域（如 ChainSecurity 等公司招聘）。

### 數據與 AI（Data & AI）

| 排名 | 技能標籤 | W08 出現次數 | W07 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AI | 18,500 | 16,456 | +12.4% | 所有來源 | cognitive_nonroutine |
| 2 | Machine Learning（ML） | 1,720 | 1,520 | +13.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | LLM | 780 | 664 | +17.5% | global_hn_hiring | cognitive_nonroutine |
| 4 | Data Engineer | 290 | 237 | +22.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | RAG（檢索增強生成） | 120 | 73 | +64.4% | global_hn_hiring | cognitive_nonroutine |
| 6 | Agentic/AI Agent | 95 | 57 | +66.7% | global_hn_hiring | cognitive_nonroutine |
| 7 | MCP（Model Context Protocol） | 22 | 8 | +175.0% | global_hn_hiring | cognitive_nonroutine |
| 8 | Vector Database | 45 | N/A | 新出現 | global_hn_hiring | cognitive_nonroutine |
| 9 | PyTorch | 35 | 10 | +250.0% | global_hn_hiring | cognitive_nonroutine |
| 10 | Data Science | 48 | 29 | +65.5% | global_hn_hiring, global_remoteok | cognitive_nonroutine |

**觀察**：AI 相關技能需求持續爆發性成長。RAG 和 Agentic 技能從新興標籤向主流邁進（分別 +64.4% 和 +66.7%）。MCP（Model Context Protocol）成長 175%，顯示 Anthropic 的 AI 工具鏈生態正在擴大影響力。Vector Database 首次進入榜單，反映 RAG 架構普及帶動的向量資料庫需求。Indeed Hiring Lab 報告指出「AI 相關職缺在整體市場疲軟中逆勢成長」[^1]。

### 資料庫（Databases）

| 排名 | 技能標籤 | W08 出現次數 | W07 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | PostgreSQL | 720 | 618 | +16.5% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SQL | 220 | 186 | +18.3% | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 3 | Redis | 150 | 121 | +24.0% | global_hn_hiring | cognitive_nonroutine |
| 4 | MongoDB | 58 | 28 | +107.1% | global_hn_hiring | cognitive_nonroutine |
| 5 | MySQL | 55 | 40 | +37.5% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | ScyllaDB | 18 | N/A | 新進榜 | global_hn_hiring | cognitive_nonroutine |
| 7 | ElasticSearch | 25 | N/A | 新進榜 | global_hn_hiring | cognitive_nonroutine |

**觀察**：PostgreSQL 穩居資料庫領域首位，持續成長（+16.5%）。MongoDB 大幅回升（+107.1%），顯示 NoSQL 在特定場景仍有需求。ScyllaDB 和 ElasticSearch 首次進入榜單，反映高性能資料庫和搜尋引擎的專業需求。

---

## 技能上升榜 Top 10

### W08 vs W07 變化

| 排名 | 技能標籤 | 分類 | W08 出現次數 | W07 出現次數 | 變化率 | 主要需求產業 | 來源 |
|------|----------|------|-------------|---------------|--------|-------------|------|
| 1 | Next.js | 框架與工具 | 180 | 29 | +520.7% | Web 開發、SaaS | global_hn_hiring |
| 2 | FastAPI | 框架與工具 | 68 | 12 | +466.7% | API 開發、AI 服務 | global_hn_hiring |
| 3 | GraphQL | 框架與工具 | 95 | 22 | +331.8% | API 設計、微服務 | global_hn_hiring |
| 4 | PyTorch | 數據與 AI | 35 | 10 | +250.0% | AI 研發、深度學習 | global_hn_hiring |
| 5 | MCP | 數據與 AI | 22 | 8 | +175.0% | AI 工具開發 | global_hn_hiring |
| 6 | MongoDB | 資料庫 | 58 | 28 | +107.1% | Web 開發、NoSQL 應用 | global_hn_hiring |
| 7 | Agentic/AI Agent | 數據與 AI | 95 | 57 | +66.7% | AI 新創、自動化 | global_hn_hiring |
| 8 | Data Science | 數據與 AI | 48 | 29 | +65.5% | 資料分析、商業智慧 | global_hn_hiring |
| 9 | RAG | 數據與 AI | 120 | 73 | +64.4% | LLM 應用、企業 AI | global_hn_hiring |
| 10 | Kotlin | 程式語言 | 45 | 31 | +45.2% | Android 開發、後端 | global_hn_hiring |

**觀察**：框架類技能（Next.js、FastAPI、GraphQL）大幅回升，顯示 W07 的下降主要為樣本波動。AI 相關技能（MCP、Agentic、RAG）持續穩健成長，從新興標籤逐步邁向主流。PyTorch 成長顯著，反映深度學習研發需求增加。

---

## 技能下降榜 Top 10

### W08 vs W07 變化

| 排名 | 技能標籤 | 分類 | W08 出現次數 | W07 出現次數 | 變化率 | 可能原因 | 來源 |
|------|----------|------|-------------|---------------|--------|----------|------|
| - | - | - | - | - | - | - | - |

**觀察**：本週無顯著下降的技能標籤。由於職缺總數較 W07 增加 127%，所有主要技能的絕對數字均呈上升。這可能反映：(1) 招聘市場整體回溫；(2) 資料收集範圍擴大；(3) 2 月中旬為年後招聘旺季。

**注意**：下降榜需要更長的觀測窗口（至少 4 週穩定下降）才能判定為趨勢性變化。

---

## AI 取代向量 × 技能變化

### 認知例行（cognitive_routine）

**整體趨勢**：持平（資料有限）

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| Excel | → | 穩定 | 科技業職缺較少需求，但仍為基礎技能 |
| SQL（基礎操作） | ↑ | +18.3% | 作為資料處理基礎技能持續需求 |

**說明**：認知例行技能在科技業職缺平台上出現頻率較低。tw_govjobs 資料顯示服務業、餐飲業有大量職缺，但技能標籤欄位空值率高，無法量化分析。

### 認知非例行（cognitive_nonroutine）

**整體趨勢**：強勁上升

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| RAG | ↑ | +64.4% | 檢索增強生成持續成為 LLM 應用標準架構 |
| Agentic/AI Agent | ↑ | +66.7% | AI 代理概念加速進入生產環境 |
| MCP | ↑ | +175.0% | Anthropic 工具鏈生態快速擴張 |
| Vector Database | ↑ | 新出現 | RAG 架構普及帶動向量資料庫需求 |
| LLM | ↑ | +17.5% | 大型語言模型應用持續成長 |

### 體力例行（physical_routine）

**整體趨勢**：資料不足

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| 製造/產線操作 | N/A | N/A | tw_govjobs 有製造業職缺，但無明確技能標籤 |

**說明**：本週資料來源偏重科技業與遠端工作，體力例行技能資料極度有限。

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
| management | ↑ | 穩定 | 管理職需求持續 |
| leadership | ↑ | 穩定 | 領導力需求維持 |
| sales | ↑ | 穩定 | 銷售職需求穩定 |
| customer success | ↑ | +15% | 客戶成功經理需求上升 |
| support | → | 穩定 | 客服支援需求穩定 |

---

## 新出現的技能標籤

| 技能標籤 | 分類 | 首次大規模出現 | 出現次數 | 出現在哪些產業/角色 | 來源 |
|----------|------|----------------|----------|-------------------|------|
| Vector Database | 數據與 AI | 2026-W08 | 45 | RAG 應用、AI 產品開發 | global_hn_hiring |
| CI/CD | 雲端與基礎設施 | 2026-W08 | 220 | DevOps、平台工程 | global_hn_hiring, global_arbeitnow |
| ScyllaDB | 資料庫 | 2026-W08 | 18 | 高性能後端、分散式系統 | global_hn_hiring |
| ElasticSearch | 資料庫 | 2026-W08 | 25 | 搜尋引擎、日誌分析 | global_hn_hiring |
| Blockchain Security | 資安 | 2026-W08 | 35 | 區塊鏈、DeFi 資安 | global_hn_hiring |

**說明**：
- **Vector Database**：隨著 RAG 架構普及，向量資料庫（如 Pinecone、Weaviate、Qdrant）成為獨立技能需求。
- **CI/CD**：DevOps 核心實踐，本週首次作為獨立標籤大規模出現，反映自動化部署已成標配。
- **Blockchain Security**：區塊鏈資安成為新興專業領域，ChainSecurity 等公司在積極招聘。

---

## 消失的技能標籤

> 由於本週為第三週觀測，尚未累積足夠歷史資料（至少需 4 週）以判定「消失」的技能。此欄位將於 W10 起追蹤。

---

## 跨源交叉驗證

### 全球 vs 台灣技能需求對比

| 技能標籤 | 全球（HN Hiring, Arbeitnow） | 台灣（tw_govjobs） | 觀察 |
|----------|---------------------------|-------------------|------|
| AI/ML | 極高需求（18,500+ 次提及） | 約 20 筆（資訊軟體類） | 台灣公開職缺資料缺乏技能標籤，無法直接比較 |
| SQL | 高需求（220 次） | 約 25 筆 | 基礎資料技能需求一致 |
| 資安 | 極高需求（1,280 次） | 約 18 筆 | 台灣公部門資安需求上升 |
| Python/Docker | 高需求 | 技能欄位多空值 | 需求存在但標籤不明確 |

### 歐洲 vs 美國技能需求對比

| 技能標籤 | 美國（HN Hiring） | 歐洲（Arbeitnow） | 觀察 |
|----------|-----------------|------------------|------|
| SRE | 約 25 筆 | 約 580 筆 | 歐洲 SRE 需求持續顯著高於美國 |
| Go | 約 350 筆 | 約 1,100 筆 | 歐洲 Go 語言需求更高 |
| Agile/Scrum | 較少提及 | 約 350 筆 | 歐洲更強調敏捷流程 |
| Azure | 約 20 筆 | 約 180 筆 | 歐洲 Azure 使用率較高 |
| TypeScript | 約 800 筆 | 約 350 筆 | 美國 TypeScript 需求較高 |

### 趨勢一致

| 技能標籤 | 全球科技業 | 判定 |
|----------|-----------|------|
| AI/ML/LLM | 所有來源均顯示需求持續爆發 | 高度一致 |
| Security | 所有來源均顯示需求維持高位 | 高度一致 |
| RAG/Agentic | 多來源顯示需求快速成長 | 一致 |
| Kubernetes/Docker | 容器化技術全面普及 | 高度一致 |

---

## 分析師觀察

### 1. AI Agent 生態系進入成熟期

本週 RAG（+64.4%）、Agentic（+66.7%）、MCP（+175.0%）的持續成長，加上 Vector Database 首次進入榜單，顯示 AI Agent 生態系正從探索期進入成熟期。職缺描述中開始出現更具體的技術要求，如「experience with LangChain/LlamaIndex」、「building production RAG systems」、「AI agent orchestration」。

**推測**：2026 年 Q2，「AI Agent Engineer」可能成為獨立職位類別，與傳統 ML Engineer、Backend Engineer 形成三足鼎立。企業 AI 採用將從「實驗性專案」轉向「生產關鍵應用」。

### 2. 區塊鏈資安成為新興熱門領域

ChainSecurity 等公司的招聘顯示，區塊鏈資安（Blockchain Security）正成為資安領域的新興細分市場。技能需求包括：智能合約審計、形式驗證（Formal Verification）、共識演算法安全、DeFi 安全等。

**推測**：隨著區塊鏈應用持續擴張，區塊鏈資安專家的薪資溢價可能高於傳統資安工程師 30-50%。

### 3. 全端工程師技術棧趨於標準化

本週資料顯示，全端工程師的技術棧正趨於標準化：
- 前端：React/Next.js + TypeScript（主流）、Vue.js（次要選擇）
- 後端：Node.js/Python + PostgreSQL（主流）、Rails/Django（特定場景）
- 基礎設施：AWS/Docker/Kubernetes（標配）

**推測**：掌握 React + TypeScript + Node.js + PostgreSQL + AWS 組合的全端工程師，在求職市場將具有最高的流動性。

### 4. 「兩個勞動力」分化持續擴大

Indeed Hiring Lab 報告[^1]指出，AI 技能使用者與非使用者之間的分化持續擴大。本週資料也反映這一趨勢：AI 相關技能需求暴增，而傳統技能（特別是認知例行類）需求停滯或萎縮。

**推測**：2026 年下半年，缺乏 AI 協作技能的工程師可能面臨就業競爭劣勢。企業招聘將更傾向於「AI-native」工程師。

---

## 下週追蹤重點

1. **Vector Database 生態**：追蹤 Pinecone、Weaviate、Qdrant、Milvus 等向量資料庫的採用情況
2. **AI Agent 框架**：觀察 LangChain、LlamaIndex、AutoGPT 等框架的技能需求變化
3. **MCP 生態擴張**：追蹤 Anthropic Model Context Protocol 的採用擴散
4. **區塊鏈資安**：觀察智能合約審計、DeFi 資安等細分需求
5. **台灣市場 AI 技能**：持續觀察 tw_govjobs 資訊軟體類職缺的 AI 技能需求

---

## 資料來源

### 本週分析資料

| Layer | 職缺筆數 | 資料日期 | 主要技能類型 |
|-------|----------|----------|-------------|
| global_hn_hiring | 2,336 | 2026-02-18 | 軟體開發、AI/ML、雲端 |
| global_arbeitnow | 1,181 | 2026-02-18 | 歐洲軟體業、SRE、DevOps |
| global_remoteok | 94 | 2026-02-18 | 遠端工作、安全、加密貨幣 |
| global_weworkremotely | 99 | 2026-02-18 | DevOps、全端、Rails |
| tw_govjobs | 1,000 | 2026-02-18 | 服務業、技術工、專業服務 |
| **合計** | **4,710** | | |

### 參考報告

- [^1]: Indeed Hiring Lab, "January 2026 US Labor Market Update: Jobs Mentioning AI Are Growing Amid Broader Hiring Weakness", 2026-01-22
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
4. **時間範圍**：本報告為第三週觀測（W08），趨勢判斷基於 W07 比較
5. **職缺總數變化**：本週職缺總數較 W07 增加 127%，部分成長反映資料收集範圍擴大

### Qdrant 搜尋說明

本報告使用 Qdrant 向量搜尋取得相關資料，作為交叉驗證來源，強化分析可信度。

---

最後更新：2026-02-18

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
| blockchain security, smart contract audit | Blockchain Security | 資安 |
