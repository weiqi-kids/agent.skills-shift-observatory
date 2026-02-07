---
layout: home
title: 首頁
nav_order: 1
description: "技能需求變化觀測站 — 追蹤全球就業市場變化與 AI 對各產業職缺的衝擊"
permalink: /
---

# 技能需求變化觀測站
{: .fs-9 }

追蹤全球就業市場變化與 AI 對各產業職缺的衝擊
{: .fs-6 .fw-300 }

[景氣溫度計]({{ site.baseurl }}/reports/climate-index-w07/){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[技能漂移]({{ site.baseurl }}/reports/skills-drift-w07/){: .btn .fs-5 .mb-4 .mb-md-0 .mr-2 }
[產業分層]({{ site.baseurl }}/reports/industry-segments-w07/){: .btn .fs-5 .mb-4 .mb-md-0 .mr-2 }
[薪資帶]({{ site.baseurl }}/reports/salary-bands-w07/){: .btn .fs-5 .mb-4 .mb-md-0 .mr-2 }
[求職策略]({{ site.baseurl }}/reports/career-strategy-w07/){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 系統概覽

本系統透過 Claude CLI 驅動，自動擷取、萃取、分析全球就業市場數據，追蹤 **53 個職務角色**在 **14 個產業**中的需求變化，並以 **5 種 AI 取代向量**分析自動化衝擊。

### 觀測架構

| 層級 | 資料源 | 說明 |
|:-----|:-------|:-----|
| **微觀層（台灣）** | 台灣就業通 | 台灣公家機關職缺 |
| **宏觀層（全球職缺）** | HN Hiring、Arbeitnow、RemoteOK、WeWorkRemotely | 北美科技業、歐洲職缺、遠端工作 |
| **宏觀層（全球報告）** | BLS、Hays、Stack Overflow、LinkedIn、Indeed、ManpowerGroup | 勞動統計、薪資趨勢、技能調查 |
| **事件層** | TechCrunch | 融資動態、裁員/擴編新聞 |

### AI 取代向量

| 向量 | 定義 | 觀測角色數 |
|:-----|:-----|:-----------|
| 認知例行 | 規則明確的腦力工作 | 10 |
| 認知非例行 | 需判斷力的專業知識工作 | 16 |
| 體力例行 | 重複性體力勞動 | 6 |
| 體力非例行 | 需靈活應變的體力工作 | 14 |
| 高度人際 | 核心在人際連結 | 4 |

---

## 最新報告

| 報告 | 週次 | 說明 |
|:-----|:-----|:-----|
| [景氣溫度計]({{ site.baseurl }}/reports/climate-index-w07/) | W07 | 就業市場綜合溫度判讀 |
| [技能漂移]({{ site.baseurl }}/reports/skills-drift-w07/) | W07 | 技能標籤上升/下降榜 |
| [產業分層]({{ site.baseurl }}/reports/industry-segments-w07/) | W07 | 各產業用人方向與趨勢 |
| [薪資帶]({{ site.baseurl }}/reports/salary-bands-w07/) | W07 | 跨產業跨地區薪資比較 |
| [求職策略]({{ site.baseurl }}/reports/career-strategy-w07/) | W07 | 技能缺口→學習路徑→職缺 |

---

## 系統健康度

> 最後更新：2026-02-07

### 資料總覽

| 類型 | 筆數 |
|:-----|-----:|
| 職缺資料總計 | 4,710 |
| 宏觀報告資料 | 212 |
| 事件信號資料 | 57 |
| **總計** | **4,979** |

### Layers 狀態

| 狀態 | 數量 | 說明 |
|:-----|-----:|:-----|
| ✅ 正常 | 14 | 資料擷取正常運作 |
| ⚠️ 待處理 | 3 | 需手動下載或待擷取 |
| ❌ 已停用 | 1 | API 風險或需驗證 |

### Modes 狀態

| Mode | 狀態 | 最新報告 |
|:-----|:-----|:---------|
| climate_index | ✅ | 2026-W07 |
| skills_drift | ✅ | 2026-W07 |
| industry_segments | ✅ | 2026-W07 |
| salary_bands | ✅ | 2026-W07 |
| career_strategy | ✅ | 2026-W07 |

---

## 關於本站

本站由 [Claude Code](https://claude.ai) 驅動的 AI 系統自動產出報告，使用 [Just the Docs](https://just-the-docs.github.io/just-the-docs/) 主題呈現。

{: .warning }
> 本站所有報告均為 AI 系統基於公開數據自動產出，僅供參考。重大職涯決策請諮詢專業人士。
