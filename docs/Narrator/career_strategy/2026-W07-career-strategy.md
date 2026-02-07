---
layout: default
title: W07
parent: 求職策略
nav_order: 9993
permalink: /reports/career-strategy-w07/
report_title: "求職策略建議 — 2026年第07週"
mode: career_strategy
period: "2026-W07"
generated_at: "2026-02-07T16:00:00Z"
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
dependent_modes:
  - climate_index
  - skills_drift
  - industry_segments
  - salary_bands
data_coverage:
  layers_available: 9
  layers_total: 14
  modes_available: 4
  modes_total: 4
risk_level: HIGH
---

# 求職策略建議 — 2026年第07週

> **重要聲明**：本報告由 AI 系統基於公開數據自動產出，所有內容僅為「基於數據觀測的參考方向」，不構成專業職涯諮詢。重大職涯決策請諮詢專業職涯顧問。詳見報告末「免責聲明」。

## 本週市場概覽

> 根據 climate_index 報告，本週市場溫度判定為「持平」。AI 基礎模型融資創紀錄（Ricursive Intelligence 成立兩個月即獲 3 億美元 Series A，估值 40 億美元），傳統科技業持續重組（Pinterest 裁員 15%、Meta Reality Labs 裁員 10%），市場呈現結構性分化。美國失業率維持 4.4%，非農就業穩定。台灣就業通平台觀測到 1,000 筆有效職缺，以零售服務業（481筆）佔比最高。LinkedIn 報告指出 AI 正在改變招聘遊戲規則，招聘人員需要像顧問一樣思考；同時強調「技能優先」（Skills First）招聘策略的重要性。市場正處於「AI 熱、整體冷」的結構性轉型期。

## 一、AI 取代向量風險評估

### 風險總覽

| 取代向量 | 當前風險等級 | 趨勢方向 | 影響人數估計 | 關鍵觀察 |
|----------|------------|----------|-------------|----------|
| 認知例行（cognitive_routine） | 高 | 升高 | — | Pinterest、Vimeo 裁員涉及內容審核與客服團隊；Zocks AI 財務顧問助理融資顯示例行認知工作自動化加速 |
| 認知非例行（cognitive_nonroutine） | 中 | 持平 | — | Ricursive Intelligence 融資顯示 AI 研究人才需求強勁，AI 作為輔助工具而非取代 |
| 體力例行（physical_routine） | 中 | 升溫 | — | Zipline 無人機配送量翻倍（100 萬→200 萬次），物流自動化加速 |
| 體力非例行（physical_nonroutine） | 低 | 降溫 | — | tw_govjobs 顯示清潔、餐飲等人力需求穩定，薪資中位數具競爭力（物流 41,100 TWD） |
| 高度人際（interpersonal） | 低 | 持平 | — | 服務業職缺穩定（tw_govjobs 零售服務佔 48%），LinkedIn 強調人際互動技能價值 |

> **風險等級說明**：風險等級基於該向量下角色的職缺需求變化、技能替代信號、全球趨勢綜合判定。此為基於有限數據的觀測結果，不代表確定性預測。

### 各向量詳細分析

#### 認知例行（cognitive_routine）

**觀測到的信號**：
- Pinterest 裁員 15%，明確表示將資源重新分配至 AI（來源：workforce_news）
- Indeed/Glassdoor 裁員 1,300 人，轉向 AI 驅動的求職媒合（來源：workforce_news）
- Zocks 獲 4,500 萬美元 Series B，開發 AI 財務顧問助理（來源：funding_signals）
- 財務會計類職缺薪資中位數最低（33,400 TWD），薪資分布集中（來源：salary_bands）

**受影響的角色**：
| 角色 | 職缺變化 | 技能需求變化 | 觀測到的替代信號 |
|------|----------|-------------|-----------------|
| 資料輸入員 | 無明確數據 | Excel/CRM 需求下降 | AI 自動化資料處理工具普及 |
| 客服專員 | 裁員信號 | 需轉向 AI 工具操作 | Pinterest、Indeed 等平台裁減客服團隊 |
| 會計助理 | 穩定 | 需熟悉自動化會計軟體 | 財務報表自動化程度提高，Zocks 等 AI 助手興起 |

