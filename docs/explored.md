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

## 評估中

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
