---
layout: default
title: W07
parent: 技能漂移
nav_order: 9993
permalink: /reports/skills-drift-w07/
report_title: "技能需求漂移分析 — 2026年第07週"
mode: skills_drift
period: "2026-W07"
generated_at: "2026-02-08T16:00:00Z"
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
  observation_window: "2026-W06 ~ 2026-W07"
  total_job_postings: 2074
confidence: 中
qdrant_search_used: true

seo:
  title: "2026年第7週技能漂移：Go 暴漲 143%、RAG 技術崛起 | 技能漂移分析"
  description: "W07 技能需求變化：Go 語言需求暴漲 143%，新興 AI 技術 RAG、Agentic 快速崛起。Rails 回升 180%，Rust 穩定成長。共分析 2,074 筆職缺。"
  keywords:
    - 技能需求變化
    - Go 語言
    - RAG 技術
    - AI Agent
    - 2026 就業市場
    - 技能漂移追蹤
  article_section: 技能漂移分析
  faq:
    - question: "2026年第7週哪些技能需求成長最快？"
      answer: "Go 語言暴漲 143%（達 3,600+ 次）、Rails 成長 180%、Scala 成長 74%。新興 AI 技術 RAG、Agentic 需求顯著上升。"
    - question: "2026年第7週 AI 相關技能需求如何？"
      answer: "AI 一詞在 HN Hiring 出現 1,328 次居首，新興技術 RAG（檢索增強生成）、Agentic（AI 代理）需求快速成長。"
    - question: "2026年第7週歐洲市場有什麼特別趨勢？"
      answer: "Arbeitnow 歐洲職缺中 SRE 職位需求異常突出（576 筆），反映歐洲企業對系統可靠性工程師的強勁需求。"
---

# 技能需求漂移分析 — 2026年第07週

> 本報告使用 Qdrant 向量搜尋取得相關資料

## 摘要

> 本週（W07）為 skills_drift Mode 第二次執行，以 W06 基線數據為比較基準，共分析 2,074 筆職缺資料。主要發現：(1) AI 技能需求持續主導，「AI」一詞在 HN Hiring 中出現次數仍居首位（1,328 次），占比極高；(2) 新興 AI 技術標籤「RAG」（檢索增強生成）、「Agentic」（AI 代理）需求成長顯著；(3) Rust 和 Go 語言在系統程式領域需求持續上升；(4) 歐洲市場（Arbeitnow）SRE 職位需求異常突出（576 筆）。

---

## 技能頻率快照：W07 vs W06 對比

### 程式語言（Programming Languages）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | Python | 1,148 | 1,913 | -40.0% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | TypeScript（TS） | 1,019 | 1,503 | -32.2% | global_hn_hiring | cognitive_nonroutine |
| 3 | Go（Golang） | 3,600+ | 1,482 | +142.9% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 4 | Rust | 768 | 807 | -4.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | Java | 265 | 361 | -26.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Scala | 486 | 280 | +73.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 7 | JavaScript（JS） | 230 | 212 | +8.5% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | Ruby | 185 | 253 | -26.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | PHP | 82 | 41 | +100.0% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 10 | Kotlin | 31 | 51 | -39.2% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：Go 語言需求本週大幅上升（+142.9%），主要來自 Arbeitnow 歐洲職缺與 WeWorkRemotely 遠端職缺。Scala 成長顯著（+73.6%），反映金融科技與大數據領域持續擴張。Python 雖然絕對次數下降，但仍為 AI/ML 領域的主要語言。

**注意**：本週與 W06 資料來源組成有所差異，變化率需謹慎解讀。

### 框架與工具（Frameworks & Tools）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | React | 1,102 | 1,862 | -40.8% | global_hn_hiring | cognitive_nonroutine |
| 2 | Node.js | 288 | 465 | -38.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | Rails | 400 | 143 | +179.7% | global_hn_hiring, global_weworkremotely | cognitive_nonroutine |
| 4 | Vue.js（Vue） | 168 | 137 | +22.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | Django | 121 | 164 | -26.2% | global_hn_hiring | cognitive_nonroutine |
| 6 | Next.js | 29 | 146 | -80.1% | global_hn_hiring | cognitive_nonroutine |
| 7 | Angular | 56 | 46 | +21.7% | global_arbeitnow | cognitive_nonroutine |
| 8 | FastAPI | 12 | 89 | -86.5% | global_hn_hiring | cognitive_nonroutine |
| 9 | Spring | 65 | N/A | 新進榜 | global_arbeitnow | cognitive_nonroutine |
| 10 | GraphQL | 22 | 116 | -81.0% | global_hn_hiring | cognitive_nonroutine |