**參考方向**（非建議）：
- 基於觀測數據，該向量下的工作者可關注以下技能補充方向：數據分析工具（如 Python/SQL）、AI 工具操作能力、專案管理技能
- 全球趨勢參考：LinkedIn 報告強調「技能優先」招聘策略，建議從認知例行工作轉向具備更高技能門檻的角色

#### 認知非例行（cognitive_nonroutine）

**觀測到的信號**：
- 軟體與 SaaS 產業觀測職缺數量最高（2,847 筆），持續擴張（來源：industry_segments）
- Python（1,913 次）、TypeScript（1,503 次）、Go（1,482 次）為高頻需求技能（來源：skills_drift）
- AI/ML 技術標籤出現超過 5,400 次，成為科技業標配（來源：skills_drift）
- Ricursive Intelligence 成立兩個月即獲 3 億美元 Series A（來源：funding_signals）
- LinkedIn 報告討論「建立以人為本的 AI 未來」，強調 AI 與人類協作（來源：global_linkedin_workforce）

**受影響的角色**：
| 角色 | 職缺變化 | 技能需求變化 | 觀測到的替代信號 |
|------|----------|-------------|-----------------|
| 後端工程師 | +39%（HN Hiring 佔比最高） | Python/Go/Rust 需求增加 | GitHub Copilot 等 AI 輔助工具改變基礎開發工作 |
| 資料科學家 | 穩定 | LLM/ML 專業化需求增加 | AI 使用者與 AI 開發者分化 |
| 資安專家 | 需求上升 | 網路安全技能短缺持續 | LinkedIn 報告關注「彌合資安人才缺口」議題 |

**參考方向**（非建議）：
- 基於觀測數據，該向量下的工作者可關注以下技能補充方向：AI/ML 應用能力、雲端架構（AWS/Kubernetes）、系統設計能力
- 全球趨勢參考：LinkedIn 報告指出資安人才缺口持續擴大，資安技能為高價值投資方向

#### 體力例行（physical_routine）

**觀測到的信號**：
- Zipline 獲 6 億美元融資擴張無人機配送，配送量一年內從 100 萬增至 200 萬次（來源：funding_signals）
- Northwood Space 獲 1 億美元 Series B + 5,000 萬美元政府合約，太空基礎設施擴張（來源：funding_signals）
- 製造業觀測職缺數僅 14 筆，樣本不足（來源：industry_segments）
- Rivian 本年度第三次裁員，削減 600 人（來源：workforce_news）

**受影響的角色**：
| 角色 | 職缺變化 | 技能需求變化 | 觀測到的替代信號 |
|------|----------|-------------|-----------------|
| 生產線作業員 | 樣本不足 | 需熟悉自動化設備操作 | 製造業自動化持續推進 |
| 倉儲物流員 | 穩定 | 無人機/機器人協作技能 | Zipline 等無人機公司創造新型態崗位 |

**參考方向**（非建議）：
- 基於觀測數據，該向量下的工作者可關注以下技能補充方向：自動化設備維護、機器人協作操作、物流系統管理
- 全球趨勢參考：無人機配送擴張主要創造新崗位（如無人機操作員、維護技師），而非直接取代現有人力

#### 體力非例行（physical_nonroutine）

**觀測到的信號**：
- tw_govjobs 顯示技術工藝職缺 65 筆、營建職缺 18 筆，需求穩定（來源：tw_govjobs）
- 物流運輸類薪資中位數達 41,100 TWD，高於科技類 38,500 TWD（來源：salary_bands）
- 營建工程類薪資中位數達 42,678 TWD，位居第一（來源：salary_bands）

**受影響的角色**：
| 角色 | 職缺變化 | 技能需求變化 | 觀測到的替代信號 |
|------|----------|-------------|-----------------|
| 水電技師 | 穩定 | 需熟悉智慧建築系統 | 無明顯取代信號 |
| 廚師 | 穩定 | 無明顯變化 | 無明顯取代信號 |
| 司機/物流 | 穩定 | 電動車/自駕車基礎知識 | 長期可能受自駕技術影響 |

**參考方向**（非建議）：
- 基於觀測數據，該向量下的工作者目前相對穩定，可持續精進專業技能
- 全球趨勢參考：體力非例行工作因需要現場作業與靈活應對，短期內 AI 取代難度較高

#### 高度人際（interpersonal）

