---
layout: default
title: W08
parent: 景氣溫度計
nav_order: 9992
permalink: /reports/climate-index-w08/
report_title: "就業景氣溫度計 — 2026年第08週"
mode: climate_index
period: "2026-W08"
generated_at: "2026-02-18T12:00:00+08:00"
source_layers:
  - tw_govjobs
  - global_arbeitnow
  - global_hn_hiring
  - global_remoteok
  - global_weworkremotely
  - global_bls
  - global_hays_salary
  - global_stackoverflow
  - global_linkedin_workforce
  - global_ilo_stats
  - global_oecd_stats
  - global_statcan
  - global_adzuna
  - workforce_news
  - funding_signals
data_coverage:
  layers_available: 15
  layers_total: 15
  observation_period: "2026-02-10 ~ 2026-02-18"
confidence: 中
qdrant_search_used: true

seo:
  title: "2026年第8週就業市場偏冷：AI融資狂潮與科技業結構重組持續 | 景氣溫度計"
  description: "本週就業市場溫度：偏冷。AI新創Ricursive Intelligence兩月獲$3億估值$40億；Capital One收購Brex；科技裁員潮延續。美國失業率4.4%穩定。"
  keywords:
    - 就業市場景氣
    - AI融資
    - 科技業裁員
    - 失業率
    - 2026勞動市場
    - Ricursive Intelligence
  article_section: 景氣溫度計
  faq:
    - question: "2026年第8週就業市場景氣如何？"
      answer: "本週就業市場溫度為「偏冷」。AI領域融資持續火熱，但科技業結構重組態勢延續，市場呈現分化格局。"
    - question: "2026年第8週美國就業數據表現如何？"
      answer: "美國總就業人數達159,526K，失業率維持4.4%，平均時薪$37.02美元，整體勞動市場基本面穩定。"
    - question: "2026年第8週有哪些重大融資事件？"
      answer: "AI實驗室Ricursive Intelligence成立兩月即獲$3億Series A、估值$40億；太空科技Northwood Space獲$1億Series B；Capital One以$51.5億收購Brex。"
---

# 就業景氣溫度計 — 2026年第08週

## 本週溫度：🟠 偏冷

> AI融資狂潮與科技業結構重組並行，市場呈現冷熱分化格局。

## 核心指標

### 台灣市場

| 指標 | 本週 | 前週 | 變化 | 來源 |
|------|------|------|------|------|
| 政府平台職缺數 | 1,000 | 1,000 | → | tw_govjobs |
| 主要職缺類型分布 | 零售服務 48%、科技 9%、專業 8% | 餐飲 34%、清潔 10% | 結構微調 | tw_govjobs |
| 薪資觀測區間 | 29,500-40,000 TWD | 29,500-37,100 TWD | 上緣微升 | tw_govjobs |
| 裁員事件數 | 5 | 5+ | → | workforce_news |
| 融資事件數 | 12 | 7 | +5 | funding_signals |

**備註**：tw_104_jobs、tw_company_reviews 數據未更新（API 限制），台灣專業人才市場的完整動態無法精確計算。政府平台職缺以服務業基層為主，但科技類職缺比例較前週略升。

### 全球市場

| 指標 | 最新值 | 前期值 | 趨勢 | 來源 |
|------|--------|--------|------|------|
| 美國非農就業（月） | 159,526K（12月） | 159,476K（11月） | ↑ +50K | global_bls |
| 美國失業率 | 4.4%（12月） | 4.5%（11月） | ↓ -0.1pp | global_bls |
| 美國平均時薪 | $37.02（12月） | - | → | global_bls |
| 日本總就業人數 | 68,280K（2025） | 67,810K（2024） | ↑ +0.7% | global_ilo_stats |
| 韓國總就業人數 | 28,881K（2025） | 28,695K（2024） | ↑ +0.6% | global_ilo_stats |
| 德國就業率 | 77.4% | 70.2%（2008） | 長期上升 | global_oecd_stats |
| 日本就業率 | 79.4% | 70.7%（2008） | 長期上升 | global_oecd_stats |

### 遠端/科技職缺市場

| 平台 | 職缺數 | 主要技術需求 | 薪資觀測 | 來源 |
|------|--------|--------------|----------|------|
| Hacker News Hiring | 2,336 | Backend 39%、Fullstack 28%、AI/ML | $80K-$400K | global_hn_hiring |
| RemoteOK | 94 | Design、Product、Support、Marketing | $60K-$292K | global_remoteok |
| WeWorkRemotely | 99 | Engineering、Teaching | $8-$100+/hr | global_weworkremotely |
| Arbeitnow (德國) | 1,181 | Data、Design、Management | 依職位而異 | global_arbeitnow |

> **數據覆蓋說明**：本週共有 **15/15 個 Layer 提供有效數據**。tw_104_jobs、tw_company_reviews 因 API 限制暫時停用，台灣專業人才市場完整數據不足。

