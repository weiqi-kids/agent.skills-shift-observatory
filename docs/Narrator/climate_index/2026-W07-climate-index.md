---
layout: default
title: W07
parent: 景氣溫度計
nav_order: 9993
permalink: /reports/climate-index-w07/
report_title: "就業景氣溫度計 — 2026年第07週"
mode: climate_index
period: "2026-W07"
generated_at: "2026-02-07T18:00:00Z"
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
  - global_indeed_hiring
  - global_manpower_outlook
  - workforce_news
  - funding_signals
data_coverage:
  layers_available: 9
  layers_total: 14
  observation_period: "2026-02-03 ~ 2026-02-07"
---

# 就業景氣溫度計 — 2026年第07週

## 本週溫度：🟡 持平

> AI 基礎模型融資創紀錄，傳統科技業重組持續，市場呈現結構性分化。

## 核心指標

### 台灣市場

| 指標 | 本週 | 前週 | 變化 | 來源 |
|------|------|------|------|------|
| 政府平台職缺數 | 1,000 | 1,000 | - | tw_govjobs |
| 裁員事件數 | 3 | 3 | - | workforce_news |
| 招聘潮事件數 | 0 | 0 | - | workforce_news |
| 本週融資事件數 | 7 | 5 | +2 | funding_signals |

**備註**：tw_104_jobs、tw_company_reviews 數據未更新，台灣市場的完整職缺數量、薪資區間變化無法計算。政府平台職缺以零售服務類（481筆）、科技類（92筆）、專業服務類（85筆）為主要需求，結構與前週相似。

### 全球市場

| 指標 | 最新值 | 前期值 | 趨勢 | 來源 |
|------|--------|--------|------|------|
| 美國非農就業（月增） | +50K | +50K | → | global_bls |
| 美國失業率 | 4.4% | 4.4% | → | global_bls |
| OECD 平均失業率 | - | - | 數據未更新 | global_oecd_employment |
| ManpowerGroup 淨展望 | 人才短缺加劇 | - | → | global_manpower_outlook |
| Indeed 招聘趨勢 | AI 職缺持續成長 | AI 職缺逆勢成長 | ↑（AI）/↓（整體） | global_indeed_hiring |
| LinkedIn 人才需求趨勢 | AI 改變招聘模式 | AI 主導人才策略 | → | global_linkedin_workforce |
| HN Hiring 職缺數 | 2,336 | 2,336 | → | global_hn_hiring |
| Arbeitnow 職缺數 | 1,181 | 1,181 | → | global_arbeitnow |
| 遠端職缺數 | 193 | 193 | → | global_remoteok + global_weworkremotely |

> **數據覆蓋說明**：本週共有 9/14 個 Layer 提供有效數據。缺失的 Layer 包括：tw_104_jobs（API 風險中等）、tw_company_reviews（已停用）、global_ilo_stats（數據未更新）、global_oecd_employment（數據未更新）、global_wef_jobs（需手動下載）。

## 溫度判讀依據

**台灣市場核心態勢**：台灣就業通平台觀測到 1,000 筆有效職缺，與前週持平。職缺結構仍以零售服務業（481筆）佔比最高（48%），科技類職缺（92筆）與專業服務類（85筆）維持穩定。農曆年後（1月底）的復甦態勢持續，但由於缺乏 104 人力銀行的完整數據，無法判斷民間市場的擴張或收縮趨勢，因此台灣市場判定為「持平偏保守」。（來源：tw_govjobs）

**全球市場背景**：美國 2025 年 12 月非農就業總人數達 159,526 千人，較 11 月增加約 50 千人（159,476K → 159,526K），失業率維持在 4.4%，顯示美國勞動市場整體穩健。Indeed Hiring Lab 報告與 Qdrant 搜尋結果顯示，AI 採用正在加速但仍集中於大型企業，形成「大企業 AI 熱、中小企業觀望」的分化格局。ManpowerGroup 2026 全球人才短缺報告指出，人才短缺問題持續加劇。（來源：global_bls、global_indeed_hiring、global_manpower_outlook）

