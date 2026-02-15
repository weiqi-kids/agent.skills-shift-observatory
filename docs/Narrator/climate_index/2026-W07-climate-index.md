---
layout: default
title: W07
parent: 景氣溫度計
nav_order: 9993
permalink: /reports/climate-index-w07/
report_title: "就業景氣溫度計 — 2026年第07週"
mode: climate_index
period: "2026-W07"
generated_at: "2026-02-08T17:00:00+08:00"
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
  observation_period: "2026-02-03 ~ 2026-02-08"

seo:
  title: "2026年第7週就業市場偏冷：科技裁員潮持續、AI 重塑招聘 | 景氣溫度計"
  description: "本週就業市場溫度：🟠 偏冷。Amazon 裁員 16,000 人、科技業結構重組。美國失業率維持 4.4%，日韓就業穩定成長。15/15 Layer 資料完整覆蓋。"
  keywords:
    - 就業市場景氣
    - 科技業裁員
    - Amazon 裁員
    - 失業率
    - 2026 勞動市場
    - AI 招聘趨勢
  article_section: 景氣溫度計
  faq:
    - question: "2026年第7週就業市場景氣如何？"
      answer: "本週就業市場溫度為「偏冷」。科技業裁員潮持續擴散，AI 正在重塑招聘結構，市場呈現結構性調整態勢。"
    - question: "2026年第7週美國就業數據表現如何？"
      answer: "美國總就業人數達 159,526K（月增 50K），失業率維持 4.4%，年度就業增長 +584K（+0.4%）。"
    - question: "2026年第7週有哪些重大裁員事件？"
      answer: "Amazon 宣布裁員 16,000 人、Pinterest 裁員 15% 並將資源轉向 AI 團隊。科技業正經歷結構性重組。"
---

# 就業景氣溫度計 — 2026年第07週

## 本週溫度：🟠 偏冷

> 科技業裁員潮持續擴散，AI 重塑招聘結構，市場呈現結構性調整態勢。

## 核心指標

### 台灣市場

| 指標 | 本週 | 前週 | 變化 | 來源 |
|------|------|------|------|------|
| 政府平台職缺數 | 1,000 | 1,000 | → | tw_govjobs |
| 主要職缺類型分布 | 餐飲 34%、清潔 10%、業務 8% | 零售服務 48% | 結構微調 | tw_govjobs |
| 薪資觀測區間 | 29,500-37,100 TWD | - | 基層為主 | tw_govjobs |
| 裁員事件數 | 5+ | 3 | ↑ | workforce_news |
| 融資事件數 | 7 | 5 | +2 | funding_signals |

**備註**：tw_104_jobs、tw_company_reviews 數據未更新（API 限制），台灣專業人才市場的完整動態無法精確計算。政府平台職缺以服務業基層為主。

### 全球市場

| 指標 | 最新值 | 前期值 | 趨勢 | 來源 |
|------|--------|--------|------|------|
| 美國總就業人數 | 159,526K（12月） | 159,476K（11月） | ↑ +50K | global_bls |
| 美國失業率 | 4.4%（12月） | 4.5%（11月） | ↓ -0.1pp | global_bls |
| 美國年度就業增長 | +584K vs 2024 | 158,942K（24.12） | ↑ +0.4% | global_bls |
| 日本總就業人數 | 68,280K（2025） | 67,810K（2024） | ↑ +0.7% | global_ilo_stats |
| 韓國總就業人數 | 28,881K（2025） | 28,695K（2024） | ↑ +0.6% | global_ilo_stats |
| 美國勞動參與率 | 62.4% | 62.6% | ↓ -0.2pp | global_ilo_stats |
| 德國就業率 | 77.4% | 70.2%（2008） | 長期上升 | global_oecd_stats |
| 日本就業率 | 79.4% | 70.7%（2008） | 長期上升 | global_oecd_stats |

### 遠端/科技職缺市場

| 平台 | 職缺數 | 主要技術需求 | 薪資觀測 | 來源 |
|------|--------|--------------|----------|------|
| Hacker News Hiring | 381 | AI（110次）、TypeScript（12）、React（11）、Python（5）| $80K-$400K | global_hn_hiring |
| RemoteOK | 93 | Full Stack、Sales、DevOps | $60K-$292K | global_remoteok |
| WeWorkRemotely | 100 | Teaching、Engineering | $8-$100+/hr | global_weworkremotely |
| Arbeitnow (德國) | 924 | Data Engineer、Manager | 依職位而異 | global_arbeitnow |
| Adzuna (美國) | 400 | Healthcare Analytics、Finance | $58K-$103K | global_adzuna |

> **數據覆蓋說明**：本週共有 **15/15 個 Layer 提供有效數據**。新增 global_ilo_stats（72筆）、global_oecd_stats（1,263筆）、global_statcan（108筆）、global_adzuna（400筆）等官方統計資料源，大幅提升數據覆蓋範圍。tw_104_jobs、tw_company_reviews 因 API 限制暫時停用。