---

## 溫度判讀依據

**台灣市場核心態勢**：政府就業通平台維持 1,000 筆職缺的穩定量能。職缺結構方面，零售服務類佔 48%（481 筆），科技類 9%（92 筆），專業類 8%（85 筆），醫療保健 7%（66 筆），技術工藝 6%（65 筆）。薪資觀測區間維持在 29,500-40,000 元，與前週相近。科技類職缺佔比略升，但整體仍以基層服務業為主。由於缺乏 104 人力銀行完整數據，台灣專業人才市場動態資訊仍有不足。（來源：tw_govjobs）

**全球市場背景**：美國勞工統計局（BLS）最新數據顯示，2025 年 12 月總就業人數達 159,526K（初值），失業率穩定在 4.4%，平均時薪 $37.02 美元，整體勞動市場基本面維持穩健。ILO 統計顯示亞太主要經濟體就業穩定增長：日本就業人數達 68,280K（+0.7% YoY），韓國達 28,881K（+0.6% YoY）。OECD 各國就業率維持在高檔，德國 77.4%、日本 79.4%。總體數據正向，但無法完全反映科技業的結構性變化。（來源：global_bls、global_ilo_stats、global_oecd_stats）

**事件面信號（融資/併購/裁員）**：本週融資市場呈現強勁態勢，但集中於 AI 與太空科技：

- **Ricursive Intelligence**：AI 實驗室成立僅兩個月即獲 $3 億 Series A 融資，估值達 $40 億美元，創下近年最快獨角獸紀錄
- **Northwood Space**：太空科技公司獲 $1 億 Series B + $5000 萬政府合約，a16z 參投
- **Capital One 收購 Brex**：$51.5 億美元現金+股票交易，但收購價不到 Brex 峰值估值的一半，反映金融科技估值回調
- **Pinterest 裁員 15%**：資源轉向 AI 團隊，典型的「結構重組而非縮編」
- **Vimeo 裁員**：被 Bending Spoons 收購後啟動裁員

Crunchbase 報告顯示 2025 年 Q4 新獨角獸數量創 2022 年 Q2 以來新高（12 月有 23 家），太空科技與金融科技領先。（來源：funding_signals、workforce_news）

**科技人才市場觀察**：Hacker News 招聘貼文累計達 2,336 筆，結構分布：後端工程 39%（902 筆）、全端 28%（646 筆）、前端 10%（241 筆）、DevOps 6%（133 筆）。Python、Docker、GCP、FastAPI 等技術棧需求穩定。薪資區間方面，Lead/Senior 級別 $85K-$200K，Staff Engineer 可達 $300K+。遠端工作仍為主流，多數職缺標註 Remote。（來源：global_hn_hiring）

**綜合研判**：本週維持「🟠 偏冷」判讀，主要依據：

1. **AI 融資狂熱持續**：Ricursive Intelligence 兩月獨角獸創紀錄，顯示資本對 AI 基礎設施的激進投注
2. **估值回調信號明確**：Brex 以不到峰值一半估值被收購，Pinterest 裁員轉型 AI
3. **結構性重組延續**：科技業裁員事件持續，但同時 AI/太空科技招聘旺盛，呈現分化格局
4. **總體就業穩定**：美國失業率 4.4%、亞太就業穩健，宏觀基本面無顯著惡化

這不是全面性市場寒冬，而是「贏家通吃」格局加劇——AI 與太空科技吸引大量資本與人才，其他領域則經歷估值修正與結構調整。

---

## 產業亮點與警訊

### 擴張信號

- 🟢 **AI 基礎設施**：Ricursive Intelligence 成立兩月獲 $3 億、估值 $40 億，顯示 AI 人才搶奪戰白熱化（來源：funding_signals）
- 🟢 **太空科技**：Northwood Space 獲 $1 億 Series B + $5000 萬政府合約，SpaceX 躍升獨角獸榜首（來源：funding_signals）
- 🟢 **後端工程**：HN Hiring 中 Backend 職缺佔 39%（902 筆），薪資競爭力強（來源：global_hn_hiring）
- 🟢 **亞太就業穩健**：日本、韓國就業人數年增 0.6%-0.7%，就業率維持高檔（來源：global_ilo_stats）
- 🟢 **Q4 獨角獸數量創新高**：12 月 23 家新獨角獸，為 2022 年 Q2 以來最高（來源：funding_signals）

### 收縮信號

- 🔴 **金融科技估值回調**：Brex 以不到峰值一半估值被收購（$51.5B vs. 峰值 $12B+）（來源：funding_signals）
- 🔴 **社群媒體裁員**：Pinterest 裁員 15%、Vimeo 併購後裁員（來源：workforce_news）
- 🔴 **傳統科技崗位收縮**：非 AI 相關軟體開發崗位持續受壓（來源：workforce_news）
- 🔴 **健身/健康科技**：VC 資金流入下降，市場觀望（來源：funding_signals）

