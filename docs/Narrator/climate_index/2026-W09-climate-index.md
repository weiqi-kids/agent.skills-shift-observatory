---
layout: default
title: W09
parent: 景氣溫度計
nav_order: 9991
permalink: /reports/climate-index-w09/
last_modified_date: 2026-02-28
report_title: "就業景氣溫度計 — 2026年第09週"
mode: climate_index
period: "2026-W09"
generated_at: "2026-02-28T22:00:00+08:00"
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
  observation_period: "2026-02-19 ~ 2026-02-28"
confidence: 中
qdrant_search_used: true

seo:
  title: "2026年第9週就業市場偏冷：Block減半員工、OpenAI融資$1100億 | 景氣溫度計"
  description: "本週就業市場溫度：偏冷。Block裁減約半數員工、eBay裁員800人、Lucid Motors裁員12%；OpenAI募集史上最大$1100億融資。美國失業率維持4.4%。"
  keywords:
    - 就業市場景氣
    - Block裁員
    - OpenAI融資
    - 科技業裁員
    - 失業率
    - 2026勞動市場
    - AI融資
  article_section: 景氣溫度計
  faq:
    - question: "2026年第9週就業市場景氣如何？"
      answer: "本週就業市場溫度為「偏冷」。Block減半員工、eBay裁員800人等重大裁員事件密集，但AI融資創紀錄（OpenAI $1100億），市場呈現明顯分化。"
    - question: "2026年第9週美國就業數據表現如何？"
      answer: "美國總就業人數達159,526K，失業率維持4.4%（較11月下降0.1個百分點），整體勞動市場基本面穩定。"
    - question: "2026年第9週有哪些重大裁員事件？"
      answer: "Block（前Square）減半員工約4000人；eBay裁員800人（三年內第三次）；Lucid Motors裁員12%；Amazon 1月已裁員16000人。"
    - question: "2026年第9週OpenAI融資情況如何？"
      answer: "OpenAI宣布募集$1100億美元，為史上最大AI融資案，估值達$8400億美元，顯示AI領域資本狂熱持續。"
---

# 就業景氣溫度計 — 2026年第09週

## 本週溫度：🟠 偏冷

> 裁員潮加劇與AI融資狂熱並行，市場分化格局進一步深化。

> 本報告使用 Qdrant 向量搜尋取得相關資料

## 核心指標

### 台灣市場

| 指標 | 本週 | 前週 | 變化 | 來源 |
|------|------|------|------|------|
| 政府平台職缺數 | 1,000 | 1,000 | → | tw_govjobs |
| 主要職缺類型分布 | 零售服務 48%、科技 9%、專業 9% | 零售服務 48%、科技 9%、專業 8% | 結構穩定 | tw_govjobs |
| 薪資觀測區間 | 29,500-40,000 TWD | 29,500-40,000 TWD | → | tw_govjobs |
| 裁員事件數 | 4 | 5 | -1 | workforce_news |
| 融資事件數 | 9 | 12 | -3 | funding_signals |

**備註**：tw_104_jobs、tw_company_reviews 數據未更新（API 限制），台灣專業人才市場的完整動態無法精確計算。政府平台職缺以服務業基層為主，科技類職缺比例維持穩定。

### 全球市場

| 指標 | 最新值 | 前期值 | 趨勢 | 來源 |
|------|--------|--------|------|------|
| 美國非農就業（月） | 159,526K（12月） | 159,476K（11月） | ↑ +50K | global_bls |
| 美國失業率 | 4.4%（12月） | 4.5%（11月） | ↓ -0.1pp | global_bls |
| 德國就業率 | 77.2%（2023） | — | → | global_oecd_stats |
| 日本就業率 | 78.9%（2023） | — | → | global_oecd_stats |
| 日本就業人口比 | 61.7%（2024） | — | → | global_ilo_stats |

### 遠端/科技職缺市場

