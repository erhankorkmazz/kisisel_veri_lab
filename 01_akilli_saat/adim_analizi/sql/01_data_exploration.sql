 -- Ham veriyi kontrol et
SELECT TOP 10 *
FROM dbo.mi_fitness_raw;

-- Import sonrası satır sayısını doğrula
SELECT COUNT(*) AS total_rows
FROM dbo.mi_fitness_raw;

