--- MAU, WAU, DAU
-- sticky factor
-- lifetime по когортам как интеграл от retention

-- dau
with a as ( 
	select
		to_char(entry_at, 'YYYY-MM-DD') AS ymd,
		count(distinct user_id) AS cnt
	FROM userentry u
	WHERE to_char(entry_at, 'YYYY-MM-DD') >= '2021-11-20'
	GROUP BY ymd
	LIMIT 90
)
SELECT avg(cnt) AS dau
FROM a;


-- wau
with a as ( 
	select
		to_char(entry_at, 'YYYY-WW') AS yw,
		count(distinct user_id) AS cnt
	FROM userentry u
	GROUP BY yw
	HAVING count(DISTINCT to_char(entry_at, 'YYYY-MM-DD')) >= 6
)
SELECT avg(cnt) AS wau
FROM a;


-- mau
with a as ( 
	select
		to_char(entry_at, 'YYYY-MM') AS ym,
		count(distinct user_id) AS cnt
	FROM userentry u
	GROUP BY ym
	HAVING count(DISTINCT to_char(entry_at, 'YYYY-MM-DD')) >= 25
)
SELECT avg(cnt) AS wau
FROM a;


-- sticky factor
with a as ( 
	select
		to_char(entry_at, 'YYYY-MM-DD') AS ymd,
		count(distinct user_id) AS cnt_dau
	FROM userentry u
	WHERE to_char(entry_at, 'YYYY-MM-DD') >= '2021-11-20'
	GROUP BY ymd
),
b as( 
	select
		to_char(entry_at, 'YYYY-MM') AS ym,
		count(distinct user_id) AS cnt_mau
	FROM userentry u
	GROUP BY ym
	HAVING count(DISTINCT to_char(entry_at, 'YYYY-MM-DD')) >= 25
)

SELECT round(avg(cnt_dau) * 100.0 / avg(cnt_mau), 2) AS sticky_factor
FROM a, b


-- lifetime
WITH a AS (
SELECT
	u.user_id,
	to_char(u2.date_joined, "YYYY-MM") AS cohort,
	EXTRACT(days FROM u.entry_at. u2.date_joined) AS diff
FROM usentry u
JOIN users u2
ON u.user_id = u2.id
WHERE u.user_id > = 94
),
b AS (
SELECT
	cohort,
	diff,
	count(DISTINCT user_id) AS cnt
FROM a
GROUP BY cohort, diff
),
c as(
SELECT diff, cnt * 1.0 / first_value(cnt) over(PARTITION BY cohort ORDER BY diff) AS rt
FROM b
)
SELECT cohort, sum(rt) AS lifetime
FROM c
GROUP BY cohort