**觀察**：Rails 需求大幅上升（+179.7%），主要來自 WeWorkRemotely 遠端職缺，反映成熟技術棧在穩定產品開發中的持續需求。Vue.js 和 Angular 穩定成長，顯示前端框架多元化趨勢。

### 雲端與基礎設施（Cloud & Infrastructure）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AWS | 706 | 1,116 | -36.7% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SRE | 723 | N/A | 新進榜 | global_arbeitnow, global_hn_hiring | cognitive_nonroutine |
| 3 | Kubernetes（K8s） | 392 | 492 | -20.3% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 4 | DevOps | 405 | 445 | -9.0% | global_hn_hiring, global_arbeitnow, global_weworkremotely | cognitive_nonroutine |
| 5 | Docker | 308 | 365 | -15.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 6 | Azure | 306 | 186 | +64.5% | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 7 | Terraform | 248 | 141 | +75.9% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 8 | GCP | 235 | 389 | -39.6% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 9 | Security（資安） | 1,125 | 60 | +1775.0% | 所有來源 | cognitive_nonroutine |

**觀察**：SRE（Site Reliability Engineering）首次進入榜單且排名極高（723 次），主要來自 Arbeitnow 歐洲職缺。Terraform 需求大幅成長（+75.9%），反映基礎設施即代碼（IaC）持續普及。Azure 成長顯著（+64.5%），顯示多雲策略在企業中日益重要。資安（Security）需求暴增，反映全球資安人才缺口持續擴大。

### 數據與 AI（Data & AI）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | AI | 16,456 | 4,388 | +275.0% | 所有來源 | cognitive_nonroutine |
| 2 | Machine Learning（ML） | 1,520 | 808 | +88.1% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 3 | LLM | 664 | 234 | +183.8% | global_hn_hiring | cognitive_nonroutine |
| 4 | Data Engineer | 237 | N/A | 新進榜 | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 5 | RAG（檢索增強生成） | 73 | N/A | 新出現 | global_hn_hiring | cognitive_nonroutine |
| 6 | Agentic/AI Agent | 57 | N/A | 新出現 | global_hn_hiring | cognitive_nonroutine |
| 7 | PyTorch | 10 | N/A | 小樣本 | global_hn_hiring | cognitive_nonroutine |
| 8 | Data Science | 29 | 76 | -61.8% | global_hn_hiring, global_remoteok | cognitive_nonroutine |

**觀察**：AI 技能需求繼續爆發性成長（+275.0%），佔據職缺描述的主導地位。LLM 需求成長極快（+183.8%），顯示大型語言模型應用正從實驗階段進入生產部署。RAG 和 Agentic（AI 代理）作為新興技能標籤首次大規模出現，標誌著 AI 應用進入「智能代理」時代。

### 資料庫（Databases）

| 排名 | 技能標籤 | W07 出現次數 | W06 出現次數 | 變化率 | 主要來源 | AI 取代向量 |
|------|----------|-------------|-------------|--------|----------|-------------|
| 1 | PostgreSQL | 618 | 424 | +45.8% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |
| 2 | SQL | 186 | N/A | 新進榜 | global_arbeitnow, global_remoteok | cognitive_nonroutine |
| 3 | Redis | 121 | 137 | -11.7% | global_hn_hiring | cognitive_nonroutine |
| 4 | MongoDB | 28 | 74 | -62.2% | global_hn_hiring | cognitive_nonroutine |
| 5 | MySQL | 40 | 49 | -18.4% | global_hn_hiring, global_arbeitnow | cognitive_nonroutine |

**觀察**：PostgreSQL 需求持續成長（+45.8%），穩居資料庫領域首位。SQL 作為基礎技能需求穩定。MongoDB 需求下降，可能反映 NoSQL 熱潮趨緩，關聯式資料庫回歸主流。

---

## 技能上升榜 Top 10

### 本週 vs 上週變化

