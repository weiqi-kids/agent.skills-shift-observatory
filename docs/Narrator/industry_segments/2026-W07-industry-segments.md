---
layout: default
title: W07
parent: 產業分層
nav_order: 9993
permalink: /reports/industry-segments-w07/
report_title: "產業分層報告 — 2026年第07週"
mode: industry_segments
period: "2026-W07"
generated_at: "2026-02-07T16:00:00Z"
source_layers:
  - tw_govjobs
  - global_arbeitnow
  - global_hn_hiring
  - global_remoteok
  - global_weworkremotely
  - workforce_news
  - funding_signals
  - global_hays_salary
  - global_indeed_hiring
  - global_linkedin_workforce
data_coverage:
  layers_available: 10
  layers_total: 10
  industries_covered: 14/14
  observation_period: "2026-01-27 ~ 2026-02-07"
confidence: "中"
---

# 產業分層報告 — 2026年第07週

> 本報告使用 Qdrant 向量搜尋取得相關資料，結合 Hays 薪資指南、Indeed 招聘趨勢、LinkedIn 職缺需求等全球資料源進行產業分析。

## 摘要

> 本週觀測 4,710 筆職缺資料，涵蓋台灣微觀資料（tw_govjobs 1,000 筆）與全球宏觀資料（global_arbeitnow 1,181 筆、global_hn_hiring 2,336 筆、遠端職缺 193 筆）。軟體與 SaaS 產業持續主導全球科技人才需求，佔整體觀測職缺超過 60%。本週最重大事件包括：(1) Ricursive Intelligence 以成立兩個月即完成 3 億美元 Series A 融資、估值達 40 億美元的驚人紀錄，顯示 AI 基礎設施投資持續升溫；(2) Pinterest 裁員 15%，明確表示將資源重新分配至 AI 相關團隊；(3) Meta Reality Labs 裁員 10%（約 1,000 人），VR/AR 領域持續收縮。根據 Hays 2025 薪資指南與 Indeed 招聘趨勢報告，AI 採用仍高度集中於大型企業，但正加速擴散至各產業。

## 產業總覽

| 產業 | 職缺數 | 主要來源 | 擴張/收縮 | AI 衝擊 | 綜合評級 |
|------|--------|----------|----------|---------|----------|
| 軟體與 SaaS | 2,847 | global_hn_hiring, global_arbeitnow | 擴張 | 中 | ***** |
| 半導體 | <50 | 小樣本 | 穩定 | 中 | *** |
| 電子硬體 | <50 | 小樣本 | 穩定 | 中 | *** |
| 金融服務 | 181 | global_arbeitnow, tw_govjobs | 擴張 | 高 | **** |
| 醫療生技 | 76 | tw_govjobs | 穩定 | 低 | **** |
| 製造業 | 14 | tw_govjobs | 穩定 | 高 | ** |
| 零售電商 | 481 | tw_govjobs | 穩定 | 中 | *** |
| 媒體娛樂 | 56 | tw_govjobs (creative) | 收縮 | 高 | ** |
| 教育 | 16 | tw_govjobs | 穩定 | 中 | *** |
| 能源與綠能 | <50 | 小樣本 | 穩定 | 低 | **** |
| 營建不動產 | 18 | tw_govjobs | 穩定 | 低 | *** |
| 電信 | <50 | 小樣本 | 擴張 | 中 | *** |
| 政府與非營利 | 87 | tw_govjobs | 穩定 | 低 | *** |
| 專業服務 | 85 | tw_govjobs | 穩定 | 中 | *** |

> **綜合評級說明**：基於職缺數量、產業融資動態、裁員事件的綜合評估。星等越多表示該產業當前求職環境越友善。此評級為定性判斷，僅供參考。小樣本產業（<50 筆）的評級需謹慎解讀。

---

## 各產業詳細分析

### 1. 軟體與 SaaS（software_saas）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 2,847 | global_hn_hiring (2,336), global_arbeitnow tech (489), global_remoteok tech (68), global_weworkremotely programming (24) |
| 主要地區 | 北美（HN Hiring）、歐洲（Arbeitnow）、全球遠端 | 綜合來源 |
| 薪資參考 | $115K-$272K USD（資深工程師） | global_hn_hiring |

