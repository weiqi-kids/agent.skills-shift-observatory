# funding_signals Layer 定義

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | funding_signals / 投資與融資信號 |
| **Engineering function** | 從新聞與公開資訊擷取企業融資、IPO、併購、財報等財務信號，作為就業市場的領先指標 |
| **Collectable data** | 融資輪次（公司、金額、階段）、IPO 消息、併購案、財報重要指引（裁員/擴張暗示） |
| **Automation level** | 70% — RSS 結構化，但金額萃取與融資階段判定需 AI 處理 |
| **Output value** | 企業財務健康信號，預測人力擴張或收縮趨勢 |
| **Risk type** | 融資金額可能被誇大、財報解讀需專業知識、產業差異大 |
| **Reviewer persona** | 資料可信度審核員 + 法規與責任審核員 |

## 重要聲明

**⚠️ 本 Layer 產出的資料僅作為就業市場趨勢信號，不構成投資建議。**

所有財務資訊的解讀與使用應由專業人員進行，本系統僅作為產業人力動態觀測的參考資料。

## 資料來源

本 Layer 從以下 RSS 源擷取資料：

- **TechCrunch Funding**: https://techcrunch.com/tag/funding/feed/
- **Crunchbase News**: https://news.crunchbase.com/feed/
- **VentureBeat Funding**: https://venturebeat.com/category/business/feed/
- **SEC EDGAR** (選用，需額外實作 API 爬蟲)

## WebFetch 策略

**按需使用** — 當以下情況發生時才使用 WebFetch 抓取原始頁面：

1. RSS description 缺少融資金額
2. 缺少投資人資訊（lead investor）
3. 融資階段不明確（如僅稱「新一輪融資」）
4. 併購案缺少交易金額

**降級處理**：
- WebFetch 失敗時，仍基於 RSS 資料萃取
- 在 `notes` 欄位標註「WebFetch 失敗，部分資訊可能不完整」
- 若關鍵欄位（金額、階段）無法判定，觸發 `[REVIEW_NEEDED]`

## 分類規則 (Category Enum)

**嚴格限制**：category 只能使用以下 5 個英文值，不可自行新增。

| Category | 中文名稱 | 判定條件 |
|----------|----------|----------|
| `funding_round` | 融資輪次 | 種子輪到 F 輪等股權融資（包含 Pre-seed, Seed, Series A-F, Growth） |
| `ipo` | IPO 與上市 | 首次公開發行、SPAC 合併、直接上市（Direct Listing） |
| `acquisition` | 併購 | 企業併購、收購、資產購買（含全資收購與部分股權收購） |
| `earnings_signal` | 財報信號 | 財報中的人力相關指引（如「計劃招聘 X 人」「預計縮減營運成本」） |
| `market_trend` | 市場趨勢 | VC 投資趨勢、產業資金流向、融資環境綜合報導 |

## `[REVIEW_NEEDED]` 觸發規則

### 必須標記的情況

1. **融資金額來自未驗證來源**
   - 例如：「據傳」「消息人士指出」「estimated」
   - 不含公司官方公告或監管機構披露

2. **財報解讀涉及對裁員的推測**
   - 例如：從「營運成本下降」推測「可能裁員」
   - 財報僅提及「成本優化」但無具體人力計劃

3. **併購金額顯著不一致**
   - 不同來源報導的交易金額差異 >30%

4. **WebFetch 失敗且 RSS 缺少關鍵欄位**
   - 融資金額、投資人、融資階段三者有兩項以上缺失

### 不觸發的情況

- ❌ **公司官方公告的融資消息**（即使金額很大）
  - 官方 PR 或監管機構披露（如 SEC Form D）
  - 在 `confidence` 欄位反映為「高」即可

- ❌ **標準融資輪次報導**
  - 主流媒體報導且有具名投資人
  - 金額與階段明確

- ❌ **IPO 或併購的公開資訊**
  - 來自交易所公告或監管機構披露