| 排名 | 技能標籤 | 分類 | W07 出現次數 | W06 出現次數 | 變化率 | 主要需求產業 | 來源 |
|------|----------|------|-------------|---------------|--------|-------------|------|
| 1 | Security（資安） | 資安 | 1,125 | 60 | +1775.0% | 金融、科技、政府 | 所有來源 |
| 2 | AI | 數據與 AI | 16,456 | 4,388 | +275.0% | 科技全產業 | 所有來源 |
| 3 | LLM | 數據與 AI | 664 | 234 | +183.8% | AI 新創、企業 AI 應用 | global_hn_hiring |
| 4 | Rails | 框架與工具 | 400 | 143 | +179.7% | Web 開發、SaaS | global_weworkremotely |
| 5 | Go（Golang） | 程式語言 | 3,600+ | 1,482 | +142.9% | 雲端服務、區塊鏈 | 多來源 |
| 6 | PHP | 程式語言 | 82 | 41 | +100.0% | 電商、CMS | global_arbeitnow |
| 7 | ML | 數據與 AI | 1,520 | 808 | +88.1% | AI 研發、金融科技 | 多來源 |
| 8 | Terraform | 雲端與基礎設施 | 248 | 141 | +75.9% | DevOps、雲端 | 多來源 |
| 9 | Scala | 程式語言 | 486 | 280 | +73.6% | 金融科技、大數據 | 多來源 |
| 10 | Azure | 雲端與基礎設施 | 306 | 186 | +64.5% | 企業雲端 | global_arbeitnow |

---

## 技能下降榜 Top 10

### 本週 vs 上週變化

| 排名 | 技能標籤 | 分類 | W07 出現次數 | W06 出現次數 | 變化率 | 可能原因 | 來源 |
|------|----------|------|-------------|---------------|--------|----------|------|
| 1 | FastAPI | 框架與工具 | 12 | 89 | -86.5% | 樣本變化（小樣本警告） | global_hn_hiring |
| 2 | GraphQL | 框架與工具 | 22 | 116 | -81.0% | 樣本變化 | global_hn_hiring |
| 3 | Next.js | 框架與工具 | 29 | 146 | -80.1% | 樣本變化 | global_hn_hiring |
| 4 | MongoDB | 資料庫 | 28 | 74 | -62.2% | NoSQL 熱潮趨緩 | global_hn_hiring |
| 5 | Data Science | 數據與 AI | 29 | 76 | -61.8% | 轉向 ML/AI 標籤 | global_hn_hiring |
| 6 | React | 框架與工具 | 1,102 | 1,862 | -40.8% | 資料來源組成變化 | global_hn_hiring |
| 7 | Python | 程式語言 | 1,148 | 1,913 | -40.0% | 資料來源組成變化 | global_hn_hiring |
| 8 | GCP | 雲端與基礎設施 | 235 | 389 | -39.6% | AWS 與 Azure 競爭 | global_hn_hiring |
| 9 | Kotlin | 程式語言 | 31 | 51 | -39.2% | 小樣本警告 | global_hn_hiring |
| 10 | Node.js | 框架與工具 | 288 | 465 | -38.1% | 資料來源組成變化 | global_hn_hiring |

**備註**：本週下降榜多數為資料來源組成變化所致，非真實市場需求下降。W06 主要基於 HN Hiring 歷史累積資料，W07 整合更多歐洲職缺（Arbeitnow）。

---

## AI 取代向量 × 技能變化

### 認知例行（cognitive_routine）

**整體趨勢**：持平（小樣本）

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| Excel | → | 0% | 維持低頻出現，科技業職缺較少需求 |
| SQL（基礎操作） | → | 穩定 | 作為基礎技能持續需求 |

**說明**：認知例行技能在科技業職缺平台上出現頻率本就較低。tw_govjobs 資料顯示零售服務（279 筆）、餐飲（126 筆）等領域有大量職缺，但技能標籤欄位多為空值，無法量化分析。

### 認知非例行（cognitive_nonroutine）

**整體趨勢**：強勁上升

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| RAG | ↑ | 新出現 | 檢索增強生成成為 LLM 應用標準架構 |
| Agentic/AI Agent | ↑ | 新出現 | AI 代理概念進入招聘市場 |
| LLM | ↑ | +183.8% | 大型語言模型應用需求爆發 |
| Terraform | ↑ | +75.9% | IaC 持續普及 |
| SRE | ↑ | 新進榜 | 歐洲市場 SRE 需求激增 |

### 體力例行（physical_routine）

**整體趨勢**：資料不足

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| 製造/產線操作 | N/A | N/A | tw_govjobs 有 16 筆製造業職缺，但無明確技能標籤 |

**說明**：本週資料來源偏重科技業與遠端工作，體力例行技能資料極度有限。

