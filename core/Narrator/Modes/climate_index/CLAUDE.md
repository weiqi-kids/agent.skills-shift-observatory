# Mode：climate_index / 就業景氣溫度計

## Mode 定義表

| 項目 | 說明 |
|------|------|
| **Mode name** | climate_index / 就業景氣溫度計 |
| **Purpose and audience** | 綜合多來源數據產出就業市場整體溫度判讀，供企業 HR 主管、求職者、政策研究者快速掌握市場概況 |
| **Source layers** | 全部 14 個 Layer：tw_104_jobs, tw_govjobs, tw_company_reviews, global_linkedin_workforce, global_indeed_hiring, global_oecd_employment, global_ilo_stats, global_wef_jobs, global_stackoverflow, global_manpower_outlook, global_bls, global_hays_salary, workforce_news, funding_signals |
| **Automation ratio** | 60% — 量化指標可自動計算，但「溫度」判讀需 AI 綜合分析 |
| **Content risk** | 過度簡化複雜的就業市場為單一指標，可能誤導決策 |
| **Reviewer persona** | 使用者誤導風險審核員 + 邏輯一致性審核員 |

---

## 資料來源定義

讀取所有 Layer 最近一個觀測週期的萃取結果（`docs/Extractor/{layer_name}/` 下的 `.md` 檔）：

### Micro（台灣）層
| Layer | 讀取重點 |
|-------|----------|
| tw_104_jobs | 職缺數量變化、薪資區間變化、應徵人數變化、各產業與角色的供需動態 |
| tw_govjobs | 政府平台職缺趨勢、公部門用人方向 |
| tw_company_reviews | 員工滿意度趨勢、離職傾向信號 |

### Macro（全球）層
| Layer | 讀取重點 |
|-------|----------|
| global_bls | 美國非農就業數據、失業率 |
| global_oecd_employment | OECD 各國失業率趨勢 |
| global_ilo_stats | 國際勞工組織全球就業統計 |
| global_manpower_outlook | ManpowerGroup 淨就業展望指數 |
| global_linkedin_workforce | LinkedIn 全球勞動力趨勢 |
| global_indeed_hiring | Indeed 全球招聘趨勢 |
| global_wef_jobs | 世界經濟論壇就業市場報告 |
| global_stackoverflow | Stack Overflow 技術人才市場動態 |
| global_hays_salary | Hays 全球薪資趨勢 |

### Events（事件）層
| Layer | 讀取重點 |
|-------|----------|
| workforce_news | 裁員事件數量與規模、招聘潮事件、重大勞動力政策變化 |
| funding_signals | 融資金額趨勢、IPO 數量、產業資金流向 |

---

## 溫度等級定義

| 等級 | 符號 | 判定條件 |
|------|------|----------|
| 寒冷 | 🔴 | 多數指標顯著惡化：職缺數大幅下降（>10%）、失業率上升、裁員事件密集、融資萎縮 |
| 偏冷 | 🟠 | 部分指標轉弱：職缺數微降（3-10%）、部分產業收縮、招聘放緩 |
| 持平 | 🟡 | 指標無顯著方向性變化：職缺數穩定（±3%）、各指標互有漲跌 |
| 溫暖 | 🟢 | 多數指標正向：職缺數上升（3-10%）、多產業擴張、薪資微升 |
| 過熱 | 🔵 | 多數指標顯著過熱：職缺數大幅上升（>10%）、人才短缺加劇、薪資快速攀升 |

> **注意**：溫度判讀為綜合評估，不由單一指標決定。當不同來源指標方向矛盾時，應在「溫度判讀依據」中明確說明矛盾之處，並以台灣數據為主要依據、全球數據為輔助參考。

---

## 輸出框架