#### 熱門角色 Top 5
| 角色 | 職缺數 | 佔比 | 來源 |
|------|--------|------|------|
| Backend Engineer | 902 | 39% | global_hn_hiring |
| Full Stack Engineer | 646 | 28% | global_hn_hiring |
| Frontend Engineer | 241 | 10% | global_hn_hiring |
| DevOps/SRE | 133 | 6% | global_hn_hiring |
| Data Engineer | 76 | 3% | global_hn_hiring |

#### 熱門技能 Top 5
| 技能 | 說明 | 來源 |
|------|------|------|
| Python/Go/Rust | 後端開發主流語言 | global_hn_hiring 職缺描述 |
| React/Vue/TypeScript | 前端框架需求穩定 | global_hn_hiring 職缺描述 |
| Kubernetes/Docker | 容器化與編排技術 | global_hn_hiring DevOps 職缺 |
| PostgreSQL/MySQL | 關聯式資料庫 | global_hn_hiring 職缺描述 |
| AWS/GCP | 雲端平台技能 | global_hn_hiring, global_remoteok |

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 程式碼生成工具（如 GitHub Copilot）正在改變基礎開發工作 |
| 認知非例行 | 中 | 系統架構設計、技術決策仍需人類判斷 |
| 體力例行 | 低 | 軟體開發不涉及體力工作 |
| 體力非例行 | 低 | 軟體開發不涉及體力工作 |
| 高度人際 | 中 | 技術溝通、客戶對接仍需人際技能 |

#### 事件信號
- 擴張信號：Ricursive Intelligence 獲 3 億美元 A 輪融資（估值 40 億美元，成立僅兩個月）[^1]
- 擴張信號：Northwood Space 獲 1 億美元 Series B 融資及 5,000 萬美元政府合約（衛星通訊基礎設施）[^2]
- 收縮信號：Pinterest 裁員 15%，資源轉向 AI[^3]

#### 全球對標
根據 Hays UK 2025 Tech Talent Explorer[^4]，英國科技人才需求持續強勁，尤其在 AI/ML 工程師與雲端架構師領域。Indeed 研究指出 AI 採用正在加速，但仍高度集中於大型企業[^5]。LinkedIn 最新職缺需求報告[^6]顯示，軟體工程師、資料科學家、雲端架構師持續位列全球最熱門職缺。北美科技新創對後端工程師的需求佔比最高（39%），反映微服務架構與 API 經濟的持續發展。

---

### 2. 半導體（semiconductor）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | <50 | 小樣本，數據僅供參考 |
| 主要地區 | 台灣、歐洲 | tw_govjobs, global_arbeitnow |

> **小樣本警告**：本週觀測到的半導體職缺數量不足 50 筆，統計數據可能有較大偏差。

#### 熱門角色
基於有限樣本觀察：
- FPGA Development Engineer（global_weworkremotely）
- Semiconductor Design Manager（global_weworkremotely）
- Hardware Manufacturing Engineer（global_arbeitnow）

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | EDA 工具自動化部分設計流程 |
| 認知非例行 | 低 | 晶片架構設計需高度專業判斷 |
| 體力例行 | 高 | 晶圓廠生產線自動化程度高 |
| 體力非例行 | 中 | 設備維護與問題排除需技術人員 |
| 高度人際 | 低 | 技術導向，人際互動需求較低 |

#### 事件信號
- 無本週重大事件

#### 全球對標
半導體產業為資本密集產業，職缺波動與產能擴張週期高度相關。本系統目前缺乏專門的半導體職缺資料源，建議未來新增 Glassdoor 或 LinkedIn 的半導體產業職缺追蹤。

---

### 3. 電子硬體（electronics_hardware）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | <50 | 小樣本，數據僅供參考 |

> **小樣本警告**：本週觀測到的電子硬體職缺數量不足 50 筆。

#### 熱門角色
- Hardware Infrastructure Site Reliability Engineer（global_remoteok - SpaceX）
- Product Designer (Hardware/3D CAD)（global_weworkremotely）

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | PCB 設計部分流程可自動化 |
| 認知非例行 | 低 | 硬體系統整合需跨領域專業 |
| 體力例行 | 高 | 組裝生產線高度自動化 |
| 體力非例行 | 中 | 產品測試與維修需技術人員 |
| 高度人際 | 低 | 研發導向，人際需求較低 |

#### 事件信號
- 收縮信號：Meta Reality Labs 裁員 10%（約 1,000 人），VR/AR 硬體領域持續調整[^7]

