# global_wef_jobs Layer 定義

## Layer 定義表

| 項目 | 說明 |
|------|------|
| **Layer name** | global_wef_jobs / WEF 未來就業報告 |
| **Engineering function** | 從手動下載的 WEF PDF 報告萃取關鍵發現與預測 |
| **Collectable data** | 未來5年技能需求預測、自動化取代風險評估、新興職業預測、企業技能策略 |
| **Data source** | WEF PDF 報告（手動下載至 `docs/Extractor/global_wef_jobs/raw/`） |
| **Automation level** | 40% — 下載為手動，萃取為自動（使用 Claude PDF 讀取功能） |
| **Output value** | 權威性未來就業趨勢預測，全球企業雇主觀點 |
| **Risk type** | 報告僅每2年發布、預測可能不準確、WEF 網站封鎖自動下載 |
| **Reviewer persona** | 幻覺風險審核員（萃取預測數據容易失真） |

## 重要說明：手動下載模式

**WEF 網站使用 Akamai CDN 封鎖自動化存取**，無法透過 curl/wget 自動下載 PDF。

需手動下載 PDF 到 `docs/Extractor/global_wef_jobs/raw/` 目錄，命名規則：
- `WEF_Future_of_Jobs_Report_2025.pdf`
- `WEF_Future_of_Jobs_Report_2023.pdf`
- 其他報告依此類推

下載來源：https://www.weforum.org/publications/

## 執行指令

### 輸入格式

fetch.sh 產出的 JSONL 每行包含一份 PDF 報告的元數據：

```json
{
  "title": "Future of Jobs Report 2025",
  "link": "https://www.weforum.org/publications/...",
  "published_date": "2025-01-01",
  "pdf_path": "/path/to/docs/Extractor/global_wef_jobs/raw/WEF_Future_of_Jobs_Report_2025.pdf",
  "pdf_filename": "WEF_Future_of_Jobs_Report_2025.pdf",
  "file_size_bytes": 12345678,
  "source": "pdf_local",
  "report_edition": "Future of Jobs Report 2025",
  "fetched_at": "2026-01-28T10:30:00Z",
  "extraction_method": "pdf_read"
}
```

### 萃取邏輯

1. **使用 Read 工具讀取 PDF**（Claude 具備 PDF 讀取能力）
   - 從 JSONL 的 `pdf_path` 欄位取得 PDF 路徑
   - 使用 Read tool 讀取 PDF 內容
2. **萃取關鍵資訊**
   - 報告的執行摘要（Executive Summary）
   - 關鍵發現（Key Findings）
   - 數值預測（需標明頁碼/章節來源）
   - 圖表說明與數據表格
3. **依 category enum 分類**
   - 將報告內容依主題拆分為多個 .md 檔
4. **產生結構化 Markdown 輸出**
5. **驗證數據來源**
   - 所有數值預測必須標明出處（頁碼或章節）
   - 無法驗證的數據必須標記 `[REVIEW_NEEDED]`

## 分類規則（Category Enum）

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `skills_forecast` | 技能預測 | 內容涉及未來5年技能需求、技能差距預測 |
| `automation_risk` | 自動化風險 | 內容涉及自動化取代比例、受影響職業評估 |
| `emerging_roles` | 新興職業 | 內容涉及新興職業清單、未來職業趨勢 |
| `employer_strategy` | 雇主策略 | 內容涉及企業技能培訓、招募策略、組織轉型 |
| `regional_outlook` | 區域展望 | 內容涉及特定區域或國家的就業趨勢分析 |

**嚴格限制：category 只能使用上述英文值，不可自行新增。** 需要新增 category 時必須與使用者確認後寫入本檔案。

## PDF 讀取規則

### 策略：使用 Read tool 直接讀取 PDF

本 Layer 使用 Claude 的 PDF 讀取功能，不使用 WebFetch（WEF 網站封鎖自動存取）。

### PDF 讀取執行

1. 從 JSONL 的 `pdf_path` 欄位取得 PDF 絕對路徑
2. 使用 Read tool 讀取 PDF 檔案
3. Claude 會將 PDF 內容轉換為可分析的文字與圖像
4. 萃取關鍵資訊時，標明來源頁碼

### PDF 不存在時的處理

若 `pdf_path` 指向的檔案不存在（JSONL 記錄但 PDF 已被移除）：
1. 跳過該筆記錄
2. 在日誌中標註：「PDF 不存在：{pdf_filename}」
3. 不產出 .md 檔（無資料可萃取）

### 無 PDF 時的處理

若 fetch.sh 未找到任何 PDF：
1. 萃取流程會收到空 JSONL 或無 JSONL
2. 應提示使用者需要手動下載 PDF
3. 不產出任何 .md 檔

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的場景

1. **預測數據無法驗證** — PDF 中萃取的數值（如「45% 的職業將被自動化取代」）無法在報告中找到對應頁碼/章節
2. **報告版本不明** — 無法確認報告是哪一年的版本（如 2023 年版 vs 2025 年版）
3. **PDF 讀取不完整** — PDF 因加密、損壞或其他原因無法完整讀取
4. **數據出處模糊** — 報告引用的數據未標明來源（如「全球企業調查顯示…」但無樣本數說明）

### 不觸發的場景

- ❌ **預測本身的不確定性** — 未來預測固有的不確定性，非萃取問題
- ❌ **報告發布頻率低** — WEF 每2年發布為常態，非萃取問題
- ❌ **缺少特定國家資料** — 報告可能未涵蓋所有國家，屬正常限制
- ❌ **PDF 需手動下載** — 這是 WEF 網站的限制，非萃取問題

## 輸出格式

```markdown
---
source_layer: global_wef_jobs
category: {category_enum_value}
title: {報告標題}
report_edition: {如 "Future of Jobs Report 2025"}
published_date: {YYYY-MM-DD}
fetched_at: {YYYY-MM-DD HH:MM:SS}
source_url: {WEF 報告頁面 URL}
pdf_filename: {PDF 檔名}
extraction_method: pdf_read
confidence: {高/中/低}
---

# {報告標題}

## 關鍵發現

{列點摘要報告的 3-5 項核心發現}

## 數據預測

{萃取的具體數值預測，必須標明出處段落}

例如：
- 未來5年，數據分析技能需求預計增長 30%（來源：第 12 頁 Figure 3）
- 45% 的企業計劃增加 AI 相關職位（來源：第 25 頁企業調查結果）

## 新興趨勢

{報告指出的新興趨勢或轉變}

## 區域差異

{如有提及區域性差異，在此說明}

## 資料來源

- **報告**：{report_edition}
- **發布機構**：World Economic Forum
- **發布日期**：{published_date}
- **擷取時間**：{fetched_at}
- **PDF 檔案**：{pdf_filename}
- **萃取方式**：PDF 讀取

## 備註

{如有 PDF 讀取問題、數據出處不明等，在此說明}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] category 為定義的 5 個 enum 值之一
- [ ] report_edition 明確標明版本年份
- [ ] 數據預測已標明出處（頁碼或章節）
- [ ] pdf_filename 正確對應來源 PDF
- [ ] confidence 評估合理（PDF 完整讀取且數據可驗證為「高」；部分缺失為「中」）
- [ ] 若預測數據無法驗證、報告版本不明或 PDF 讀取不完整，已標記 `[REVIEW_NEEDED]`
- [ ] 未因預測不確定性或發布頻率而誤標 `[REVIEW_NEEDED]`
- [ ] 所有數值預測有明確來源引用（含頁碼）
- [ ] 無幻覺內容（所有資訊皆來自 PDF 原文）