**觀測到的信號**：
- 零售服務職缺 481 筆，佔 tw_govjobs 近半數（來源：tw_govjobs）
- 醫療照護職缺 76 筆，需求穩定（來源：industry_segments）
- 教育產業 AI 衝擊評估為「高度保護」（來源：industry_segments）
- LinkedIn 報告強調招聘人員需轉型為顧問角色（來源：global_linkedin_workforce）

**受影響的角色**：
| 角色 | 職缺變化 | 技能需求變化 | 觀測到的替代信號 |
|------|----------|-------------|-----------------|
| 門市服務員 | 穩定 | 數位支付/POS 系統操作 | 自助結帳普及但人際服務仍需 |
| 照顧服務員 | 穩定/成長 | 無明顯變化 | 高齡化驅動持續需求 |
| 業務人員 | 穩定 | CRM/數據分析能力 | AI 作為輔助工具而非取代 |
| 招聘人員 | 角色轉型 | 需具備顧問式思維 | AI 改變招聘流程，但人際判斷仍需 |

**參考方向**（非建議）：
- 基於觀測數據，該向量下的工作者可強化人際互動的核心價值，同時學習數位工具輔助
- 全球趨勢參考：LinkedIn 報告指出 AI 正在改變招聘遊戲規則，但人際判斷與顧問式思維更為重要

## 二、高需求技能與學習資源參考

### 技能需求上升 Top 10

| 排名 | 技能 | 需求變化 | 相關角色 | 相關產業 | 學習資源參考 |
|------|------|----------|----------|----------|-------------|
| 1 | AI/Machine Learning | 高頻出現（5,400+ 次） | ML Engineer, Data Scientist | 軟體與 SaaS, 金融服務 | 見下方 |
| 2 | Python | 高頻出現（1,913 次） | Backend Engineer, Data Analyst | 軟體與 SaaS, 金融服務 | 見下方 |
| 3 | TypeScript | 高頻出現（1,503 次） | Frontend Engineer, Full Stack | 軟體與 SaaS | 見下方 |
| 4 | Go (Golang) | 高頻出現（1,482 次） | Backend Engineer, DevOps | 軟體與 SaaS | 見下方 |
| 5 | AWS | 高頻出現（1,116 次） | DevOps, Cloud Engineer | 軟體與 SaaS | 見下方 |
| 6 | Rust | 中高頻出現（807 次） | Systems Engineer, Backend | 軟體與 SaaS | 見下方 |
| 7 | Kubernetes | 中高頻出現（492 次） | DevOps, SRE | 軟體與 SaaS | 見下方 |
| 8 | React | 高頻出現（1,862 次） | Frontend Engineer | 軟體與 SaaS | 見下方 |
| 9 | LLM/Prompt Engineering | 新興技能（234 次） | AI Engineer, ML Engineer | 軟體與 SaaS | 見下方 |
| 10 | Cybersecurity | 持續短缺 | Security Engineer, SOC Analyst | 軟體與 SaaS, 金融服務 | 見下方 |

### 學習資源參考

> **聲明**：以下僅列出公開可驗證的免費或主流學習平台，不代表推薦或背書。學習效果因人而異。

| 技能 | 免費資源 | 主流平台 | 官方認證 |
|------|----------|----------|----------|
| AI/Machine Learning | fast.ai（免費課程）、Google ML Crash Course | Coursera, edX | Google TensorFlow Certificate, AWS ML Specialty |
| Python | Python 官方文件、Real Python（部分免費） | Coursera, Codecademy | Python Institute PCEP/PCAP |
| TypeScript | TypeScript 官方文件、TypeScript Handbook | Udemy, Frontend Masters | 無官方認證 |
| Go (Golang) | Go 官方教程（tour.golang.org） | Udemy, Pluralsight | 無官方認證 |
| AWS | AWS Free Tier、AWS Skill Builder（免費） | A Cloud Guru, Linux Academy | AWS Certified Solutions Architect 等 |
| Rust | Rust 官方 Book（doc.rust-lang.org/book） | Udemy | 無官方認證 |
| Kubernetes | Kubernetes 官方文件、Kubernetes the Hard Way | Linux Foundation, A Cloud Guru | CKA, CKAD, CKS |
| React | React 官方文件、freeCodeCamp | Udemy, Frontend Masters | 無官方認證 |
| LLM/Prompt Engineering | OpenAI Prompt Engineering Guide（免費） | DeepLearning.AI | 無官方認證 |
| Cybersecurity | OWASP、NIST Cybersecurity Framework（免費） | Coursera, Cybrary | CompTIA Security+, CISSP, CEH |