---

### 4. 金融服務（financial_services）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 181 | tw_govjobs finance (31), global_arbeitnow finance (50), global_arbeitnow hr (46), global_remoteok finance (4), global_weworkremotely management/finance (50) |
| 主要地區 | 台灣、德國、北美 | tw_govjobs, global_arbeitnow, global_weworkremotely |

#### 熱門角色 Top 5
| 角色 | 來源 |
|------|------|
| Senior Accountant | global_arbeitnow |
| Head of Finance | global_arbeitnow |
| Finance Manager | global_weworkremotely |
| Financial Advisor | global_remoteok |
| 銀行清潔人員（委外） | tw_govjobs |

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 財務報表、數據輸入高度自動化 |
| 認知非例行 | 中 | 投資分析、風險評估 AI 輔助增加 |
| 體力例行 | 低 | 金融服務不涉及體力工作 |
| 體力非例行 | 低 | 金融服務不涉及體力工作 |
| 高度人際 | 中 | 客戶關係管理、財務諮詢需人際技能 |

#### 事件信號
- 收縮信號：Capital One 以 51.5 億美元收購 Fintech 新創 Brex（低於峰值估值一半），併購後可能伴隨組織重組[^8]
- 擴張信號：Zocks 獲 4,500 萬美元 B 輪融資，專注 AI 財務顧問助手[^9]

#### 全球對標
根據 Hays USA 2025 Salary Guide[^10] 與 Hays Canada FY25 Salary Guide[^11]，金融服務業對具備 AI 技能的財務分析師需求持續增長。Fintech 整併活躍，Brex 被收購顯示企業支付卡市場進入整併階段。AI 在金融領域的應用（如 Zocks 的 AI 財務顧問助手）正在改變顧問服務的人力結構。

---

### 5. 醫療生技（healthcare_biotech）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 76 | tw_govjobs healthcare (66), tw_govjobs care (10) |
| 薪資參考 | 28,000-45,000 TWD/月（照服員） | tw_govjobs |
| 主要地區 | 台灣 | tw_govjobs |

#### 熱門角色 Top 5
| 角色 | 職缺數 | 來源 |
|------|--------|------|
| 照顧服務員 | 10+ | tw_govjobs care |
| 培訓設計師（美容美髮） | 若干 | tw_govjobs healthcare |
| 家庭照顧服務員 | 若干 | tw_govjobs healthcare |
| Licensed Professional Counselor | 若干 | global_remoteok |

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | 醫療影像判讀 AI 輔助增加 |
| 認知非例行 | 低 | 診斷決策仍需醫師專業判斷 |
| 體力例行 | 低 | 照護工作需要人類直接接觸 |
| 體力非例行 | 低 | 護理、照顧服務需靈活應對 |
| 高度人際 | 高度保護 | 病患關懷、情緒支持不可取代 |

#### 事件信號
- 無重大裁員或擴張事件
- **推測**：台灣高齡化趨勢持續，照顧服務員需求預期穩定成長

#### 全球對標
醫療生技產業受人口結構影響大於科技週期。台灣的照顧服務員職缺反映高齡化社會的人力需求。此產業受 AI 衝擊相對較低，因為醫療照護的核心價值在於人際互動與情緒支持。

---

### 6. 製造業（manufacturing）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 14 | tw_govjobs manufacturing |
| 薪資參考 | 35,000-45,000 TWD/月 | tw_govjobs |
| 主要地區 | 台灣 | tw_govjobs |

> **小樣本警告**：本週觀測到的製造業職缺數量不足 50 筆。

#### 熱門角色
- 空調鍋爐技術員
- 職業安全衛生管理員
- 病媒防治技術員

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | 品管檢測部分自動化 |
| 認知非例行 | 低 | 製程優化需工程師判斷 |
| 體力例行 | 高 | 生產線自動化程度持續提高 |
| 體力非例行 | 中 | 設備維護與異常處理需技術人員 |
| 高度人際 | 低 | 製造業人際互動需求較低 |

#### 事件信號
- 無本週重大事件

---

### 7. 零售電商（retail_ecommerce）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 481 | tw_govjobs retail_service |
| 薪資參考 | 面議-200 TWD/時（兼職）、30K-53K TWD/月（正職） | tw_govjobs |
| 主要地區 | 台灣（台北市為主） | tw_govjobs |