**事件面信號（裁員/融資/政策）**：本週裁員事件維持 3 起（Pinterest 裁員 15%、Vimeo 併購後裁員、Meta Reality Labs 裁員 10%），與前週持平。融資面則呈現強勁信號：Ricursive Intelligence 創下紀錄，成立僅兩個月即完成 3 億美元 Series A 融資並達 40 億美元估值；Northwood Space 獲得 1 億美元 Series B 加上 5,000 萬美元政府合約；Zipline 6 億美元成長輪融資持續發酵。Crunchbase 報導 2025 年 Q4 新獨角獸數量達 2022 年 Q2 以來最高（12 月有 23 家公司加入），金融科技領域領先成長。資金持續大量湧入 AI 基礎模型與太空科技領域。（來源：workforce_news、funding_signals）

**AI 產業觀察**：本週最值得關注的是 AI 作為「基礎設施層」的定位愈加明確。Crunchbase News 分析指出，AI 不是一個獨立的產業部門，而是正在被嵌入到每個產業中，如同網際網路曾經做到的一樣。投資者預測 AI 將在 2026 年對企業勞動力市場產生實質影響。這意味著 AI 技能將成為所有產業的橫向需求，而非僅限於 AI 公司。（來源：funding_signals、workforce_news）

**綜合研判**：本週延續 W06 的「結構性調整」態勢。傳統科技崗位（VR/AR、社群媒體內容團隊、影音平台）持續收縮，但 AI 相關職缺與基礎模型新創融資創新高。Ricursive Intelligence 成立兩個月即成為獨角獸的案例，顯示資本對 AI 基礎模型的極度樂觀。失業率穩定與非農就業持續成長顯示勞動市場基本面仍可，但招聘活動整體趨於保守。IPO 窗口的不確定性（年初開放但可能正在關閉）也增加了高成長公司員工股權變現的風險。綜合以上，判定本週溫度維持「持平」——市場未顯著惡化也未顯著回暖，正在經歷 AI 驅動的人才需求結構深度轉型。

## 產業亮點與警訊

### 擴張信號
- **AI/基礎模型**：Ricursive Intelligence 成立兩個月即獲 3 億美元 Series A，估值 40 億美元，創下 AI 新創融資紀錄（來源：funding_signals）
- **太空科技**：Northwood Space 獲 1 億美元 Series B + 5,000 萬美元政府合約，SpaceX 躍升獨角獸榜首（來源：funding_signals）
- **無人機物流**：Zipline 6 億美元成長輪融資，配送量一年內翻倍（100 萬 → 200 萬次）（來源：funding_signals）
- **金融科技 x AI**：Zocks 獲 4,500 萬美元 Series B，由 Lightspeed、QED 領投，財務顧問 AI 助理需求旺盛（來源：funding_signals）

### 收縮信號
- **社群媒體**：Pinterest 裁員 15%，明確將資源重新分配至 AI（來源：workforce_news）
- **VR/AR 元宇宙**：Meta Reality Labs 裁員 10%（約 1,000 人），VR/AR 投資回報仍不明朗（來源：workforce_news）
- **影音平台**：Vimeo 被 Bending Spoons 收購後啟動裁員（來源：workforce_news）

### 值得關注
- **IPO 市場不確定性**：Crunchbase 報導 IPO 窗口年初開放但可能正在關閉，SpaceX、OpenAI 等公司的 IPO 時程不明（來源：funding_signals）
- **AI 人才分化**：Indeed 報告顯示 AI 採用集中於大型企業，中小企業存在「被拋在後面」的風險（來源：global_indeed_hiring）
- **招聘模式轉型**：LinkedIn 報告指出 AI 正在改變招聘遊戲規則，招聘人員需要像顧問一樣思考（來源：global_linkedin_workforce）

## 本週重大事件

1. **Ricursive Intelligence 創紀錄融資**（來源：funding_signals）
   前沿 AI 實驗室 Ricursive Intelligence 成立僅兩個月即完成 3 億美元 Series A 融資，估值達 40 億美元。如此快速且大規模的融資極為罕見，顯示投資人對 AI 基礎模型領域的激進投注，預期將大規模招募頂級 AI 研究科學家與 ML 工程師。

2. **Northwood Space 太空基礎設施雙喜臨門**（來源：funding_signals）
   衛星通訊基礎設施公司 Northwood Space 獲得 1 億美元 Series B 融資（由 Washington Harbour、a16z 投資）加上 5,000 萬美元政府合約，顯示太空科技領域的商業與政府市場雙軌發展策略。預期將擴充航太工程、射頻系統、地面站建設等團隊。