> **注意**：
> - 僅列出免費公開資源（如官方文件、開源教程）和主流平台名稱
> - 不列出特定付費課程或推薦碼
> - 不評價各平台的教學品質
> - 學習路徑因個人基礎不同而異，此處僅為方向參考

## 三、熱門轉職路徑觀察

> **重要**：以下轉職路徑為基於數據觀測的「可能方向」，不代表建議或保證。每條路徑的可行性高度取決於個人背景、經驗和學習能力。

### 基於數據觀測的轉職方向

| 起始角色 | 目標方向 | 技能重疊度 | 需補充技能 | 薪資變化參考 | 觀測依據 |
|----------|----------|-----------|-----------|-------------|----------|
| 資料輸入員 → | 資料分析師 | 中 | Python, SQL, 資料視覺化 | +30%~50%（推估） | 認知例行→認知非例行轉型 |
| 客服專員 → | 客戶成功經理 | 高 | CRM 工具, 數據分析, 專案管理 | +20%~40%（推估） | 人際技能延續，增加策略分析 |
| 會計助理 → | 財務分析師 | 中 | Excel 進階, 財務建模, Python | +25%~45%（推估） | 認知例行→認知非例行轉型 |
| 後端工程師 → | ML Engineer | 中 | Python ML 套件, 數學統計, LLM | +15%~30%（推估） | 程式技能延續，增加 ML 專業 |
| IT 專員 → | 資安工程師 | 中 | 網路安全、滲透測試、合規 | +20%~40%（推估） | LinkedIn 報告指出資安人才缺口持續 |

### 轉職路徑詳解

#### 資料輸入員 → 資料分析師

**觀測依據**：
- 認知例行職缺（如資料輸入）面臨 AI 自動化壓力，薪資中位數偏低（財務會計類 33,400 TWD）（來源：salary_bands）
- 資料分析相關技能（Python, SQL）為 skills_drift 報告中的高頻需求技能（來源：skills_drift）

**技能重疊**：
- 已具備：資料處理概念、Excel 基礎、細心與準確度
- 需補充：Python/SQL 程式能力、資料視覺化（Tableau/Power BI）、統計分析基礎

**薪資帶參考**（來源：salary_bands）：
- 起始角色 P50：約 33,000-35,000 TWD/月（推估，認知例行類）
- 目標方向 P50：約 38,500-50,000 TWD/月（科技類 P50-P75）

**不確定性提醒**：
- 轉職所需時間因個人基礎而異，可能需要 6-18 個月的學習與實作累積
- 資料分析職缺競爭激烈，單純技能學習不保證成功轉職
- 實際薪資受產業、公司規模、個人談判能力等多因素影響

#### 客服專員 → 客戶成功經理

**觀測依據**：
- 傳統客服職位面臨 AI 自動化取代壓力（Pinterest 等公司裁減客服團隊）（來源：workforce_news）
- SaaS 產業持續擴張，客戶成功（Customer Success）為 SaaS 商業模式核心職能（來源：industry_segments）

**技能重疊**：
- 已具備：客戶溝通能力、問題解決、產品知識
- 需補充：CRM 工具進階操作、數據分析能力、專案管理、英語能力

**薪資帶參考**（來源：salary_bands）：
- 起始角色 P50：約 33,000-35,000 TWD/月（推估）
- 目標方向 P50：約 40,000-55,000 TWD/月（推估，SaaS 產業）

**不確定性提醒**：
- 客戶成功經理多要求 SaaS/科技業經驗，跨產業轉職難度較高
- 部分職位要求英語流利，作為與全球客戶溝通的必備能力
- SaaS 產業雖擴張，但經濟下行時客戶成功團隊也可能精簡

#### IT 專員 → 資安工程師

**觀測依據**：
- LinkedIn 報告指出資安人才缺口持續擴大（來源：global_linkedin_workforce）
- 資安技能在 skills_drift 報告中出現頻率雖低，但為全球性短缺技能（來源：skills_drift）
- 金融服務、軟體與 SaaS 產業對資安人才需求強勁（來源：industry_segments）