#### 熱門角色 Top 5
| 角色 | 職缺數 | 來源 |
|------|--------|------|
| 門市服務員 | 200+ | tw_govjobs retail_service |
| 餐飲內外場人員 | 150+ | tw_govjobs retail_service |
| 房務員 | 30+ | tw_govjobs retail_service |
| 廚師/廚助 | 50+ | tw_govjobs retail_service |
| 銷售顧問 | 若干 | tw_govjobs retail_service |

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 收銀、庫存管理自動化增加 |
| 認知非例行 | 低 | 顧客服務需臨場應變 |
| 體力例行 | 中 | 自助結帳、機器人上菜逐漸普及 |
| 體力非例行 | 低 | 餐飲服務需靈活應對 |
| 高度人際 | 中度保護 | 顧客互動、服務體驗仍需人力 |

#### 事件信號
- 無本週重大事件

#### 全球對標
台灣零售服務業職缺集中於餐飲連鎖（如堤諾、瓦薩、拉亞漢堡）與飯店業，反映服務業復甦與勞動密集特性。

---

### 8. 媒體娛樂（media_entertainment）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 56 | tw_govjobs creative |
| 主要地區 | 台灣 | tw_govjobs |

#### 熱門角色
- 業務專員/行銷專員
- 影音相關職位（推測）

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 內容審核、影片標籤自動化 |
| 認知非例行 | 高 | AI 生成內容（文字、圖像、影片）快速發展 |
| 體力例行 | 低 | 媒體娛樂不涉及體力工作 |
| 體力非例行 | 低 | 媒體娛樂不涉及體力工作 |
| 高度人際 | 中 | 創意發想、客戶提案需人際技能 |

#### 事件信號
- 收縮信號：Pinterest 裁員 15%，資源轉向 AI[^3]
- 收縮信號：Vimeo 被 Bending Spoons 收購後啟動裁員[^12]

#### 全球對標
媒體娛樂產業正經歷 AI 驅動的結構性轉型。Pinterest、Vimeo 的裁員均提及將資源重新分配至 AI。這反映平台型媒體公司正以 AI 取代部分人力密集的內容審核與推薦功能。

---

### 9. 教育（education）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 16 | tw_govjobs education |

> **小樣本警告**：本週觀測到的教育產業職缺數量不足 50 筆。

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 題庫、作業批改可自動化 |
| 認知非例行 | 中 | 課程設計、教學策略需專業判斷 |
| 體力例行 | 低 | 教育不涉及體力工作 |
| 體力非例行 | 低 | 教育不涉及體力工作 |
| 高度人際 | 高度保護 | 學生輔導、情緒支持不可取代 |

#### 事件信號
- 無重大事件

---

### 10. 能源與綠能（energy_green）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | <50 | 小樣本 |

> **小樣本警告**：本週觀測到的能源與綠能職缺數量不足 50 筆。

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | 能源調度部分可自動化 |
| 認知非例行 | 低 | 能源系統設計需工程專業 |
| 體力例行 | 中 | 發電廠運維自動化增加 |
| 體力非例行 | 低 | 現場維護需技術人員 |
| 高度人際 | 低 | 技術導向，人際需求較低 |

#### 事件信號
- 無本週重大事件

---

### 11. 營建不動產（construction_realestate）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 18 | tw_govjobs construction |
| 薪資參考 | 面議 | tw_govjobs |
| 主要地區 | 台灣 | tw_govjobs |

> **小樣本警告**：本週觀測到的營建不動產職缺數量不足 50 筆。

#### 熱門角色
- 工地主任
- 測量助理
- 安管員
- 工務工程師

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 中 | BIM 設計部分流程自動化 |
| 認知非例行 | 低 | 建築設計需創意與專業判斷 |
| 體力例行 | 中 | 預製構件減少現場人力 |
| 體力非例行 | 低 | 現場施工需靈活應對 |
| 高度人際 | 低 | 技術導向，人際需求較低 |

#### 事件信號
- 擴張信號：Cambio 獲 1,800 萬美元融資（估值 1 億美元），發展 AI 商業地產軟體[^13]

---

### 12. 電信（telecom）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | <50 | 小樣本 |