| 平台 | 職缺數 | 主要技術需求 | 薪資觀測 | 來源 |
|------|--------|--------------|----------|------|
| Hacker News Hiring | 2,336 | Backend 39%、Fullstack 28%、Frontend 10% | $80K-$400K | global_hn_hiring |
| RemoteOK | 94 | Design、Product、Support、Marketing | $60K-$292K | global_remoteok |
| WeWorkRemotely | 99 | Engineering、Teaching | $8-$100+/hr | global_weworkremotely |
| Arbeitnow (德國) | 1,181 | Data、Design、Management | 依職位而異 | global_arbeitnow |

> **數據覆蓋說明**：本週共有 **15/15 個 Layer 提供有效數據**。tw_104_jobs、tw_company_reviews 因 API 限制暫時停用，台灣專業人才市場完整數據不足。

---

## 溫度判讀依據

**台灣市場核心態勢**：政府就業通平台維持 1,000 筆職缺的穩定量能。職缺結構方面，零售服務類佔 48%（481 筆），科技類 9%（92 筆），專業類 9%（85 筆），醫療保健 7%（66 筆），技術工藝 7%（65 筆），物流運輸 3%（31 筆），製造業 1%（14 筆）。薪資觀測區間維持在 29,500-40,000 元。整體職缺結構與前週相近，以基層服務業為主。（來源：tw_govjobs）

**全球市場背景**：美國勞工統計局（BLS）最新數據顯示，2025 年 12 月總就業人數達 159,526K（初值），較 11 月增加 50K，失業率從 4.5% 小幅下降至 4.4%，顯示勞動市場基本面尚稱穩健。OECD 數據顯示主要經濟體就業率維持高檔：日本 78.9%、德國 77.2%。ILO 統計日本就業人口比為 61.7%（2024）。總體宏觀數據正向，但無法完全反映科技業的劇烈結構性變化。（來源：global_bls、global_oecd_stats、global_ilo_stats）

**事件面信號（裁員/融資）**：本週裁員事件規模顯著擴大，但 AI 融資同步創紀錄：

- **Block（前 Square）**：CEO Jack Dorsey 宣布減半員工，估計影響約 4,000 人，效仿 Elon Musk 激進管理模式
- **eBay**：裁員 800 人，為三年內第三次大規模人力縮減
- **Lucid Motors**：裁員 12%，追求盈利能力，反映電動車產業財務壓力
- **Amazon**：1 月已裁員 16,000 人（累計與 2025 年 10 月達 30,000 人）
- **OpenAI**：募集 $1,100 億美元史無前例融資，估值達 $8,400 億美元
- **太空科技**：2025 年產業融資達 $120 億美元，2026 年延續強勁勢頭

（來源：workforce_news、funding_signals）

**科技人才市場觀察**：Hacker News 招聘貼文累計達 2,336 筆，結構分布與前週相近：後端工程 39%（902 筆）、全端 28%（646 筆）、前端 10%（241 筆）、DevOps 6%（133 筆）。遠端工作仍為主流。值得注意的是，SaaS 公司 IPO 明顯缺席——儘管整體 IPO 市場正常運作（建築科技、太空科技、生技持續上市），傳統 SaaS 卻未見重大上市案例，反映該子領域面臨特殊壓力。（來源：global_hn_hiring、funding_signals）

**綜合研判**：本週維持「🟠 偏冷」判讀，但寒冷信號較前週增強：

1. **裁員潮顯著加劇**：Block 減半員工（~4,000 人）為本週最重大事件，eBay、Lucid Motors 裁員持續，顯示科技業與電動車產業結構調整遠未結束
2. **AI 融資狂熱創紀錄**：OpenAI $1,100 億融資打破所有紀錄，顯示資本對 AI 基礎設施的極度樂觀
3. **SaaS IPO 缺席**：傳統 SaaS 面臨 AI 衝擊與估值壓力，人才可能流向 AI 原生產品
4. **宏觀基本面穩定**：美國失業率 4.4%、OECD 就業率高檔，整體勞動市場未見系統性惡化

這是一個「極度分化」的市場：AI 與太空科技吸引史無前例的資本，而傳統科技、電商、金融科技則經歷激烈重組。Jack Dorsey 公開表示其他公司將跟進，暗示裁員潮可能擴大。

---

## 產業亮點與警訊

### 擴張信號

