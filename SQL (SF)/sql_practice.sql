-- Превращаем длинную таблицу в широкую 
SELECT 
NAME,
MAX(CASE WHEN KEY = 'FIO' THEN VALUE END) AS FIO,
MAX(CASE WHEN KEY ='phone' THEN VALUE END) AS Phone,
MAX(CASE WHEN KEY ='email' THEN VALUE END) AS Email,
FROM pasport 
GROUP BY NAME;
-- используем max из-за группировки


-- арифметическая прогрессия рекурсией
WITH RECURSIVE T(n) AS(
		VALUES(1)
	UNION ALL
		SELECT n+1 FROM T WHERE n < 100
)
SELECT SUM(n) FROM  T;


-- вернуть подряд идущие записи
WITH A AS( 
SELECT ID, ID - ROW_NUMBER() OVER (ORDER BY ID ASC) AS diff
FROM Numbers
)
SELECT MIN(ID) AS START, MAX(ID) AS END
FROM A
GROUP BY diff
ORDER BY START;



WITH moved_rows AS(
	DELETE FROM orders o
	WHERE 
		EXTRACT(MONTH FROM o.orf_datetime) = 5
	RETURNING * 
)
INSERT INTO ord5
SELECT * FROM ord5