# 資料源探索紀錄

## 已採用

| 資料源 | 類型 | 對應 Layer | 採用日期 | 備註 |
|--------|------|-----------|----------|------|
| 104人力銀行 | JSON API | tw_104_jobs | 2026-01-28 | 非官方API,需注意 rate limiting |
| 台灣就業通 | 網頁擷取 | tw_govjobs | 2026-01-28 | 政府就業服務平台 |
| 求職天眼通 | 網頁擷取 | tw_company_reviews | 2026-01-28 | 公司評論與面試經驗 |
| LinkedIn Economic Graph | 公開報告 | global_linkedin_workforce | 2026-01-28 | 全球人才流動報告 |
| Indeed Hiring Lab | RSS + 報告 | global_indeed_hiring | 2026-01-28 | 多國招聘趨勢研究 |
| OECD.Stat | REST API | global_oecd_employment | 2026-01-28 | OECD國家就業統計 |
| ILO ILOSTAT | REST API | global_ilo_stats | 2026-01-28 | 全球勞工統計(含開發中國家) |
| WEF Future of Jobs | 報告/PDF | global_wef_jobs | 2026-01-28 | 每2年發布的未來就業預測 |
| Stack Overflow Survey | 資料集 | global_stackoverflow | 2026-01-28 | 年度開發者調查 |
| ManpowerGroup MEOS | 報告 | global_manpower_outlook | 2026-01-28 | 季度就業展望調查 |
| US BLS | REST API | global_bls | 2026-01-28 | 美國勞動統計局官方數據 |
| Hays Salary Guide | 報告/PDF | global_hays_salary | 2026-01-28 | 年度薪資指南 |
| TechCrunch/Reuters RSS | RSS | workforce_news | 2026-01-28 | 裁員與人力動態新聞 |
| TechCrunch Funding RSS | RSS | funding_signals | 2026-01-28 | 融資與投資新聞 |
| Eurostat Labour Market API | REST API | global_eurostat | 2026-02-08 | 歐盟27國就業/失業/薪資統計 |
| Australia Bureau of Statistics | REST API | global_abs | 2026-02-08 | 澳洲勞動力調查(1978至今) |
| KOSIS (Korea Statistics) | REST API | global_kosis | 2026-02-08 | 韓國就業/失業/勞動參與率統計 |
| Adzuna API | REST API | global_adzuna | 2026-02-08 | 全球多國職缺+薪資趨勢 |
| Statistics Canada | REST API | global_statcan | 2026-02-08 | 加拿大勞動力調查(月度更新) |

## 評估中

### P1 優先（建議立即採用）

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 涵蓋範圍 |
|--------|------|-----|------|----------|------|----------|


### P2 中優先（短期評估）

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 涵蓋範圍 |
|--------|------|-----|------|----------|------|----------|
| Japan Stats Bureau | CSV/Excel | https://www.stat.go.jp/english/data/roudou/ | ja/en | 2026-02-08 | 可透過 ILO 取得 | 日本勞動力 |
| Stats NZ | 報告 | https://www.stats.govt.nz/topics/labour-market/ | en | 2026-02-08 | 待評估 API | 紐西蘭就業 |
| Jobicy RSS | RSS | https://jobicy.com/jobs-rss-feed | en | 2026-02-08 | 可整合 | 遠端工作（含亞太）|
| WHO Health Workforce | OData API | https://www.who.int/data/gho/data/themes/topics/health-workforce | en | 2026-02-08 | 待評估 | 全球醫療人力 |

### P3 低優先（原有）

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 下次評估 |
|--------|------|-----|------|----------|------|----------|
| 1111人力銀行 | 網頁/API | https://www.1111.com.tw/ | zh-TW | 2026-01-28 | 待測試API | 2026-02-15 |
| CakeResume | 網頁 | https://www.cake.me/ | zh-TW/en | 2026-01-28 | 偏新創科技,優先級低 | 2026-03-01 |
| Yourator | 網頁 | https://www.yourator.co/ | zh-TW | 2026-01-28 | 偏新創科技,優先級低 | 2026-03-01 |
| yes123 | 網頁 | https://www.yes123.com.tw/ | zh-TW | 2026-01-28 | 與104高度重疊 | 2026-03-01 |
| 公職網證照 | 網頁 | https://www.public.com.tw/exam-education/certificate-time | zh-TW | 2026-01-28 | 更新頻率低 | 2026-06-01 |
| 教育部證照 | 網頁 | https://me.moe.edu.tw/license/categories.php | zh-TW | 2026-01-28 | 更新頻率低 | 2026-06-01 |

## 已排除

| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估時間 |
|--------|------|----------|----------|-------------|
| LinkedIn Jobs API | API | API嚴格封鎖,無法可靠存取 | 2026-01-28 | 2026-07-01 |
| Dice Jobs API | API | API 已於 2017 年關閉 | 2026-02-08 | 永久排除 |
| GitHub Jobs | API | 官方招聘平台已關閉 | 2026-02-08 | 永久排除 |
| Greenhouse API | API | 僅提供單一公司職缺，無市場趨勢 | 2026-02-08 | 永久排除 |
| Wellfound (AngelList) | 網頁 | 無 API/RSS，需爬蟲有法律風險 | 2026-02-08 | 2026-08-01 |
