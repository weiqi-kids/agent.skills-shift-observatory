---
layout: default
title: 研究者專區
nav_exclude: true
permalink: /for-researchers/
description: "研究者與政策制定者：資料來源、方法論、引用格式與 AI 取代向量框架說明"
---

# 研究者 / 政策制定者專區

歡迎！如果你是學術研究者、政策分析師或對就業市場進行系統性研究，這個頁面提供你需要的技術細節。

---

## 資料來源總覽

本系統整合 15+ 個公開資料來源，分為三個層級：

### 微觀層（台灣市場）

| 資料源 | 類型 | 更新頻率 | API/格式 |
|:-------|:-----|:---------|:---------|
| 台灣就業通 | 政府 Open API | 即時 | XML |

### 宏觀層（全球市場）

| 資料源 | 類型 | 更新頻率 | 涵蓋範圍 |
|:-------|:-----|:---------|:---------|
| HN Hiring | 職缺 | 月度 | 北美科技業 |
| Arbeitnow | 職缺 | 即時 | 歐洲 |
| RemoteOK | 職缺 | 即時 | 遠端工作 |
| WeWorkRemotely | 職缺 | 即時 | 遠端工作 |
| BLS | 統計 | 月度 | 美國 |
| Eurostat | 統計 | 季度 | 歐盟 |
| ABS | 統計 | 季度 | 澳洲 |
| KOSIS | 統計 | 月度 | 韓國 |
| StatCan | 統計 | 月度 | 加拿大 |
| Hays | 報告 | 年度 | 全球薪資 |
| Stack Overflow | 調查 | 年度 | 開發者 |
| LinkedIn Workforce | 報告 | 季度 | 全球 |
| Indeed | 報告 | 季度 | 全球招聘 |
| ManpowerGroup | 報告 | 季度 | 就業展望 |

### 事件層

| 資料源 | 類型 | 更新頻率 | 內容 |
|:-------|:-----|:---------|:-----|
| TechCrunch | 新聞 | 即時 | 融資、裁員、擴編 |

詳細的資料收集流程，請見 [關於本站 - 方法論](/about/#方法論)。

---

## AI 取代向量分析框架

本系統採用的 5 種 AI 取代向量分類，參考自勞動經濟學中常見的工作任務分類框架（如 Autor, Levy, Murnane 2003）：

| 向量 | 定義 | 自動化特性 | 觀測角色數 |
|:-----|:-----|:-----------|:-----------|
| **cognitive_routine** | 規則明確的腦力工作 | 高度可程式化 | 10 |
| **cognitive_nonroutine** | 需判斷力的專業工作 | AI 輔助為主 | 16 |
| **physical_routine** | 重複性體力勞動 | 機器人取代 | 6 |
| **physical_nonroutine** | 需靈活應變的體力工作 | 技術尚不成熟 | 14 |
| **interpersonal** | 核心在人際連結 | 難以自動化 | 4 |

### 53 個觀測角色

完整角色清單請見各 Mode 報告的 CLAUDE.md 定義，或參考 [薪資帶報告](/reports/salary-bands-w08/) 的角色列表。

---

## 產業分類

本系統將職缺分類為 14 個產業：

| 代碼 | 中文名稱 | 涵蓋範圍 |
|:-----|:---------|:---------|
| software_saas | 軟體與 SaaS | 軟體開發、雲端服務 |
| semiconductor | 半導體 | IC 設計、晶圓代工、封測 |
| electronics_hardware | 電子硬體 | 消費電子、網通設備 |
| financial_services | 金融服務 | 銀行、保險、金融科技 |
| healthcare_biotech | 醫療生技 | 醫院、藥廠、醫材 |
| manufacturing | 製造業 | 傳統製造、精密機械 |
| retail_ecommerce | 零售電商 | 實體零售、電商、物流 |
| media_entertainment | 媒體娛樂 | 數位媒體、遊戲、廣告 |
| education | 教育 | 學校、補教、教育科技 |
| energy_green | 能源與綠能 | 傳統能源、再生能源 |
| construction_realestate | 營建不動產 | 營造、建築、不動產 |
| telecom | 電信 | 電信營運、5G |
| government_ngo | 政府與非營利 | 公務機關、NGO |
| professional_services | 專業服務 | 顧問、法律、會計 |

---

## 報告類型與更新頻率

| 報告 | 更新頻率 | 主要資料來源 |
|:-----|:---------|:-------------|
| [景氣溫度計](/climate-index/) | 每週 | 全部 Layer |
| [技能漂移](/skills-drift/) | 每週 | 職缺 Layer |
| [產業分層](/industry-segments/) | 每週 | 職缺 + 統計 Layer |
| [薪資帶](/salary-bands/) | 每週 | 職缺 Layer |
| [求職策略](/career-strategy/) | 每週 | 全部 Layer + 前四報告 |

---

## 引用格式

### APA 格式

```
Skills Shift Observatory. (2026). 就業景氣溫度計 — 2026年第08週.
    Retrieved from https://skills.weiqi.kids/reports/climate-index-w08/
```

### BibTeX

```bibtex
@misc{skillsshift2026w08,
  title = {就業景氣溫度計 — 2026年第08週},
  author = {{Skills Shift Observatory}},
  year = {2026},
  url = {https://skills.weiqi.kids/reports/climate-index-w08/},
  note = {AI-generated report based on public employment data}
}
```

---

## 資料限制與偏差聲明

使用本站資料進行研究時，請注意以下限制：

### 樣本偏差

| 偏差類型 | 說明 |
|:---------|:-----|
| 產業偏差 | 科技業、大型企業佔比較高 |
| 地區偏差 | 台灣資料以北部為主 |
| 語言偏差 | 全球資料以英語系國家為主 |
| 「面議」排除 | 高薪職缺傾向面議，已排除在薪資統計外 |

### 時間延遲

| 資料類型 | 典型延遲 |
|:---------|:---------|
| 職缺資料 | 即時至 1 週 |
| 政府統計 | 1-2 個月 |
| 年度報告 | 3-12 個月 |

### AI 生成風險

本站所有報告由 AI 系統（Claude）自動產出，綜合判斷部分可能存在偏差或不精確。建議將本站資料作為「輔助參考」而非「唯一來源」。

---

## 開源與貢獻

本專案開源於 GitHub：

[查看原始碼](https://github.com/weiqi-kids/agent.skills-shift-observatory){: .btn }

歡迎透過 Issue 提出資料來源建議、方法論改進或錯誤回報。

---

## 相關資源

- [關於本站](/about/) - 完整方法論說明
- [名詞解釋](/glossary/) - 術語定義
- [系統架構](https://github.com/weiqi-kids/agent.skills-shift-observatory/blob/main/CLAUDE.md) - 技術文件

---

[← 回首頁](/)