> **小樣本警告**：本週觀測到的電信產業職缺數量不足 50 筆。

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 客服、帳務自動化程度高 |
| 認知非例行 | 中 | 網路規劃需工程專業 |
| 體力例行 | 中 | 機房維運自動化增加 |
| 體力非例行 | 低 | 基地台維護需現場技術人員 |
| 高度人際 | 中 | 企業客戶銷售需人際技能 |

#### 事件信號
- 擴張信號：Northwood Space 獲 1 億美元 B 輪融資及 5,000 萬美元政府合約（衛星通訊）[^2]

---

### 13. 政府與非營利（government_ngo）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 87 | tw_govjobs professional (85) + public_service (2) |
| 主要地區 | 台灣 | tw_govjobs |

#### 熱門角色
- 行政助理
- 社區主任
- 推展員
- 外國人業務訪查員
- 儲備幹部

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 公文處理、資料建檔可自動化 |
| 認知非例行 | 低 | 政策制定需專業判斷 |
| 體力例行 | 低 | 政府工作不涉及體力勞動 |
| 體力非例行 | 低 | 政府工作不涉及體力勞動 |
| 高度人際 | 中度保護 | 民眾服務、社會福利需人際互動 |

#### 事件信號
- 無重大事件

---

### 14. 專業服務（professional_services）

#### 市場數據
| 指標 | 數值 | 來源 |
|------|------|------|
| 觀測職缺數 | 85 | tw_govjobs professional |
| 主要地區 | 台灣 | tw_govjobs |

#### 熱門角色
- 儀器貿易業務助理
- 國外進口採購
- 儲備幹部
- 總務清潔人員

#### AI 取代向量影響
| 向量 | 影響程度 | 說明 |
|------|----------|------|
| 認知例行 | 高 | 文件審閱、資料分析可自動化 |
| 認知非例行 | 中 | 專業諮詢需人類判斷 |
| 體力例行 | 低 | 專業服務不涉及體力工作 |
| 體力非例行 | 低 | 專業服務不涉及體力工作 |
| 高度人際 | 中度保護 | 客戶關係、諮詢服務需人際技能 |

#### 事件信號
- 無重大事件

---

## 跨產業比較

### 職缺數量排名

| 排名 | 產業 | 職缺數 | 主要驅動因素 | 樣本說明 |
|------|------|--------|-------------|----------|
| 1 | 軟體與 SaaS | 2,847 | AI 基礎設施投資、雲端服務需求 | 主要來自 HN Hiring、Arbeitnow |
| 2 | 零售電商 | 481 | 服務業復甦、連鎖餐飲擴張 | 主要來自 tw_govjobs |
| 3 | 金融服務 | 181 | Fintech 整併、AI 財務顧問 | 跨來源綜合 |
| 4 | 政府與非營利 | 87 | 穩定需求 | tw_govjobs |
| 5 | 專業服務 | 85 | 穩定需求 | tw_govjobs |
| 6 | 醫療生技 | 76 | 高齡化、照護需求 | tw_govjobs |
| 7 | 媒體娛樂 | 56 | 創意產業 | tw_govjobs creative |
| 8-14 | 其他產業 | <50 | 樣本不足 | 小樣本 |

### AI 衝擊程度排名

| 排名 | 產業 | AI 衝擊綜合評分 | 最受影響的向量 | 最受影響的角色 |
|------|------|----------------|---------------|---------------|
| 1 | 媒體娛樂 | 高 | 認知非例行 | 內容創作者、影片編輯 |
| 2 | 金融服務 | 高 | 認知例行 | 資料輸入、財務分析師 |
| 3 | 製造業 | 高 | 體力例行 | 生產線作業員 |
| 4 | 軟體與 SaaS | 中 | 認知例行 | 初階程式設計師 |
| 5 | 專業服務 | 中 | 認知例行 | 行政助理、法務助理 |
| 6 | 教育 | 中 | 認知例行 | 題庫編輯、作業批改 |
| 7 | 零售電商 | 中 | 認知例行 | 收銀員、庫存管理 |
| 8 | 醫療生技 | 低 | 認知例行 | 影像判讀（輔助） |
| 9 | 營建不動產 | 低 | 認知例行 | BIM 設計（輔助） |
| 10 | 能源與綠能 | 低 | 體力例行 | 發電廠運維（部分） |

### 產業健康度矩陣

產業健康度依據「職缺成長信號」與「AI 衝擊程度」兩個維度評估：