- 🟢 **AI 基礎設施**：OpenAI 募集 $1,100 億美元史上最大融資，估值 $8,400 億美元，AI 人才搶奪戰進入新階段（來源：funding_signals）
- 🟢 **太空科技**：2025 年產業融資達 $120 億美元，2026 年延續強勁，需求橫跨航太工程與 AI/ML 專家（來源：funding_signals）
- 🟢 **後端工程**：HN Hiring 中 Backend 職缺佔 39%（902 筆），薪資競爭力維持高檔（來源：global_hn_hiring）
- 🟢 **Fintech + AI 交叉**：GV 合夥人強調尋找「compounding startups」，Fintech × AI 跨領域人才需求上升（來源：funding_signals）

### 收縮信號

- 🔴 **金融科技/支付**：Block 減半員工，繼 Brex 被收購後，Fintech 產業進入深度整合（來源：workforce_news）
- 🔴 **電子商務**：eBay 三年內第三次裁員，電商平台持續面臨營運壓力（來源：workforce_news）
- 🔴 **電動車製造**：Lucid Motors 裁員 12%，Rivian 先前也有裁員，電動車產業財務壓力持續（來源：workforce_news）
- 🔴 **傳統 SaaS**：IPO 市場正常但 SaaS 缺席，投資人質疑傳統 SaaS 是否會被 AI 原生產品取代（來源：funding_signals）

### 值得關注

- 🟡 **AI-washing 現象**：有分析指出部分企業以「AI 轉型」為藉口進行傳統裁員，需區分真正的 AI 驅動重組（來源：workforce_news）
- 🟡 **LP 流動性創新**：Turbine 等公司為創投 LP 提供流動性工具，間接影響新創融資環境（來源：funding_signals）
- 🟡 **小眾前沿領域**：月球能源、植物基染料、倉儲機器人等小型融資案反映長期技術趨勢（來源：funding_signals）

---

## 本週重大事件

1. **Block（前 Square）減半員工，CEO 暗示其他公司將跟進**（來源：workforce_news）
   Jack Dorsey 宣布大規模裁員，將員工總數削減約一半（估計約 4,000 人）。Dorsey 效仿 Elon Musk 激進管理風格，並公開表示其他公司也將採取類似行動。這是本週最重大的裁員事件，具有科技業人力趨勢指標意義。

2. **OpenAI 募集 $1,100 億美元史上最大融資**（來源：funding_signals）
   OpenAI 宣布史無前例的融資案，估值達 $8,400 億美元。此融資規模打破所有紀錄，顯示資本對 AI 基礎設施的極度樂觀。預計將大規模招募 AI 研究科學家與 ML 工程師。

3. **eBay 裁員 800 人，三年內第三次大規模縮減**（來源：workforce_news）
   eBay 宣布裁員 800 名員工，反映電商平台持續面臨的營運壓力。連續三年裁員顯示該公司正在經歷長期結構性調整。

4. **SaaS 公司 IPO 明顯缺席，傳統 SaaS 面臨 AI 衝擊**（來源：funding_signals）
   儘管 2026 年 IPO 市場整體正常運作（建築科技、太空科技、生技持續上市），SaaS 公司卻明顯缺席。投資人質疑傳統 SaaS 是否會被 AI 原生產品取代，人才可能流向 AI 賽道。

5. **太空科技融資持續飛漲，2025 年達 $120 億美元**（來源：funding_signals）
   Crunchbase 數據顯示太空科技產業 2025 年融資達 $120 億美元高峰，2026 年延續強勁勢頭。商業太空時代來臨，人才需求橫跨傳統航太工程與新興軟體/AI 領域。

---

## AI 取代向量觀察

