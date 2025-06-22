-- a. Melihat daftar tabel di schemas
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

-- b. Melihat isi tabel ds_salaries
SELECT * FROM public.ds_salaries;

-- c. Melihat isi tabel ds_salaries dari bawah
SELECT * FROM public.ds_salaries ORDER BY no DESC;

-- d. Melihat informasi di tabel ds_salaries
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ds_salaries';

-- e. Melihat kolom yang no = 100, 200
SELECT * FROM public.ds_salaries WHERE no IN (100,200);

-- f. SOAL 
-- 1. Melihat apakah ada data yang null
SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE no IS NULL) AS null_no,
  COUNT(*) FILTER (WHERE work_year IS NULL) AS null_work_year,
  COUNT(*) FILTER (WHERE experience_level IS NULL) AS null_experience_level,
  COUNT(*) FILTER (WHERE employment_type IS NULL) AS null_employment_type,
  COUNT(*) FILTER (WHERE job_title IS NULL) AS null_job_title,
  COUNT(*) FILTER (WHERE salary IS NULL) AS null_salary,
  COUNT(*) FILTER (WHERE salary_currency IS NULL) AS null_salary_currency,
  COUNT(*) FILTER (WHERE salary_in_usd IS NULL) AS null_salary_in_usd,
  COUNT(*) FILTER (WHERE employee_residence IS NULL) AS null_employee_residence,
  COUNT(*) FILTER (WHERE remote_ratio IS NULL) AS null_remote_ratio,
  COUNT(*) FILTER (WHERE company_location IS NULL) AS null_company_location,
  COUNT(*) FILTER (WHERE company_size IS NULL) AS null_company_size
FROM public.ds_salaries;

-- 2. Job_title yang relate sama data analyst
SELECT DISTINCT job_title 
FROM public.ds_salaries 
WHERE job_title 
LIKE '%Data Analyst%' 
ORDER BY job_title;

-- 3. Average salary dari job_title yang relate sama data_analyst
SELECT AVG(salary_in_usd) AS avg_salary_annually
FROM public.ds_salaries
WHERE job_title LIKE '%Data Analyst%';

SELECT AVG((salary_in_usd/12)) AS avg_salary_monthly
FROM public.ds_salaries
WHERE job_title LIKE '%Data Analyst%';

-- 4. Average salary dari job_title yang relate sama data_analyst berdasarkan experience_levelnya
SELECT experience_level, AVG((salary_in_usd/12)) avg_salary_monthly 
FROM public.ds_salaries 
WHERE job_title LIKE '%Data Analyst%' 
GROUP BY experience_level 
ORDER BY avg_salary_monthly DESC;

-- 5. company_location mana yang menawarkan salary_in_usd tertinggi untuk posisi serupa dengan data analyst
-- yang employment_type nya Full-Time dengan Medium atau Entry experience_level dengan rata2 salary_in_usd diatas 1,000,000?

SELECT company_location, job_title, experience_level, 
AVG(((salary_in_usd*16294)/12)) avg_salary_monthly_Rp 
FROM public.ds_salaries 
WHERE job_title LIKE '%Data Analyst%' 
AND employment_type = 'FT' 
AND experience_level IN ('EN', 'MI') 
GROUP BY 1,2,3 
HAVING AVG(((salary_in_usd*16294)/12)) >= 1000000
ORDER BY 4;

-- 6. The highest salary increase from MI to EX level 
-- for Full-Time positions similar to Data Analyst
WITH ds_1 AS (
SELECT work_year, AVG(salary_in_usd) avg_mi
FROM public.ds_salaries
WHERE job_title LIKE '%Data Analyst%' 
AND experience_level = 'MI' AND employment_type = 'FT'
GROUP BY work_year
),
ds_2 AS (
SELECT work_year, AVG(salary_in_usd) avg_ex
FROM public.ds_salaries
WHERE job_title LIKE '%Data Analyst%' 
AND experience_level = 'EX' AND employment_type = 'FT'
GROUP BY work_year
)
SELECT ds1.work_year, ds1.avg_mi, ds2.avg_ex,
ds2.avg_ex-ds1.avg_mi diff
FROM ds_1 ds1 
LEFT JOIN ds_2 ds2
ON ds1.work_year=ds2.work_year ORDER BY diff DESC;

-- 7. kebanyakan employee yang kerja di country yang sama kaya residence tuh pada kerjanya full remote, partial remote, atau no remote?
WITH 
no_remote AS (
	SELECT COUNT(
		CASE WHEN job_title LIKE '%Data Analyst%' 
		AND remote_ratio = 0 
		AND employee_residence = company_location 
		THEN 1 END) AS no_remote_count 
	FROM public.ds_salaries),
partially AS (
	SELECT COUNT(
		CASE WHEN job_title LIKE '%Data Analyst%' 
		AND remote_ratio = 50 
		AND employee_residence = company_location 
		THEN 1 END) AS partially_count 
	FROM public.ds_salaries),
full_remote AS (
	SELECT COUNT(
	CASE WHEN job_title LIKE '%Data Analyst%' 
	AND remote_ratio = 100 
	AND employee_residence = company_location 
	THEN 1 END) AS full_remote_count 
	FROM public.ds_salaries)
SELECT * FROM no_remote CROSS JOIN partially CROSS JOIN full_remote;


-- 8. Akankah AVG(salary) untuk setiap job yang terkait Data Analyst mempunyai rata2 yang tinggi untuk yang employee_residence nya ga sama kaya company_locationnya?
WITH 
ga_sama AS (
	SELECT job_title, AVG(salary_in_usd) avg_ga_sama 
	FROM public.ds_salaries
	WHERE job_title LIKE '%Data Analyst%' 
	AND employee_residence = company_location 
	GROUP BY job_title
),
sama AS (
	SELECT job_title, AVG(salary_in_usd) avg_sama 
	FROM public.ds_salaries
	WHERE job_title LIKE '%Data Analyst%' 
	AND employee_residence != company_location 
	GROUP BY job_title
)
SELECT COALESCE(ga_sama.job_title,sama.job_title), avg_ga_sama, avg_sama, 
	(CASE WHEN avg_ga_sama > avg_sama 
	 THEN 'ya' WHEN avg_ga_sama <= avg_sama 
	 THEN 'tidak' END) apakah_avg_ga_sama_lebih_besar 
FROM ga_sama 
FULL OUTER JOIN sama 
ON ga_sama.job_title=sama.job_title;