3. **2025 Q4 新獨角獸創近三年新高**（來源：funding_signals）
   2025 年第四季度新獨角獸數量達 2022 年 Q2 以來最高，12 月有 23 家公司加入獨角獸行列。SpaceX 躍升榜首，金融科技領域領先成長。高成長新創公司的人才需求將持續旺盛。

4. **AI 作為基礎設施層的定位明確化**（來源：funding_signals）
   Crunchbase News 專欄分析指出 AI 不是獨立的產業部門，而是基礎設施層，正在被嵌入到每個產業中。這意味著 AI 技能將成為所有產業的橫向需求，傳統產業的「產業 + AI」混合職位將快速成長。

5. **Pinterest 轉型 AI 優先**（來源：workforce_news）
   Pinterest 宣布裁員 15% 員工，將資源重新分配至「AI 聚焦角色和團隊」，公司表示將「優先發展 AI 驅動的產品和能力」。此舉反映社群媒體產業正從傳統內容營運轉向 AI 驅動的個人化推薦，是科技業「人力重組而非縮編」的典型案例。

## AI 取代向量觀察

| 取代向量 | 本週信號 | 代表性事件/數據 |
|----------|----------|-----------------|
| 認知例行（cognitive_routine） | 升溫 | Pinterest、Vimeo 裁員涉及內容營運與客服團隊；Zocks 財務顧問 AI 助理融資顯示例行認知工作自動化加速 |
| 認知非例行（cognitive_nonroutine） | 持平 | Ricursive Intelligence 融資顯示 AI 研究人才需求強勁，但 AI 輔助工具也在增加專業判斷的可自動化程度 |
| 體力例行（physical_routine） | 升溫 | Zipline 無人機配送量翻倍、Northwood Space 太空基礎設施擴張，物流自動化加速 |
| 體力非例行（physical_nonroutine） | 降溫 | tw_govjobs 顯示清潔、餐飲、美髮等人力需求穩定，AI/機器人取代壓力低 |
| 高度人際（interpersonal） | 持平 | 服務業職缺穩定（tw_govjobs 零售服務佔 48%），LinkedIn 報告顯示招聘人員需轉型為顧問角色 |

## 免責聲明

本報告為自動化分析產出，僅供參考。就業市場判讀基於有限的觀測數據源，不代表完整的市場狀況。「溫度」指標為綜合性定性判斷，非精確量化指數。任何就業或投資決策請諮詢專業人士。數據來源的更新頻率不一（部分為即時、部分為月度或季度），跨來源比較時應注意時間差異。

---

**資料來源說明**

| Layer | 狀態 | 最新數據時間 | 備註 |
|-------|------|--------------|------|
| tw_govjobs | 有效 | 2026-02-04 | 1,000 筆職缺 |
| tw_104_jobs | 數據未更新 | - | API 風險中等 |
| tw_company_reviews | 已停用 | - | 網站已關閉 |
| global_arbeitnow | 有效 | 2026-02 | 1,181 筆職缺（歐洲/德國為主） |
| global_hn_hiring | 有效 | 2026-02 | 2,336 筆職缺（北美科技業） |
| global_remoteok | 有效 | 2026-02 | 94 筆遠端職缺 |
| global_weworkremotely | 有效 | 2026-02 | 99 筆遠端職缺 |
| global_bls | 有效 | 2025-12 | 非農就業、失業率 |
| global_hays_salary | 部分有效 | 2026 | Hays USA/Canada/UK 薪資指南 |
| global_stackoverflow | 有效 | 2025 | 開發者調查 |
| global_linkedin_workforce | 部分有效 | 2026-01 | AI 改變招聘模式報告 |
| global_indeed_hiring | 有效 | 2026-01 | AI 採用分化報告、12月就業報告 |
| global_manpower_outlook | 有效 | 2026 | 全球人才短缺報告 |
| global_ilo_stats | 數據未更新 | - | - |
| global_oecd_employment | 數據未更新 | - | - |
| global_wef_jobs | 需手動下載 | - | CDN 封鎖自動化存取 |
| workforce_news | 有效 | 2026-01-27 | 20 筆事件（含 12 筆裁員） |
| funding_signals | 有效 | 2026-01-27 | 37 筆事件（含融資輪、市場趨勢） |

**本報告使用 Qdrant 向量搜尋取得相關資料**，搜尋結果涵蓋就業市場趨勢、AI 對就業影響、薪資趨勢等主題，並與 docs/Extractor 目錄下的結構化資料交叉驗證。

---

最後更新：2026-02-07