---

## 溫度判讀依據

**台灣市場核心態勢**：政府就業通平台維持 1,000 筆職缺的穩定量能，但結構上以基層服務業為主：餐飲服務（17筆，佔34%）、清潔工作（5筆，10%）、業務銷售（4筆，8%）居前三。薪資集中在 29,500-37,100 元區間，多數職缺學歷要求為高中職（60%）。科技業與專業人才職缺比例偏低，這與全球科技業裁員潮相呼應。由於缺乏 104 人力銀行完整數據，台灣專業人才市場動態資訊不足，判讀偏保守。（來源：tw_govjobs）

**全球市場背景**：美國勞工統計局（BLS）最新數據顯示，2025 年 12 月總就業人數達 159,526K，較 2024 年同期增加 584K（+0.4%），失業率從 4.5% 微降至 4.4%，整體勞動市場仍呈溫和擴張。ILO 統計顯示亞太主要經濟體就業穩定增長：日本就業人數從 67,810K 增至 68,280K（+0.7%），韓國從 28,695K 增至 28,881K（+0.6%）。OECD 各國就業率維持在 71-81% 區間，德國（77.4%）、日本（79.4%）表現強勁。但需注意，總體數據無法完全反映科技業的結構性收縮。（來源：global_bls、global_ilo_stats、global_oecd_stats）

**事件面信號（裁員/融資/政策）**：本週裁員事件顯著增加：

- **Amazon**：宣布裁員 16,000 人，為 2023 年 14,000 人裁員後的第二波大規模調整
- **Pinterest**：裁員 15% 員工，明確將資源重新分配至 AI 團隊
- **AI 裁員爭議**：科技媒體質疑部分企業是否「AI-washing」——以 AI 轉型為由進行成本削減

融資面則呈現分化：Apple Xcode 26.3 整合 Anthropic Claude 與 OpenAI Codex，推動「agentic coding」成為主流開發模式，顯示 AI 工具鏈的成熟度提升。（來源：workforce_news、funding_signals）

**技術人才市場觀察**：Hacker News 2026 年 2 月招聘貼文分析顯示 AI 相關職缺佔據絕對主導（110 次提及），遠端工作模式仍是主流（remote 23 次 vs. onsite 9 次），技術棧需求以 TypeScript、React、Python、Rust、Kubernetes 為主。薪資區間方面，Senior Engineer $150K-$200K，Staff Engineer $200K-$300K，高階職位可達 $400K+。這顯示即便在裁員潮中，AI/ML、基礎設施與全端工程師仍有強勁需求。（來源：global_hn_hiring）

**綜合研判**：本週由「🟡 持平」調整為「🟠 偏冷」，主要依據：

1. **裁員事件升級**：Amazon 16,000 人、Pinterest 15% 的裁員規模顯著大於前週
2. **結構性矛盾加劇**：總體就業數據（BLS、ILO）仍呈正向，但科技業收縮信號明確
3. **AI 驅動重組加速**：企業以 AI 轉型為由進行人力結構調整，非典型衰退式裁員
4. **台灣市場疲軟**：政府平台職缺以基層服務業為主，專業人才需求信號不明顯

這不是全面性市場寒冬，而是「結構性重組」——AI 正在重塑勞動市場結構，部分角色需求萎縮，另一部分（AI 相關）則持續擴張。

---

## 產業亮點與警訊

### 擴張信號

- 🟢 **AI/ML 工程**：HN Hiring 中 AI 相關職缺提及率最高（110 次），薪資競爭激烈，$150K-$400K 為常態（來源：global_hn_hiring）
- 🟢 **醫療保健分析**：Adzuna 顯示 Healthcare Analytics Analyst 大量招聘，薪資 $65K-$103K USD（來源：global_adzuna）
- 🟢 **能源數據工程**：德國 Arbeitnow 出現 SCADA/能源領域 Senior Data Engineer 需求（來源：global_arbeitnow）
- 🟢 **開發者工具**：Apple Xcode 整合 Claude 與 Codex，推動開發者生態進化（來源：funding_signals）
- 🟢 **亞太就業穩健**：日本、韓國就業人數年增 0.6%-0.7%，就業率維持高檔（來源：global_ilo_stats）

### 收縮信號

- 🔴 **科技業一般崗位**：Amazon 裁員 16,000 人、Pinterest 裁員 15%，影響萬人規模（來源：workforce_news）
- 🔴 **科技媒體**：Washington Post 撤離矽谷分社，縮減科技報導團隊（來源：workforce_news）
- 🔴 **非 AI 軟體開發**：裁員潮中被標記為「可被 AI 取代」的重複性開發工作受影響（來源：workforce_news）
- 🔴 **VR/AR 元宇宙**：Meta Reality Labs 持續調整，VR/AR 投資回報仍不明朗（來源：workforce_news）

### 值得關注