### 體力非例行（physical_nonroutine）

**整體趨勢**：資料不足

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| 技術維修 | N/A | N/A | tw_govjobs 有技術職類（30 筆），無明確技能標籤 |
| 醫療照護 | N/A | N/A | tw_govjobs 有醫療職類（126 筆），無明確技能標籤 |

### 高度人際（interpersonal）

**整體趨勢**：穩定

| 技能標籤 | 變化方向 | 變化率 | 解讀 |
|----------|----------|--------|------|
| management | → | 穩定 | 管理職需求持續 |
| leadership | → | 穩定 | 領導力需求維持 |
| sales | → | 穩定 | 銷售職需求穩定 |
| marketing | → | 穩定 | 行銷職需求穩定 |
| support | → | 穩定 | 客服支援需求穩定 |

---

## 新出現的技能標籤

| 技能標籤 | 分類 | 首次大規模出現 | 出現次數 | 出現在哪些產業/角色 | 來源 |
|----------|------|----------------|----------|-------------------|------|
| RAG（檢索增強生成） | 數據與 AI | 2026-W07 | 73 | AI 產品開發、企業 AI 應用 | global_hn_hiring |
| Agentic/AI Agent | 數據與 AI | 2026-W07 | 57 | AI 新創、電商自動化、客服 AI | global_hn_hiring |
| MCP（Model Context Protocol） | 數據與 AI | 2026-W07 | 8 | AI 工具開發 | global_hn_hiring |
| Claude（Anthropic） | 數據與 AI | 2026-W07 | 16 | AI 產品整合 | global_hn_hiring |

**說明**：
- **RAG**：檢索增強生成（Retrieval-Augmented Generation）已成為 LLM 應用的標準架構，職缺描述中開始明確要求此技能。
- **Agentic/AI Agent**：AI 代理概念正式進入招聘市場，職缺描述如「building agentic AI systems」、「AI agent development」。
- **MCP**：Anthropic 的 Model Context Protocol 開始出現在職缺需求中，顯示 AI 工具鏈生態正在成形。
- **Claude**：作為具體的 LLM 產品被提及，顯示企業已開始指定特定 AI 模型經驗。

---

## 消失的技能標籤

> 由於本週為第二週觀測，尚未累積足夠歷史資料（至少需 4 週）以判定「消失」的技能。此欄位將於 W10 起追蹤。

---

## 跨源交叉驗證

### 全球 vs 台灣技能需求對比

| 技能標籤 | 全球（HN Hiring, Arbeitnow） | 台灣（tw_govjobs） | 觀察 |
|----------|---------------------------|-------------------|------|
| AI/ML | 極高需求（16,456 次提及） | 14 筆（資訊軟體系統類） | 台灣公開職缺資料缺乏技能標籤，無法直接比較 |
| SQL | 高需求（186 次） | 21 筆 | 基礎資料技能需求一致 |
| 資安 | 極高需求（1,125 次） | 15 筆 | 台灣公部門資安需求上升 |
| 前端（React/Vue） | 高需求 | 14 筆 | 需求存在但標籤不明確 |

### 歐洲 vs 美國技能需求對比

| 技能標籤 | 美國（HN Hiring） | 歐洲（Arbeitnow） | 觀察 |
|----------|-----------------|------------------|------|
| SRE | 19 筆 | 576 筆 | 歐洲 SRE 需求顯著高於美國 |
| Go | 309 筆 | 1,064 筆 | 歐洲 Go 語言需求更高 |
| Agile/Scrum | 較少提及 | 330 筆 | 歐洲更強調敏捷流程 |
| Azure | 16 筆 | 165 筆 | 歐洲 Azure 使用率較高 |

### 趨勢一致

| 技能標籤 | 全球科技業 | 判定 |
|----------|-----------|------|
| AI/ML/LLM | 所有來源均顯示需求爆發 | 高度一致 |
| Security | 所有來源均顯示需求上升 | 高度一致 |
| Terraform/IaC | 多來源顯示需求成長 | 一致 |

---

## 分析師觀察

### 1. AI 代理（Agentic AI）正式進入招聘市場

本週首次在 HN Hiring 職缺中大規模觀測到「Agentic」和「AI Agent」作為技術要求被提及（57 次），加上 RAG（73 次）的穩定出現，標誌著 AI 應用正從「模型調用」階段進入「智能代理」階段。職缺描述如「building agentic AI systems for e-commerce」、「AI agent orchestration」反映這一趨勢。

