 -- Ham veriyi kontrol et
-- Veri 6 sütundan oluşmaktadır:
-- Uid, Sid, Key, Time, Value, UpdateTime.
-- Value alanında JSON formatında ölçüm bilgileri tutulmaktadır.
SELECT TOP 10 *
FROM dbo.mi_fitness_raw;
----------------------------------------------------------------------------
-- Import sonrası satır sayısını doğrula
-- Sonuç: 628,770 kayıt
SELECT COUNT(*) AS total_rows
FROM dbo.mi_fitness_raw;
----------------------------------------------------------------------------
-- Veri havuzundaki ölçüm türlerini ve kayıt sayılarını incele
-- Sonuç:
-- Veri setinde 20 farklı ölçüm türü bulunmaktadır.
-- En fazla kayıt:
-- heart_rate : 189,456
-- body_momentum : 163,736
-- light_sensitivity_value : 163,736
-- calories : 63,833
-- Bu proje için kullanılacak 'steps' türünde
-- toplam 16,732 kayıt bulunmaktadır.

SELECT [Key], COUNT(*) AS kayit_sayisi
FROM dbo.mi_fitness_raw
GROUP BY [Key]
ORDER BY kayit_sayisi DESC;
----------------------------------------------------------------------------
-- Yalnızca adım (steps) türündeki kayıtlardan
-- ilk 20 gözlemi incele.
-- Sonuç:
-- Adım kayıtları ayrı satırlar halinde tutulmaktadır.
-- Value sütununun JSON formatında olduğu görülmüştür.
-- JSON içerisinde şu alanlar bulunmaktadır: time, steps, distance, calories
-- Örnek: {"time":1787206980,"steps":14,"distance":9,"calories":...}
-- Dolayısıyla sonraki aşamada JSON içerisindeki, değişkenler ayrı SQL sütunlarına ayrıştırılacaktır.

SELECT TOP 20 *
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';
---------------------------------------------------------------------------

-- Adım kayıtlarının Value sütunundaki JSON yapısını ayrıştır.
-- steps, distance ve calories değerlerini ayrı sütunlarda incele.

SELECT TOP 20
    [Time],
    JSON_VALUE([Value], '$.steps') AS steps,
    JSON_VALUE([Value], '$.distance') AS distance,
    JSON_VALUE([Value], '$.calories') AS calories
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- Sonuç:
-- JSON_VALUE fonksiyonu kullanılarak Value sütunundaki
-- steps, distance ve calories alanları başarıyla ayrıştırıldı.
-- Örnek:
-- Time         steps   distance   calories
-- 1787206980   14      9          2
-- Bu aşamada JSON_VALUE tarafından döndürülen değerler
-- metinsel (nvarchar) biçimdedir.
-- Sonraki aşamada analiz yapılabilmesi için bu alanlar
-- sayısal veri tiplerine dönüştürülecektir.