- 🟡 **遠端工作常態化**：HN Hiring 中 remote（23 次）遠超 onsite（9 次），企業分散式辦公成熟（來源：global_hn_hiring）
- 🟡 **Fintech 與合規科技**：Comply、OpenSanctions 等合規科技公司持續招聘（來源：global_hn_hiring）
- 🟡 **教育科技**：Papaya Tutor 等平台擴大遠端教師招募（來源：global_weworkremotely）
- 🟡 **加拿大人口增長**：2025 年 1-6 月人口從 34,388K 增至 34,577K，移民帶動勞動力供給（來源：global_statcan）

---

## 本週重大事件

1. **Amazon 宣布裁員 16,000 人**（來源：workforce_news）
   繼 2023 年 14,000 人裁員後的第二波大規模調整，反映電商與雲服務市場競爭壓力，規模遠超前週任何單一事件。

2. **Pinterest 裁員 15% 並將資源轉向 AI**（來源：workforce_news）
   明確以「AI 優先」為戰略方向，將人力從傳統崗位轉移至 AI 相關團隊，是科技業「人力重組而非縮編」的典型案例。

3. **Apple Xcode 26.3 整合 Claude 與 Codex**（來源：funding_signals）
   首次將第三方 AI Agent 深度整合至原生開發工具，推動「agentic coding」成為主流開發模式，預示開發者工作流程的重大轉變。

4. **AI 裁員 vs. AI-washing 爭議**（來源：workforce_news）
   科技媒體質疑部分企業是否真正因 AI 效率提升而裁員，還是借 AI 之名進行成本削減，引發對「AI 取代工作」敘事的反思。

5. **ILO/OECD 數據顯示亞太就業穩健**（來源：global_ilo_stats、global_oecd_stats）
   日本就業率 79.4%、韓國就業人數年增 0.6%，亞太主要經濟體勞動市場基本面仍穩，與北美科技業收縮形成對比。

---

## AI 取代向量觀察

| 取代向量 | 本週信號 | 代表性事件/數據 |
|----------|----------|-----------------|
| 認知例行（cognitive_routine） | 升溫 | Pinterest 重組瞄準可自動化的內容審核與數據處理崗位；HN 招聘中 AI 相關職缺壓倒性領先（110次），顯示 AI 正在取代例行認知工作 |
| 認知非例行（cognitive_nonroutine） | 持平 | 高階工程師、Staff Engineer 需求仍強（$200K-$400K），AI 輔助而非取代；醫療分析師需求旺盛（來源：global_adzuna） |
| 體力例行（physical_routine） | 持平 | 台灣清潔、倉儲類職缺穩定；無明顯機器人取代加速信號 |
| 體力非例行（physical_nonroutine） | 降溫 | 餐飲服務業職缺持續佔據台灣最大宗（34%），人力需求穩定（來源：tw_govjobs） |
| 高度人際（interpersonal） | 持平 | 業務、教育類職缺維持需求；遠端教育平台擴張（Papaya Tutor） |

---

## 資料來源明細

本報告使用 Qdrant 向量搜尋取得相關資料，資料來源包括：

| Layer | 筆數 | 更新時間 | 狀態 |
|-------|------|----------|------|
| tw_govjobs | 1,000 | 2026-02-08 | 有效 |
| global_hn_hiring | 381 | 2026-02-08 | 有效 |
| global_arbeitnow | 924 | 2026-02-06 | 有效 |
| global_remoteok | 93 | 2026-02-08 | 有效 |
| global_weworkremotely | 100 | 2026-02-08 | 有效 |
| global_linkedin_workforce | 61 | 2026-02-08 | 有效 |
| global_bls | 144 | 2026-02-08 | 有效 |
| global_ilo_stats | 72 | 2026-02-08 | **新增** |
| global_oecd_stats | 1,263 | 2026-02-08 | **新增** |
| global_statcan | 108 | 2026-02-08 | **新增** |
| global_hays_salary | 40 | 2026-02-08 | 有效 |
| global_stackoverflow | 23 | 2026-02-08 | 有效 |
| workforce_news | 20 | 2026-02-08 | 有效 |
| funding_signals | 7 | 2026-02-08 | 有效 |
| global_adzuna | 400 | 2026-02-08 | **新增** |

**總計**：4,636 筆觀測數據

---

## 免責聲明

本報告為自動化分析產出，僅供參考。就業市場判讀基於有限的觀測數據源，不代表完整的市場狀況。「溫度」指標為綜合性定性判斷，非精確量化指數。任何就業或投資決策請諮詢專業人士。

資料來源的更新頻率不一（部分為即時、部分為月度或季度），跨來源比較時應注意時間差異。本週新增 ILO、OECD、StatCan、Adzuna 等官方統計資料源，提升數據覆蓋範圍。

tw_104_jobs 與 tw_company_reviews 因 API 存取限制暫時停用，台灣專業人才市場動態資訊有所不足。

---

最後更新：2026-02-08
