# workforce_news Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | workforce_news / 裁員與人力動態新聞 |
| **Engineering function** | 從多個新聞 RSS 源擷取全球裁員、招聘潮、企業重組等人力市場事件 |
| **Collectable data** | 裁員公告（公司、人數、部門）、大規模招聘消息、企業重組、政策變動 |
| **Automation level** | 75% — RSS 結構化，但事件萃取需 AI 判斷關鍵資訊與可信度 |
| **Output value** | 即時人力市場事件追蹤，提供裁員/擴張信號作為技能需求變動的領先指標 |
| **Risk type** | 媒體報導可能不準確、數字未經公司確認、消息來源模糊 |
| **Reviewer persona** | 資料可信度審核員 + 幻覺風險審核員 |

## 資料來源

本 Layer 從以下 RSS 源擷取資料：

- **TechCrunch Layoffs tag**: https://techcrunch.com/tag/layoffs/feed/
- **Reuters Business/Economy**: https://www.reutersagency.com/feed/?best-topics=business-finance
- **Bloomberg workforce news** (視可用性)
- **台灣經濟日報/工商時報 RSS** (台灣企業人力動態)

## WebFetch 策略

**按需使用** — 當以下情況發生時才使用 WebFetch 抓取原始頁面：

1. RSS description 內容不足 100 字
2. 缺少關鍵欄位：裁員人數、公司名稱、受影響部門
3. 數字資訊模糊（如「數百人」「大規模」等）

**降級處理**：
- WebFetch 失敗時，仍基於 RSS 資料萃取
- 在 `notes` 欄位標註「WebFetch 失敗，僅基於 RSS 摘要」
- 若 RSS description 不足以判定關鍵資訊，觸發 `[REVIEW_NEEDED]`

## 分類規則 (Category Enum)

**嚴格限制**：category 只能使用以下 5 個英文值，不可自行新增。

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `layoff` | 裁員公告 | 公司宣布或媒體報導的裁員事件（含具體人數或「預計裁員」聲明） |
| `hiring_surge` | 大規模招聘 | 公司宣布大量招聘計劃（通常 >100 人或明確提及「擴張」「大規模招聘」） |
| `restructuring` | 企業重組 | 部門合併、業務轉型、組織架構調整（可能伴隨裁員或轉調） |
| `policy_change` | 政策變動 | 政府就業政策、勞動法規變更、產業政策調整 |
| `market_signal` | 市場信號 | 產業趨勢報導、就業市場綜合分析（無具體單一事件） |

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的情況

1. **裁員人數來自未具名消息來源**
   - 例如：「據傳」「消息人士指出」「知情人士透露」
   - 不含公司官方聲明或具名高層發言

2. **同一事件不同媒體報導的數字有顯著差異**
   - 例如：A 媒體稱「500 人」，B 媒體稱「1000 人」
   - 差異超過 20%

3. **WebFetch 失敗且 RSS description 中的數字模糊**
   - 例如：「數百人」「大量員工」「significant headcount reduction」
   - 無法從 RSS 資料中提取確切數字

### 不觸發的情況

- ❌ **公司官方公告的裁員數字**（即使看起來很大）
  - 官方公告本身就是一手來源
  - 在 `confidence` 欄位反映為「高」即可

- ❌ **新聞僅有標題而無詳細數字**
  - 在 `notes` 欄位標註「原始報導未提供具體數字」
  - `headcount` 填 `null`

- ❌ **政策變動新聞**
  - 政府公告本身就是一手來源
  - 不因「無具體影響人數」而標記

## 萃取邏輯

對每一筆 JSONL 資料（RSS item）執行以下步驟：

1. **讀取 JSON 欄位**：title, link, description, pubDate
2. **判定是否需要 WebFetch**：依「WebFetch 策略」判斷
3. **萃取關鍵資訊**：
   - 公司名稱（company）
   - 裁員/招聘人數（headcount）
   - 受影響地區（region）
   - 受影響部門或產業（industry）
   - 原因（reason）
4. **判定 category**：依分類規則選擇唯一 enum 值
5. **判定 severity**：
   - `critical`: >1000 人
   - `high`: >100 人
   - `medium`: >10 人
   - `low`: 1-10 人
   - `info`: 無具體人數或非裁員事件
6. **判定 confidence**：
   - `高`: 公司官方公告、政府公告
   - `中`: 主流媒體報導且有具名來源
   - `低`: 消息來源不明、數字模糊
7. **檢查 `[REVIEW_NEEDED]` 觸發規則**
8. **產出 Markdown 檔案**：檔名格式 `{YYYYMMDD}-{company_slug}-{category}.md`

## 輸出格式

```markdown
---
title: "{headline}"
source_url: "{article_url}"
source_layer: workforce_news
category: "{layoff|hiring_surge|restructuring|policy_change|market_signal}"
date: "{pubDate}"
fetched_at: "{timestamp}"
company: "{company_name or N/A}"
headcount: {number or null}
region: "{affected_region}"
industry: "{industry}"
confidence: "{高|中|低}"
severity: "{critical|high|medium|low|info}"
---

# {headline}

## 事件摘要
{2-3 sentence summary of the event}

## 關鍵數據
- **公司**：{company}
- **影響人數**：{headcount}
- **影響地區**：{region}
- **影響部門/產業**：{department/industry}
- **原因**：{stated reason}

## 來源與可信度
- **來源類型**：{官方公告|媒體報導|傳聞}
- **Confidence 依據**：{why this confidence level}

## 備註
{additional notes, including WebFetch status if applicable}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] **category 是否為 5 個 enum 值之一？**（layoff, hiring_surge, restructuring, policy_change, market_signal）
- [ ] **數字是否有來源支持？**（避免無中生有）
- [ ] **推測與事實是否明確區分？**（推測需在 notes 欄位標註）
- [ ] **severity 是否合理？**（>1000人=critical, >100人=high, >10人=medium, 其他=low, 無人數=info）
- [ ] **company 名稱是否正確？**（非縮寫或拼寫錯誤，使用官方全名）
- [ ] **confidence 判定是否合理？**（官方=高，主流媒體=中，傳聞=低）
- [ ] **是否依規則正確判定 `[REVIEW_NEEDED]`？**（不可自行擴大範圍）
- [ ] **YAML frontmatter 格式是否正確？**（所有欄位皆有值或 null）
- [ ] **檔名是否符合規範？**（日期-公司-分類.md）