- ❌ **VC 市場趨勢報導**
  - 產業綜合分析本身不涉及具體公司數據真偽

## 萃取邏輯

對每一筆 JSONL 資料（RSS item）執行以下步驟：

1. **讀取 JSON 欄位**：title, link, description, pubDate
2. **判定是否需要 WebFetch**：依「WebFetch 策略」判斷
3. **萃取關鍵資訊**：
   - 公司名稱（company）
   - 融資金額與幣別（amount, currency）
   - 融資階段（stage）：Seed, Series A-F, IPO, Acquisition 等
   - 主要投資人（investors）
   - 估值（valuation，若有）
   - 與人力市場的關聯性（job_market_implication）
4. **判定 category**：依分類規則選擇唯一 enum 值
5. **判定 severity**：
   - `critical`: >$1B 融資、重大併購、IPO
   - `high`: $100M-$1B 融資、Series C 以後
   - `medium`: $10M-$100M 融資、Series A-B
   - `low`: <$10M 融資、種子輪
   - `info`: 市場趨勢報導
6. **判定 confidence**：
   - `高`: 公司官方公告、監管機構披露
   - `中`: 主流媒體報導且有具名投資人
   - `低`: 消息來源不明、金額模糊
7. **檢查 `[REVIEW_NEEDED]` 觸發規則**
8. **產出 Markdown 檔案**：檔名格式 `{YYYYMMDD}-{company_slug}-{category}.md`

## 輸出格式

```markdown
---
title: "{headline}"
source_url: "{article_url}"
source_layer: funding_signals
category: "{funding_round|ipo|acquisition|earnings_signal|market_trend}"
date: "{pubDate}"
fetched_at: "{timestamp}"
company: "{company_name or N/A}"
amount: {number or null}
currency: "{USD|EUR|TWD|etc or N/A}"
stage: "{Seed|Series A-F|IPO|Acquisition|etc or N/A}"
investors: "{lead_investor(s) or N/A}"
valuation: {number or null}
industry: "{industry}"
job_market_implication: "{positive|negative|neutral|unknown}"
confidence: "{高|中|低}"
severity: "{critical|high|medium|low|info}"
---

# {headline}

## 事件摘要
{2-3 sentence summary of the funding event}

## 關鍵數據
- **公司**：{company}
- **融資金額**：{amount} {currency}
- **融資階段**：{stage}
- **主要投資人**：{investors}
- **估值**：{valuation} (若有)
- **產業**：{industry}

## 人力市場意涵
{分析此融資事件對該公司人力需求的可能影響，例如：Series B 融資通常伴隨團隊擴張；併購案可能導致組織重組}

## 來源與可信度
- **來源類型**：{官方公告|媒體報導|傳聞}
- **Confidence 依據**：{why this confidence level}

## 免責聲明
本資料僅為就業市場分析用途的信號指標，不構成任何投資建議。

## 備註
{additional notes, including WebFetch status if applicable}
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] **category 是否為 5 個 enum 值之一？**（funding_round, ipo, acquisition, earnings_signal, market_trend）
- [ ] **金額與幣別是否合理？**（避免單位錯誤，如 M/B 混淆）
- [ ] **融資階段是否正確？**（不可自行創造新階段名稱）
- [ ] **投資人資訊是否準確？**（不可推測未提及的投資人）
- [ ] **severity 是否合理？**（依融資規模判定）
- [ ] **company 名稱是否正確？**（使用官方全名，非縮寫）
- [ ] **confidence 判定是否合理？**（官方=高，主流媒體=中，傳聞=低）
- [ ] **job_market_implication 是否有依據？**（基於融資階段與產業常見模式，不可無根據推測）
- [ ] **是否依規則正確判定 `[REVIEW_NEEDED]`？**（不可自行擴大範圍）
- [ ] **免責聲明是否包含？**（必須在每個檔案中包含）
- [ ] **YAML frontmatter 格式是否正確？**（所有欄位皆有值或 null）
- [ ] **檔名是否符合規範？**（日期-公司-分類.md）
