# 技能需求變化觀測站 (Skills Shift Observatory)

觀測全球就業市場變化與 AI 對各產業職缺的衝擊。

## 系統概覽

本系統透過 Claude CLI 驅動,自動擷取、萃取、分析全球就業市場數據,追蹤 **53 個職務角色**在 **14 個產業**中的需求變化,並以 **5 種 AI 取代向量**分析自動化衝擊。

### 觀測架構

```
微觀層(台灣原始資料)          宏觀層(全球聚合報告)          事件層(新聞與信號)
├── 104人力銀行職缺              ├── LinkedIn Workforce          ├── 裁員/人力新聞
├── 台灣就業通                   ├── Indeed Hiring Lab           └── 融資/財報信號
└── 求職天眼通評論               ├── OECD 就業統計
                                 ├── ILO 國際勞工統計
                                 ├── WEF 未來就業報告
                                 ├── Stack Overflow 調查
                                 ├── ManpowerGroup 展望
                                 ├── US BLS 勞動統計
                                 └── Hays 薪資指南
```

### AI 取代向量

| 向量 | 定義 | 觀測角色數 |
|------|------|-----------|
| 認知例行 | 規則明確的腦力工作 | 10 |
| 認知非例行 | 需判斷力的專業知識工作 | 16 |
| 體力例行 | 重複性體力勞動 | 6 |
| 體力非例行 | 需靈活應變的體力工作 | 14 |
| 高度人際 | 核心在人際連結 | 4 |
| AI 原生 | AI 時代新興角色 | 2 |

### 產出報告

| 報告 | 內容 | 更新頻率 |
|------|------|---------|
| 景氣溫度計 | 就業市場綜合溫度判讀 | 週 |
| 技能需求漂移 | 技能標籤上升/下降榜 | 週 |
| 產業分層分析 | 各產業用人方向與趨勢 | 週 |
| 薪資帶分析 | 跨產業跨地區薪資比較 | 週 |
| 求職策略建議 | 技能缺口→學習路徑→職缺 | 週 |

## 系統健康度

> 最後更新：2026-02-06

### Layers — 微觀層（台灣）

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| tw_govjobs | 2026-02-05 | 1,000 | ✅ 正常 |
| tw_104_jobs | — | 0 | ❌ 已停用（API 風險） |
| tw_company_reviews | — | 0 | ❌ 已停用（需驗證） |

### Layers — 宏觀層（全球職缺）

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| global_hn_hiring | 2026-02-06 | 2,336 | ✅ 正常 |
| global_arbeitnow | 2026-02-06 | 1,181 | ✅ 正常 |
| global_weworkremotely | 2026-02-05 | 99 | ✅ 正常 |
| global_remoteok | 2026-02-05 | 94 | ✅ 正常 |

### Layers — 宏觀層（全球報告）

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| global_bls | 2026-01-28 | 143 | ✅ 正常 |
| global_hays_salary | 2026-01-28 | 23 | ✅ 正常 |
| global_stackoverflow | 2026-01-28 | 21 | ✅ 正常 |
| global_linkedin_workforce | 2026-01-28 | 12 | ✅ 正常 |
| global_indeed_hiring | 2026-01-28 | 10 | ✅ 正常 |
| global_manpower_outlook | 2026-01-28 | 3 | ✅ 正常 |
| global_oecd_employment | — | 0 | ⚠️ 待擷取 |
| global_ilo_stats | — | 0 | ⚠️ 待擷取 |
| global_wef_jobs | — | 0 | ⚠️ 需手動下載 PDF |

### Layers — 事件層

| Layer | 最後更新 | 資料筆數 | 狀態 |
|-------|----------|----------|------|
| funding_signals | 2026-01-28 | 37 | ✅ 正常 |
| workforce_news | 2026-01-28 | 20 | ✅ 正常 |

### Modes（Narrator 報告）

| Mode | 最後產出 | 報告檔案 | 狀態 |
|------|----------|----------|------|
| climate_index | 2026-02-06 | 2026-W06-climate-index.md | ✅ 正常 |
| skills_drift | 2026-02-06 | 2026-W06-skills-drift.md | ✅ 基線版 |
| industry_segments | 2026-02-06 | 2026-W06-industry-segments.md | ✅ 正常 |
| salary_bands | 2026-02-06 | 2026-W06-salary-bands.md | ✅ 正常 |
| career_strategy | 2026-02-06 | 2026-W06-career-strategy.md | ✅ 正常 |

### 資料總覽

| 類型 | 筆數 |
|------|------|
| 職缺資料總計 | 4,710 |
| 宏觀報告資料 | 212 |
| 事件信號資料 | 57 |
| **總計** | **4,979** |

## 使用方式

### 執行完整流程
```bash
# 在專案根目錄執行 Claude CLI
claude "執行完整流程"
```

### 指定執行
```bash
claude "執行 tw_104_jobs"      # 只跑 104 職缺 Layer
claude "執行 climate_index"     # 只跑景氣溫度計報告
claude "只跑 fetch"             # 只執行資料擷取
```

## 環境設定

需要在 `.env` 設定:
```
QDRANT_URL=...
QDRANT_API_KEY=...
QDRANT_COLLECTION=skills-shift-observatory
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSION=1536
OPENAI_API_KEY=sk-...
```

## 授權

Private repository.