**擴張 + 低 AI 衝擊**（最佳象限）：
- 醫療生技（高齡化驅動，人際互動受保護）
- 能源與綠能（政策驅動，技術門檻高）

**擴張 + 高 AI 衝擊**（機會與挑戰並存）：
- 軟體與 SaaS（需持續技能升級）
- 金融服務（Fintech 人才需求大，但基層職位被自動化）

**穩定/收縮 + 低 AI 衝擊**（相對安全）：
- 營建不動產（週期性波動，但核心職位穩定）
- 政府與非營利（穩定但成長有限）

**穩定/收縮 + 高 AI 衝擊**（需謹慎）：
- 媒體娛樂（多家公司裁員，AI 生成內容衝擊）
- 製造業（自動化持續推進）

---

## 台灣 vs 全球趨勢對比

| 產業 | 台灣趨勢 | 全球趨勢 | 一致性 | 說明 |
|------|----------|----------|--------|------|
| 軟體與 SaaS | 穩定 | 擴張 | 分歧 | 台灣缺乏 HN Hiring 類型的新創職缺資料，實際需求可能更高 |
| 金融服務 | 穩定 | 擴張 | 分歧 | 全球 Fintech 整併活躍，台灣金融業受法規限制，數位轉型較慢 |
| 零售電商 | 穩定 | 穩定 | 一致 | 服務業基層人力需求全球皆穩定 |
| 醫療生技 | 穩定 | 穩定 | 一致 | 高齡化為全球共同趨勢 |
| 媒體娛樂 | 穩定 | 收縮 | 分歧 | 全球平台型媒體裁員，台灣創意產業受影響較小 |
| 製造業 | 穩定 | 收縮 | 分歧 | 全球製造業自動化加速，台灣因半導體產業支撐相對穩定 |

---

## 分析師觀察

### 本週產業結構的主要變化

2026 年第 7 週的就業市場持續呈現「AI 重塑」特徵。Ricursive Intelligence 以成立兩個月即完成 3 億美元 Series A 融資、達到 40 億美元估值的驚人紀錄，再次證明資本市場對 AI 基礎模型的激進投注。同時，Pinterest 裁員 15% 並明確表示將資源重新分配至 AI 團隊，Meta Reality Labs 裁員 10%，顯示科技公司正在進行結構性的人力重組。

### 跨產業趨勢：AI 作為基礎設施層

根據 Crunchbase 專欄分析[^14]，AI 不應被視為獨立產業，而是「基礎設施層」——如同網際網路曾經是。Indeed 研究指出 AI 採用正在加速但仍高度集中於大型企業[^5]。這意味著：

1. AI 技能將成為所有產業的橫向需求，不限於科技公司
2. 「產業 + AI」混合職位將快速成長（如醫療 AI 工程師、金融 AI 分析師）
3. 單純的 AI 基礎研究職位競爭激烈，但應用層職位機會更廣

達沃斯世界經濟論壇的觀察[^15]也印證這一趨勢：AI 已取代氣候變遷成為全球領袖最關注的議題，科技 CEO 們對 AI 的發展既興奮又謹慎。

### 對求職者的啟示（基於觀測結果）

1. **軟體工程師**：後端與全端工程師需求最高，但需持續學習 AI 輔助開發工具
2. **金融從業者**：Fintech 整併創造流動機會，AI 財務顧問助手（如 Zocks）的興起意味著需學習 AI 協作技能
3. **媒體從業者**：平台型媒體收縮（Pinterest、Vimeo），但創作者經濟仍有空間
4. **服務業人員**：基層服務業需求穩定，但需關注自動化對收銀、庫存等職位的影響
5. **醫療照護人員**：高齡化驅動穩定需求，人際互動技能受保護

---

## 資料來源與限制

### 資料來源清單

| Layer | 筆數 | 涵蓋範圍 | 限制 |
|-------|------|----------|------|
| tw_govjobs | 1,000 | 台灣政府就業通 | 偏向基層職缺，科技職缺較少 |
| global_arbeitnow | 1,181 | 歐洲（德國為主） | 語言限制，非英語職缺較多 |
| global_hn_hiring | 2,336 | 北美科技新創 | 偏向科技業，薪資偏高 |
| global_remoteok | 94 | 全球遠端職缺 | 樣本量小 |
| global_weworkremotely | 99 | 全球遠端職缺 | 樣本量小 |
| workforce_news | 20+ | 裁員/擴編事件 | 以科技業為主 |
| funding_signals | 37+ | 融資動態 | 以科技業為主 |
| global_hays_salary | 3 | Hays 薪資指南（UK, USA, Canada） | Qdrant 向量搜尋取得 |
| global_indeed_hiring | 1 | Indeed 招聘趨勢 | Qdrant 向量搜尋取得 |
| global_linkedin_workforce | 1 | LinkedIn 職缺需求 | Qdrant 向量搜尋取得 |

