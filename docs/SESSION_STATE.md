# Skills Shift Observatory - 系統狀態紀錄

**最後更新：2026-02-06 18:45 (UTC+8)**

---

## 一、系統資料總覽

**總計：4,979 筆職缺資料**

| Layer | 數量 | 狀態 | 說明 |
|-------|------|------|------|
| tw_govjobs | 1,000 | ✅ 完成 | 台灣公家機關職缺 |
| global_arbeitnow | 1,181 | ✅ 完成 | 歐洲/全球職缺（pages 1-17） |
| global_hn_hiring | 2,336 | ✅ 完成 | 北美科技業（Aug 2025 - Feb 2026，6個月） |
| global_weworkremotely | 99 | ✅ 完成 | 遠端職缺 |
| global_remoteok | 94 | ✅ 完成 | 遠端職缺 |

---

## 二、已完成的工作

### 2.1 Layer 建立與資料擷取
- [x] 建立 4 個 global Layer（remoteok, arbeitnow, hn_hiring, weworkremotely）
- [x] 建立對應的 fetch.sh, update.sh, CLAUDE.md
- [x] 修復 tw_govjobs Layer（API 連線成功）
- [x] 擴充 Arbeitnow 資料（pages 6-17，共 924 筆新增）
- [x] 擴充 HN Hiring 歷史資料（Aug 2025 - Jan 2026，共 2,001 筆）

### 2.2 資料萃取完成
- [x] tw_govjobs: 1,000 筆萃取完成
- [x] global_remoteok: 94 筆萃取完成
- [x] global_arbeitnow: 1,181 筆萃取完成（含去重）
- [x] global_hn_hiring: 2,336 筆萃取完成
- [x] global_weworkremotely: 99 筆萃取完成

### 2.3 系統基礎建設
- [x] 建立 lib/skills_taxonomy.json（47 技能 + 同義詞）
- [x] 建立 lib/job_roles.json（53 職業角色 × 14 產業 × 5 AI 取代向量）
- [x] 建立 lib/extract_skills.sh 和 lib/match_role.sh
- [x] 研究台灣資料源替代方案（結論：tw_govjobs 是唯一免費可用選項）

---

## 三、尚未完成的工作

### 3.1 Qdrant 向量資料庫
- [ ] 執行 update.sh 將萃取結果寫入 Qdrant
- [ ] 設定 .env 中的 Qdrant 連線參數

### 3.2 Narrator Mode 報告產出
5 個 Mode 報告已完成（2026-W06）：
- [x] climate_index（景氣溫度計）— 148 行
- [x] skills_drift（技能需求漂移）— 286 行，基線建立版
- [x] industry_segments（產業分層）— 642 行
- [x] salary_bands（薪資帶分析）— 330 行
- [x] career_strategy（求職策略建議）— 336 行

### 3.3 每日自動化
- [ ] 設定每日 fetch 排程（用戶提到會每日 fetch）
- [x] 更新 README.md 健康度儀表板（2026-02-06 完成）

---

## 四、HN Hiring 資料品質統計

| 指標 | 數值 | 比例 |
|------|------|------|
| 遠端友善 | 625 | 60% |
| 技術棧標註 | 582 | 55% |
| 高信心度萃取 | 546 | 52% |
| 薪資揭露 | 149 | 14% |
| 簽證贊助 | 29 | 2.8% |

---

## 五、檔案位置

### 核心設定
- 系統規格：`/CLAUDE.md`
- 維護指令：`/core/CLAUDE.md`
- Extractor 通用規則：`/core/Extractor/CLAUDE.md`
- Narrator 通用規則：`/core/Narrator/CLAUDE.md`

### Layer 定義
- `/core/Extractor/Layers/tw_govjobs/`
- `/core/Extractor/Layers/global_remoteok/`
- `/core/Extractor/Layers/global_arbeitnow/`
- `/core/Extractor/Layers/global_hn_hiring/`
- `/core/Extractor/Layers/global_weworkremotely/`

### 萃取結果
- `/docs/Extractor/tw_govjobs/` (1,000 .md)
- `/docs/Extractor/global_arbeitnow/` (1,181 .md)
- `/docs/Extractor/global_hn_hiring/` (2,336 .md)
- `/docs/Extractor/global_weworkremotely/` (99 .md)
- `/docs/Extractor/global_remoteok/` (94 .md)

### Narrator 報告（2026-W06）
- `/docs/Narrator/climate_index/2026-W06-climate-index.md` - 就業景氣溫度計
- `/docs/Narrator/skills_drift/2026-W06-skills-drift.md` - 技能需求漂移（基線）
- `/docs/Narrator/industry_segments/2026-W06-industry-segments.md` - 產業分層分析
- `/docs/Narrator/salary_bands/2026-W06-salary-bands.md` - 薪資帶分析
- `/docs/Narrator/career_strategy/2026-W06-career-strategy.md` - 求職策略建議

### 輔助檔案
- `/lib/skills_taxonomy.json` - 技能分類表
- `/lib/job_roles.json` - 53 職業角色定義
- `/docs/taiwan-job-sources-research.md` - 台灣資料源研究報告

---

## 六、建議的下一步

1. **設定 Qdrant 向量資料庫**
   - 設定 .env 中的 Qdrant 連線參數
   - 執行 update.sh 將萃取結果寫入 Qdrant

2. **設定每日 fetch**
   ```bash
   # 每日執行各 Layer 的 fetch.sh
   bash core/Extractor/Layers/global_hn_hiring/fetch.sh
   bash core/Extractor/Layers/global_arbeitnow/fetch.sh
   # ... 其他 Layer
   ```

3. **每週產出 Narrator 報告**
   - 執行「Narrator Mode 報告」產出下週 W07 報告
   - skills_drift 從 W07 開始可計算變化率

4. **更新健康度儀表板**
   - 更新 README.md 中的 Layer 狀態表

---

## 七、已知問題

1. **tw_104_jobs** - API 返回 404，已停用（.disabled）
2. **tw_company_reviews** - 需要驗證，已停用（.disabled）
3. **Arbeitnow API** - 最多可抓到 page 17（約 1,700 筆），之後返回空資料

---

**下次進入時，請讀取此檔案了解系統狀態。**