| 取代向量 | 本週信號 | 代表性事件/數據 |
|----------|----------|-----------------|
| [認知例行](/glossary/#認知例行cognitive-routine)（cognitive_routine） | 升溫 | Block 裁員瞄準可自動化崗位；「AI-washing」現象反映企業以 AI 為由進行效率優化 |
| [認知非例行](/glossary/#認知非例行cognitive-non-routine)（cognitive_nonroutine） | 持平 | OpenAI $1,100 億融資帶動 AI 研究員需求；高階工程師薪資維持 $200K-$400K |
| [體力例行](/glossary/#體力例行physical-routine)（physical_routine） | 持平 | 台灣製造業職缺 14 筆（1.4%），倉儲機器人融資顯示長期自動化趨勢 |
| [體力非例行](/glossary/#體力非例行physical-non-routine)（physical_nonroutine） | 降溫 | 零售服務業職缺仍佔台灣最大宗（48%），人力需求穩定（來源：tw_govjobs） |
| [高度人際](/glossary/#高度人際interpersonal)（interpersonal） | 持平 | 教育、照護類職缺維持需求；遠端教育平台持續招募 |

---

## 本週行動清單

基於本週數據，建議以下行動：

### 求職者

- [ ] **評估產業風向**：若目前在 Fintech/支付、電商、傳統 SaaS 領域，建議關注公司財務狀況與 AI 轉型計劃，Block、eBay 裁員顯示這些領域仍在調整（依據：本週裁員事件）
- [ ] **關注 AI 原生職缺**：OpenAI $1,100 億融資將帶動大規模招募，AI 研究員、ML 工程師、AI 產品經理為優先標的
- [ ] **探索太空科技賽道**：2025 年 $120 億產業融資顯示長期成長潛力，航太工程 + AI/ML 跨領域技能具高價值
- [ ] **準備面對 SaaS 轉型**：傳統 SaaS IPO 缺席，考慮向 AI 賦能 SaaS 或 AI 原生產品方向發展技能
- [ ] **追蹤獨角獸動態**：Crunchbase 獨角獸榜單持續更新，追蹤高成長公司有助識別招募機會

### 在職者

- [ ] **評估公司 AI 策略**：Block、Pinterest 以「AI 轉型」為由裁員，確認自身公司的 AI 佈局與個人定位
- [ ] **強化跨領域技能**：Fintech + AI、太空科技 + AI 等交叉領域需求上升，跨領域人才更具抗風險能力

### 下週關注

- Block 裁員後續影響與其他公司是否跟進（Jack Dorsey 暗示將有更多公司採取類似行動）
- OpenAI 融資後的招募動態
- 美國 2026 年 1 月就業數據發布

---

## 資料來源明細

> 本報告使用 Qdrant 向量搜尋取得相關資料，資料來源包括：

| Layer | 筆數 | 更新時間 | 狀態 |
|-------|------|----------|------|
| tw_govjobs | 1,000 | 2026-02-28 | 有效 |
| global_hn_hiring | 2,336 | 2026-02-06 | 有效 |
| global_arbeitnow | 1,181 | 2026-02-06 | 有效 |
| global_remoteok | 94 | 2026-02-28 | 有效 |
| global_weworkremotely | 99 | 2026-02-28 | 有效 |
| global_linkedin_workforce | 61 | 2026-02-08 | 有效 |
| global_bls | 143 | 2026-01-28 | 有效 |
| global_ilo_stats | 72 | 2026-02-08 | 有效 |
| global_oecd_stats | 1,263 | 2026-02-08 | 有效 |
| global_statcan | 108 | 2026-02-08 | 有效 |
| global_hays_salary | 40 | 2026-02-08 | 有效 |
| global_stackoverflow | 23 | 2026-02-08 | 有效 |
| workforce_news | 27 | 2026-02-28 | 有效 |
| funding_signals | 47 | 2026-02-28 | 有效 |
| global_adzuna | 400 | 2026-02-08 | 有效 |

**總計**：6,894 筆觀測數據

---

## 免責聲明

本報告為自動化分析產出，僅供參考。就業市場判讀基於有限的觀測數據源，不代表完整的市場狀況。「溫度」指標為綜合性定性判斷，非精確量化指數。任何就業或投資決策請諮詢專業人士。

資料來源的更新頻率不一（部分為即時、部分為月度或季度），跨來源比較時應注意時間差異。tw_104_jobs 與 tw_company_reviews 因 API 存取限制暫時停用，台灣專業人才市場動態資訊有所不足。

---

最後更新：2026-02-28