### 分析限制

1. **樣本偏差**：職缺資料以科技業為主（HN Hiring 佔 50%），傳統產業資料不足
2. **地區偏差**：台灣資料僅來自政府就業通，缺少 104/1111 等主流人力銀行
3. **時間延遲**：融資與裁員事件為新聞報導，可能與實際發生時間有延遲
4. **產業歸類**：跨產業公司（如 Amazon 同時涵蓋電商、雲端、物流）的職缺歸類可能有模糊
5. **小樣本產業**：半導體、電子硬體、能源、電信等產業觀測樣本不足 50 筆，統計意義有限

---

## 免責聲明

本報告為自動化分析產出，僅供參考。產業分類基於系統預設的 14 大類，與實際企業自我歸類可能有差異。小樣本產業（觀測職缺數低於 50 筆）的統計數據可能有較大偏差，已在報告中標註。薪資數據基於職缺刊登的薪資區間，不代表實際支付薪資。任何就業或投資決策請諮詢專業人士。

本報告內容不構成：
- 個人化職涯諮詢建議
- 投資或財務建議
- 法律意見
- 就業保證或薪資承諾

---

## 參考文獻

[^1]: funding_signals, "AI Lab Ricursive Intelligence Lands $300M Series A At $4B Valuation", docs/Extractor/funding_signals/funding_round/20260126-ricursive-intelligence-funding_round.md
[^2]: funding_signals, "Northwood Space Raises $100M Series B And Lands $50M Government Contract", docs/Extractor/funding_signals/funding_round/20260127-northwood-space-funding_round.md
[^3]: workforce_news, "Pinterest layoffs impact 15% of staff as resources redirected to AI", docs/Extractor/workforce_news/layoff/20260127-pinterest-layoff.md
[^4]: global_hays_salary, "Hays Tech Talent Explorer — UK 2025", Qdrant 向量搜尋取得
[^5]: global_indeed_hiring, "AI Adoption Is Accelerating but Still Concentrated Among the Largest Firms", Qdrant 向量搜尋取得
[^6]: global_linkedin_workforce, "Most In Demand Jobs", Qdrant 向量搜尋取得
[^7]: workforce_news, "Meta to reportedly lay off 10% of Reality Labs staff", docs/Extractor/workforce_news/layoff/20260114-meta-reality-labs-layoff.md
[^8]: funding_signals, "Capital One To Buy Fintech Startup Brex At Less Than Half Its Peak Valuation In $5.15B Deal", docs/Extractor/funding_signals/acquisition/20260123-capital-one-brex-acquisition.md
[^9]: funding_signals, "Zocks Raises $45M Series B From Lightspeed, QED For AI Assistant To Financial Advisers", docs/Extractor/funding_signals/funding_round/20260126-zocks-funding_round.md
[^10]: global_hays_salary, "Hays USA 2025 Salary Guide & Hiring Trends", Qdrant 向量搜尋取得
[^11]: global_hays_salary, "Hays Canada FY25 Salary Guide & Hiring Trends", Qdrant 向量搜尋取得
[^12]: workforce_news, "Vimeo starts layoffs after acquisition by Bending Spoons", docs/Extractor/workforce_news/layoff/20260123-vimeo-layoff.md
[^13]: funding_signals, "Cambio Lands $18M At $100M Valuation For AI-Powered Commercial Real Estate Software", docs/Extractor/funding_signals/funding_round/20260122-cambio-funding_round.md
[^14]: funding_signals, "Beyond The Buzz: AI's Real Impact And Illusions We Must Avoid", docs/Extractor/funding_signals/market_trend/20260127-ai-infrastructure-impact-market_trend.md
[^15]: workforce_news, "AI CEOs transformed Davos into a tech conference", docs/Extractor/workforce_news/market_signal/20260123-davos-ai-ceos-market_signal.md

---

最後更新：2026-02-07