```markdown
---
title: "就業景氣溫度計 — {YYYY}年第{WW}週"
mode: climate_index
period: "{YYYY}-W{WW}"
generated_at: "{ISO 8601 timestamp}"
source_layers:
  - tw_104_jobs
  - tw_govjobs
  - tw_company_reviews
  - global_linkedin_workforce
  - global_indeed_hiring
  - global_oecd_employment
  - global_ilo_stats
  - global_wef_jobs
  - global_stackoverflow
  - global_manpower_outlook
  - global_bls
  - global_hays_salary
  - workforce_news
  - funding_signals
data_coverage:
  layers_available: {N}
  layers_total: 14
  observation_period: "{start_date} ~ {end_date}"
---

# 就業景氣溫度計 — {YYYY}年第{WW}週

## 本週溫度：{🔴 寒冷 | 🟠 偏冷 | 🟡 持平 | 🟢 溫暖 | 🔵 過熱}

> {一句話摘要：30字以內，精準描述本週市場狀態}

## 核心指標

### 台灣市場

| 指標 | 本週 | 前週 | 變化 | 來源 |
|------|------|------|------|------|
| 觀測職缺總數 | {N} | {N} | {+/-N, +/-X%} | tw_104_jobs |
| 平均薪資區間（中位） | {N}K | {N}K | {+/-N%} | tw_104_jobs |
| 新增職缺數 | {N} | {N} | {+/-N%} | tw_104_jobs |
| 政府平台職缺數 | {N} | {N} | {+/-N%} | tw_govjobs |
| 裁員事件數 | {N} | {N} | {+/-N} | workforce_news |
| 招聘潮事件數 | {N} | {N} | {+/-N} | workforce_news |
| 本週融資事件數 | {N} | {N} | {+/-N} | funding_signals |

### 全球市場

| 指標 | 最新值 | 前期值 | 趨勢 | 來源 |
|------|--------|--------|------|------|
| 美國非農就業（月增） | {N}K | {N}K | {↑/↓/→} | global_bls |
| 美國失業率 | {N}% | {N}% | {↑/↓/→} | global_bls |
| OECD 平均失業率 | {N}% | {N}% | {↑/↓/→} | global_oecd_employment |
| ManpowerGroup 淨展望 | {N}% | {N}% | {↑/↓/→} | global_manpower_outlook |
| Indeed 招聘趨勢指數 | {N} | {N} | {↑/↓/→} | global_indeed_hiring |
| LinkedIn 人才需求趨勢 | {描述} | — | {↑/↓/→} | global_linkedin_workforce |

> **數據覆蓋說明**：本週共有 {N}/14 個 Layer 提供有效數據。{列出缺失的 Layer 及原因}

## 溫度判讀依據

{3-5 段分析文字，解釋溫度判讀的邏輯依據。每段必須引用具體數據點，格式為（來源：{layer_name}）。}

{第一段：台灣市場核心態勢}

{第二段：全球市場背景}

{第三段：事件面信號（裁員/融資/政策）}

{第四段：綜合研判（如有矛盾信號，須在此段明確說明）}

{第五段（選填）：與前期溫度變化的銜接}

## 產業亮點與警訊

### 擴張信號
- 🟢 {產業名稱}：{具體證據，含數字與來源}
- 🟢 {產業名稱}：{具體證據}

### 收縮信號
- 🔴 {產業名稱}：{具體證據，含數字與來源}
- 🔴 {產業名稱}：{具體證據}

### 值得關注
- 🟡 {產業名稱}：{信號尚不明確的觀察}

## 本週重大事件

{列出本週 3-5 件對就業市場影響最大的事件，按影響程度排序}

1. **{事件標題}**（來源：{layer_name}）
   {事件摘要，2-3 句}

2. **{事件標題}**（來源：{layer_name}）
   {事件摘要}

3. **{事件標題}**（來源：{layer_name}）
   {事件摘要}

## AI 取代向量觀察

| 取代向量 | 本週信號 | 代表性事件/數據 |
|----------|----------|-----------------|
| 認知例行（cognitive_routine） | {升溫/降溫/持平} | {簡述} |
| 認知非例行（cognitive_nonroutine） | {升溫/降溫/持平} | {簡述} |
| 體力例行（physical_routine） | {升溫/降溫/持平} | {簡述} |
| 體力非例行（physical_nonroutine） | {升溫/降溫/持平} | {簡述} |
| 高度人際（interpersonal） | {升溫/降溫/持平} | {簡述} |

## 免責聲明

本報告為自動化分析產出，僅供參考。就業市場判讀基於有限的觀測數據源，不代表完整的市場狀況。「溫度」指標為綜合性定性判斷，非精確量化指數。任何就業或投資決策請諮詢專業人士。數據來源的更新頻率不一（部分為即時、部分為月度或季度），跨來源比較時應注意時間差異。
```

---

## 輸出位置

`docs/Narrator/climate_index/{YYYY}-W{WW}-climate-index.md`

---

## 自我審核 Checklist

產出報告前，必須逐項確認：

- [ ] **來源標註完整**：所有數字是否有明確來源標註（layer_name）？
- [ ] **溫度邏輯一致**：溫度判讀是否與核心指標一致（不矛盾）？若指標方向矛盾，是否在判讀依據中說明？
- [ ] **地域區分清晰**：是否明確區分台灣數據與全球數據，未混為一談？
- [ ] **免責聲明存在**：免責聲明是否完整包含？
- [ ] **推測標註明確**：推測性判斷是否明確標註為推測？
- [ ] **無投資建議**：是否避免了具體的投資建議？
- [ ] **數據覆蓋透明**：是否說明了哪些 Layer 本週無數據？
- [ ] **時間一致性**：跨來源數據的觀測時間是否一致？若不一致是否標註？
- [ ] **前期銜接**：溫度變化是否與前期報告邏輯銜接？
- [ ] **簡化風險控制**：是否避免將複雜市場過度簡化為單一判斷？

---

## 執行注意事項

1. **數據不足處理**：若某 Layer 本週無新數據，使用「數據未更新」標註，不以舊數據充數。
2. **矛盾信號處理**：台灣數據與全球數據方向相反時，以台灣數據為主要判讀依據，但必須說明全球背景。
3. **極端事件處理**：單一重大裁員或招聘事件不應單獨決定溫度，需評估是否為產業性或全面性趨勢。
4. **季節性考量**：農曆年前後、畢業季等季節性因素應在判讀中提及，避免將季節性波動誤判為趨勢。