### 值得關注

- 🟡 **AI 基礎設施論述**：Crunchbase 分析師指出 AI 不是獨立產業，而是賦能所有產業的基礎設施層（來源：funding_signals）
- 🟡 **遠端工作常態化**：HN Hiring 中遠端職缺仍佔多數，分散式辦公成熟（來源：global_hn_hiring）
- 🟡 **IPO 窗口觀望**：市場等待 2026 年 IPO 窗口打開信號（來源：funding_signals）
- 🟡 **台灣科技職缺微升**：政府平台科技類從 8% 升至 9%，但仍以基層為主（來源：tw_govjobs）

---

## 本週重大事件

1. **Ricursive Intelligence 成立兩月獲 $3 億 Series A、估值 $40 億**（來源：funding_signals）
   AI 實驗室創下近年最快獨角獸紀錄，顯示資本對基礎 AI 模型領域的激進投注。預計將大規模招募頂級 AI 研究科學家與 ML 工程師。

2. **Capital One 以 $51.5 億收購 Brex**（來源：funding_signals）
   史上最大銀行-金融科技交易。收購價不到 Brex 峰值估值的一半，反映金融科技估值回調。併購通常伴隨重複職能裁員。

3. **Northwood Space 獲 $1 億 Series B + $5000 萬政府合約**（來源：funding_signals）
   太空科技基礎設施公司獲 a16z 等頂級 VC 投資，加上政府合約，預示太空科技人才需求擴張。

4. **2025 年 Q4 新獨角獸數量創 2022 年 Q2 以來新高**（來源：funding_signals）
   12 月 23 家公司加入獨角獸行列，SpaceX 躍升榜首，金融科技領先成長。對求職者而言，追蹤獨角獸趨勢有助識別高成長機會。

5. **Pinterest 裁員 15% 並將資源轉向 AI**（來源：workforce_news）
   明確以「AI 優先」為戰略方向，將人力從傳統崗位轉移至 AI 相關團隊，是科技業「人力重組而非縮編」的典型案例。

---

## AI 取代向量觀察

| 取代向量 | 本週信號 | 代表性事件/數據 |
|----------|----------|-----------------|
| 認知例行（cognitive_routine） | 升溫 | Pinterest 重組瞄準可自動化崗位；AI 作為基礎設施層正在取代例行認知工作 |
| 認知非例行（cognitive_nonroutine） | 持平 | 高階工程師需求仍強（$200K-$400K）；AI 研究科學家大量招募（Ricursive Intelligence） |
| 體力例行（physical_routine） | 持平 | 台灣倉儲、製造業職缺穩定；無明顯機器人取代加速信號 |
| 體力非例行（physical_nonroutine） | 降溫 | 零售服務業職缺持續佔據台灣最大宗（48%），人力需求穩定（來源：tw_govjobs） |
| 高度人際（interpersonal） | 持平 | 業務、教育類職缺維持需求；遠端教育平台持續招募 |

---

## 資料來源明細

本報告使用 Qdrant 向量搜尋取得相關資料，資料來源包括：

| Layer | 筆數 | 更新時間 | 狀態 |
|-------|------|----------|------|
| tw_govjobs | 1,000 | 2026-02-18 | 有效 |
| global_hn_hiring | 2,336 | 2026-02-06 | 有效 |
| global_arbeitnow | 1,181 | 2026-02-06 | 有效 |
| global_remoteok | 94 | 2026-02-18 | 有效 |
| global_weworkremotely | 99 | 2026-02-18 | 有效 |
| global_linkedin_workforce | 61 | 2026-02-08 | 有效 |
| global_bls | 143 | 2026-02-08 | 有效 |
| global_ilo_stats | 72 | 2026-02-08 | 有效 |
| global_oecd_stats | 1,263 | 2026-02-08 | 有效 |
| global_statcan | 108 | 2026-02-08 | 有效 |
| global_hays_salary | 40 | 2026-02-08 | 有效 |
| global_stackoverflow | 23 | 2026-02-08 | 有效 |
| workforce_news | 20 | 2026-02-18 | 有效 |
| funding_signals | 37 | 2026-02-18 | 有效 |
| global_adzuna | 400 | 2026-02-08 | 有效 |

**總計**：6,877 筆觀測數據

---

## 免責聲明

本報告為自動化分析產出，僅供參考。就業市場判讀基於有限的觀測數據源，不代表完整的市場狀況。「溫度」指標為綜合性定性判斷，非精確量化指數。任何就業或投資決策請諮詢專業人士。

資料來源的更新頻率不一（部分為即時、部分為月度或季度），跨來源比較時應注意時間差異。tw_104_jobs 與 tw_company_reviews 因 API 存取限制暫時停用，台灣專業人才市場動態資訊有所不足。

---

最後更新：2026-02-18