**技能重疊**：
- 已具備：IT 基礎設施知識、網路概念、系統管理
- 需補充：滲透測試、威脅分析、合規框架（ISO 27001、NIST）、雲端安全

**薪資帶參考**：
- 起始角色 P50：約 35,000-40,000 TWD/月（推估）
- 目標方向 P50：約 45,000-65,000 TWD/月（推估，視認證與經驗）

**不確定性提醒**：
- 資安認證（如 CISSP、CEH）通常需要一定經驗年資才能報考
- 資安工作壓力較大，需要持續關注最新威脅情報
- 大型企業與金融業的資安職缺較多，中小企業可能以外包為主

#### 後端工程師 → ML Engineer

**觀測依據**：
- ML/AI 技能需求高頻出現（5,400+ 次），為全球科技業最熱門方向（來源：skills_drift）
- HN Hiring 顯示 AI 相關職位薪資天花板明顯高於傳統軟體開發（來源：industry_segments）
- Ricursive Intelligence 等 AI 公司大規模融資，將創造 ML Engineer 職缺（來源：funding_signals）

**技能重疊**：
- 已具備：Python/Go 程式能力、系統設計、資料處理
- 需補充：機器學習演算法、深度學習框架（PyTorch/TensorFlow）、LLM 應用開發

**薪資帶參考**（來源：salary_bands、global_hn_hiring）：
- 起始角色 P50：$165K USD/年（全球科技業）
- 目標方向 P50：$180K-$250K USD/年（推估，AI 職位薪資天花板更高）

**不確定性提醒**：
- ML Engineer 職位競爭極為激烈，頂尖人才來自全球
- 需要扎實的數學/統計基礎，非單純學習框架操作即可
- AI 領域技術變化快速，需持續學習投入

## 四、各產業進入門檻觀察

| 產業 | 入門角色 | 基本技能門檻 | 平均入門薪資 | 職缺供需比 | 進入難度參考 |
|------|----------|-------------|-------------|-----------|-------------|
| 軟體與 SaaS | Junior Developer | Python/JS, Git, 基礎演算法 | 38,500 TWD（台灣）/ $80K USD（全球） | 需求高/競爭高 | 中 |
| 零售電商 | 門市服務員 | 基本溝通、POS 操作 | 33,500-37,000 TWD | 需求高/競爭低 | 低 |
| 金融服務 | 會計助理/專員 | 會計基礎、Excel | 33,400 TWD | 需求中/競爭中 | 低-中 |
| 醫療生技 | 照顧服務員 | 照服員證照、基本護理 | 28,000-33,500 TWD | 需求高/競爭低 | 低 |
| 物流運輸 | 司機/配送員 | 駕照、體力 | 37,500-41,100 TWD | 需求高/競爭中 | 低 |
| 營建不動產 | 工地助理/測量助理 | 基礎土木知識、體力 | 35,000-42,678 TWD | 需求中/競爭低 | 低 |
| 媒體娛樂 | 行銷專員/內容創作 | 文案能力、社群經營 | 35,000-38,500 TWD | 需求中/競爭高 | 中 |
| 資安 | SOC Analyst | 網路基礎、資安認證 | 40,000-50,000 TWD | 需求高/競爭中 | 中-高 |

> **進入難度參考**基於：入門職缺數量、要求技能數量、要求經驗年資、應徵競爭程度。此為觀測指標，非絕對判斷。

## 五、本週關鍵觀察

### 市場動態觀察

根據 climate_index 報告，本週延續「AI 熱、整體冷」的分化態勢。Ricursive Intelligence 成立兩個月即成為獨角獸（3 億美元 Series A，估值 40 億美元），顯示資本對 AI 基礎模型的極度樂觀。同時，Pinterest、Vimeo、Meta Reality Labs 的裁員均明確提及將資源重新分配至 AI。

2025 Q4 新獨角獸數量達 2022 年 Q2 以來最高（12 月有 23 家公司加入），金融科技領域領先成長。IPO 窗口的不確定性（年初開放但可能正在關閉）增加了高成長公司員工股權變現的風險。

### 技能趨勢觀察

根據 skills_drift 報告（W06 基線版），當前快照顯示：