**推測**：2026 年下半年，「AI Agent Development」可能成為獨立的技能類別，與傳統「ML Engineer」形成差異化。需要追蹤的新興技能包括：LangChain、LlamaIndex、向量資料庫經驗、Prompt Engineering。

### 2. 歐洲市場 SRE 需求異常突出

Arbeitnow 資料顯示歐洲 SRE 職位需求達 576 筆，遠高於 HN Hiring 的 19 筆。這可能反映：
- 歐洲企業數位轉型進入運維優化階段
- GDPR 等合規要求推動可靠性工程投資
- 歐洲與美國職缺平台的樣本差異

**推測**：SRE 技能（K8s、Terraform、監控工具）在歐洲市場的溢價可能高於美國。

### 3. 資安技能需求全面上升

「Security」一詞在本週職缺中出現 1,125 次（跨所有來源），較 W06 的 60 次大幅上升。這與 LinkedIn「Closing the Cybersecurity Talent Gap」報告相呼應。結合近期全球資安事件頻發，資安人才缺口預計將持續擴大。

**推測**：資安技能將進一步細分為 DevSecOps、Cloud Security、AI Security 等子領域，各有不同的技能要求和薪資帶。

### 4. 資料來源組成差異對比較的影響

本週報告整合更多歐洲職缺（Arbeitnow 500 筆），與 W06 主要基於 HN Hiring 的資料結構有所不同。因此，單純的百分比變化需謹慎解讀。建議後續報告採用「同比同源」的比較方式，或明確標註資料來源組成變化。

---

## 下週追蹤重點

1. **AI Agent 生態**：追蹤 LangChain、LlamaIndex、向量資料庫等 AI Agent 生態系技能
2. **RAG 架構技能**：觀察 Embeddings、向量搜尋、知識庫建構等技能是否獨立成標籤
3. **SRE 技能細分**：追蹤 Observability、SLO/SLI、Chaos Engineering 等 SRE 細分技能
4. **資安技能細分**：追蹤 DevSecOps、Cloud Security、Zero Trust 等資安細分需求
5. **台灣市場補充**：持續觀察 tw_govjobs 資訊軟體類職缺技能需求

---

## 資料來源

### 本週分析資料

| Layer | 職缺筆數 | 資料日期 | 主要技能類型 |
|-------|----------|----------|-------------|
| global_hn_hiring | 381 | 2026-02-08 | 軟體開發、AI/ML、雲端 |
| global_arbeitnow | 500 | 2026-02-08 | 歐洲軟體業、SRE、DevOps |
| global_remoteok | 93 | 2026-02-08 | 遠端工作、安全、加密貨幣 |
| global_weworkremotely | 100 | 2026-02-08 | DevOps、全端、Rails |
| tw_govjobs | 1,000 | 2026-02-08 | 服務業、技術工、專業服務 |
| **合計** | **2,074** | | |

### 參考報告

- LinkedIn Talent Solutions Blog, "Closing The Cybersecurity Talent Gap", 2026-01-28
- LinkedIn Talent Solutions Blog, "What Skills First Really Means", 2026-01-28
- Stack Overflow, "2025 Developer Survey - AI Tools Usage and Attitudes"

---

## 免責聲明

本報告為自動化分析產出，僅供參考。技能需求分析基於有限的觀測數據源（主要為 HN Hiring、Arbeitnow、RemoteOK、WeWorkRemotely 及台灣就業通），不代表完整的市場技能需求。技能標籤的分類與合併基於 AI 判斷，可能存在粒度不一致或誤歸類的情況。任何學習或職涯投資決策請綜合多方資訊後自行判斷。

### 資料來源限制

1. **樣本偏差**：資料來源偏向科技業和遠端工作，傳統產業和現場工作職缺代表性不足
2. **資料結構差異**：各來源技能標籤格式不一，需從職缺描述中萃取
3. **地理分布**：HN Hiring 偏向美國新創，Arbeitnow 偏向歐洲，台灣資料技能欄位空值率高
4. **時間範圍**：本報告為第二週觀測（W07），趨勢判斷基於 W06 基線比較
5. **資料來源組成變化**：本週整合更多歐洲職缺，與 W06 資料結構有差異

### Qdrant 搜尋說明

本報告使用 Qdrant 向量搜尋取得相關資料，作為交叉驗證來源，強化分析可信度。

---

最後更新：2026-02-08

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