1. **AI 技術滲透率極高**：「AI」一詞在 HN Hiring 職缺中出現 4,388 次，AI 能力已成為科技業標配
2. **語言與框架演變**：Go（1,482 次）和 Rust（807 次）在雲端原生架構中重要性提升，Python 定位轉向 AI/ML 專用工具
3. **資安人才缺口**：LinkedIn 報告關注「彌合資安人才缺口」，資安技能為高價值投資方向
4. **技能優先招聘**：LinkedIn 報告強調「技能優先」（Skills First）策略，學歷門檻可能逐漸降低

### 產業結構觀察

根據 industry_segments 報告，14 個產業呈現明顯分化：

- **擴張象限**：軟體與 SaaS（2,847 筆職缺）、金融服務（Fintech 整併活絡）、太空科技（Northwood Space 融資）
- **穩定象限**：零售電商（481 筆）、醫療生技（76 筆）、政府與非營利（87 筆）
- **收縮象限**：媒體娛樂（多家公司裁員轉向 AI）、製造業（自動化持續推進）

AI 作為「基礎設施層」的定位愈加明確——如同網際網路曾經是。這意味著「產業 + AI」混合職位將快速成長。

### 值得持續關注的信號

1. **tw_104_jobs 恢復狀況**：目前台灣科技業職缺資料主要依賴 tw_govjobs，若 104 人力銀行 API 恢復，可提供更完整的台灣市場樣貌
2. **AI/ML 技能細分**：追蹤 LLM、GPT、Prompt Engineering 等細分標籤的需求變化
3. **遠端工作薪資套利**：HN Hiring 全球薪資中位數（$165K USD/年）約為台灣的 10 倍，台灣開發者遠端工作機會值得關注
4. **資安人才培育**：LinkedIn 報告持續關注資安人才缺口，此領域可能提供較穩定的職涯發展路徑
5. **技能優先招聘趨勢**：追蹤「技能優先」策略對學歷門檻的實際影響

## 免責聲明

本報告由 AI 系統基於公開數據自動產出，僅供參考。

1. **非專業職涯諮詢**：本報告不構成專業的職涯規劃建議。重大職涯決策請諮詢專業職涯顧問。
2. **數據局限性**：分析基於有限的觀測數據源（主要為台灣就業通及全球遠端職缺平台），不代表完整的就業市場狀況。本週 tw_104_jobs、tw_company_reviews 等資料源未更新，台灣科技業樣本可能不足。
3. **預測不確定性**：所有趨勢分析和預測均基於歷史數據推斷，實際市場變化可能與預測不同。
4. **個人差異**：職涯發展受個人背景、技能、經驗、地理位置等多重因素影響，本報告無法涵蓋個人化情境。
5. **不構成投資建議**：報告中提及的產業趨勢和企業動態不構成任何投資建議。
6. **學習資源中立**：報告中列出的學習資源僅為公開可查資訊的彙整，不代表推薦或品質保證。
7. **AI 生成風險**：本報告由 AI 模型生成，儘管基於數據，但綜合判斷部分可能包含不精確或過度簡化的分析。

---

**資料來源說明**

| Layer | 狀態 | 筆數 | 備註 |
|-------|------|------|------|
| tw_govjobs | 有效 | 1,000 | 台灣就業通 |
| global_hn_hiring | 有效 | 2,336 | HN Hiring |
| global_arbeitnow | 有效 | 1,181 | 歐洲職缺 |
| global_remoteok | 有效 | 94 | 遠端職缺 |
| global_weworkremotely | 有效 | 99 | 遠端職缺 |
| global_linkedin_workforce | 部分有效 | 12 | LinkedIn 人才趨勢報告（WebFetch 失敗降級） |
| workforce_news | 有效 | 20 | 裁員/擴編事件 |
| funding_signals | 有效 | 37 | 融資動態 |
| global_bls | 有效 | 143 | 美國經濟指標 |
| tw_104_jobs | 數據未更新 | 0 | API 風險中等 |

**Qdrant 向量搜尋結果**（本報告參考）：
- Overcome Talent Architecture Roadblocks
- Closing The Cybersecurity Talent Gap
- New York Life Talent Strategy
- AI Powered Role Play Midyear
- What Skills First Really Means

**本報告使用 Qdrant 向量搜尋取得相關資料**，搜尋結果涵蓋人才策略、資安人才缺口、技能優先招聘等主題，並與 docs/Extractor 目錄下的結構化資料交叉驗證。

---

最後更新：2026-02-07
