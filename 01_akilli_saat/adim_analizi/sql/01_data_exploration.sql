SELECT TOP 10 *
FROM dbo.mi_fitness_raw;

-- Ham veriyi kontrol ediyorum.
-- Veri 6 sütundan oluşmaktadır: Uid, Sid, Key, Time, Value, UpdateTime.
-- Value alanında JSON formatında ölçüm bilgileri tutulmaktadır.
----------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM dbo.mi_fitness_raw;

-- Import sonrası satır sayısını doğrula
-- Sonuç: 628,770 kayıt

----------------------------------------------------------------------------
SELECT [Key], COUNT(*) AS kayit_sayisi
FROM dbo.mi_fitness_raw
GROUP BY [Key]
ORDER BY kayit_sayisi DESC;

-- Veri havuzundaki ölçüm türlerini ve kayıt sayılarını inceliyorum.
-- Veri setinde 20 farklı ölçüm türü bulunmaktadır.
-- En fazla kayıt:
-- heart_rate : 189,456
-- body_momentum : 163,736
-- light_sensitivity_value : 163,736
-- calories : 63,833
-- Bu proje için kullanılacak 'steps' türünde
-- toplam 16,732 kayıt bulunmaktadır.

----------------------------------------------------------------------------
SELECT TOP 20 *
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- Yalnızca adım (steps) türündeki kayıtlardan ilk 20 gözlemi inceliyorum.
-- Adım kayıtları ayrı satırlar halinde tutulmaktadır.
-- Value sütununun JSON formatında olduğu görülmüştür.
-- JSON içerisinde şu alanlar bulunmaktadır: time, steps, distance, calories
-- Örnek: {"time":1787206980,"steps":14,"distance":9,"calories":...}
-- Dolayısıyla sonraki aşamada JSON içerisindeki, değişkenler ayrı SQL sütunlarına ayrıştırılacaktır.


---------------------------------------------------------------------------
SELECT TOP 20
    [Time],
    JSON_VALUE([Value], '$.steps') AS steps,
    JSON_VALUE([Value], '$.distance') AS distance,
    JSON_VALUE([Value], '$.calories') AS calories
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- Adım kayıtlarının Value sütunundaki JSON yapısını ayrıştırıyorum.
-- steps, distance ve calories değerlerini ayrı sütunlarda inceliyorum.
-- JSON_VALUE fonksiyonu kullanılarak Value sütunundaki steps, distance ve calories alanları başarıyla ayrıştırıldı.
-- Time         steps   distance   calories
-- 1787206980   14      9          2
-- Bu aşamada JSON_VALUE tarafından döndürülen değerler metinsel (nvarchar) biçimdedir.
-- Sonraki aşamada analiz yapılabilmesi için bu alanlar sayısal veri tiplerine dönüştürülecektir. 

---------------------------------------------------------------------------
SELECT TOP 20
    [Time],
    TRY_CONVERT(INT, JSON_VALUE([Value], '$.steps')) AS steps,
    TRY_CONVERT(INT, JSON_VALUE([Value], '$.distance')) AS distance,
    TRY_CONVERT(INT, JSON_VALUE([Value], '$.calories')) AS calories
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- JSON_VALUE ile ayrıştırılan steps, distance ve calories alanları varsayılan olarak metinsel (nvarchar) veri tipindedir.
-- Analiz ve toplulaştırma işlemleri için bu değerleri INT'e dönüştürdüm.

--------------------------------------------------------------------------------
SELECT
    COUNT(*) AS toplam_kayit,
    SUM(
        CASE
            WHEN TRY_CONVERT(INT, JSON_VALUE([Value], '$.steps')) IS NULL
            THEN 1 ELSE 0
        END
    ) AS steps_sorunlu,
    SUM(
        CASE
            WHEN TRY_CONVERT(INT, JSON_VALUE([Value], '$.distance')) IS NULL
            THEN 1 ELSE 0
        END
    ) AS distance_sorunlu,
    SUM(
        CASE
            WHEN TRY_CONVERT(INT, JSON_VALUE([Value], '$.calories')) IS NULL
            THEN 1 ELSE 0
        END
    ) AS calories_sorunlu
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- steps, distance ve calories alanlarında sayısal tipe dönüştürülemeyen kayıt olup olmadığını kontrol ettim.
-- Sonuç:
-- toplam_kayit      : 16,732
-- steps_sorunlu     : 0
-- distance_sorunlu  : 0
-- calories_sorunlu  : 0
-- Adım kayıtlarının tamamındaki steps, distance ve calories alanları sayısal tipe sorunsuz biçimde dönüştürülebilmektedir.

-----------------------------------------------------------------------------------------------
SELECT TOP 20
    [Time],
    DATEADD(
        SECOND,
        [Time],
        '1970-01-01'
    ) AS tarih_saat_utc,
    DATEADD(
        HOUR,
        3,
        DATEADD(
            SECOND,
            [Time],
            '1970-01-01'
        )
    ) AS tarih_saat_tr
FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- Time sütunu Unix timestamp formatındadır.
-- Önce 1 Ocak 1970 tarihine geçen saniyeler eklenerek UTC tarih-saat değeri oluşturdum.
-- Analiz kişisel günlük hareket örüntülerine odaklandığı için UTC değeri Türkiye yerel saatine (UTC+3) dönüştürdüm.
-- Sonuç:
-- Unix timestamp değerleri okunabilir tarih-saat biçimine başarıyla dönüştürüldü.
-- Örnek:
-- Time        UTC                      Türkiye saati
-- 1787206980  2026-08-20 06:23:00      2026-08-20 09:23:00
-- Bundan sonraki günlük ve saatlik analizlerde Türkiye yerel saati kullanılacaktır.

------------------------------------------------------------------------------------------------------------------------
SELECT TOP 20
    DATEADD(
        HOUR,
        3,
        DATEADD(SECOND, [Time], '1970-01-01')
    ) AS tarih_saat,

    CAST(
        DATEADD(
            HOUR,
            3,
            DATEADD(SECOND, [Time], '1970-01-01')
        ) AS DATE
    ) AS tarih,

    TRY_CONVERT(
        INT,
        JSON_VALUE([Value], '$.steps')
    ) AS steps

FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps';

-- Günlük analiz yapılabilmesi için yerel tarih-saat bilgisinden yalnızca tarih kısmını ayırdım.
-- Aynı zamanda JSON içerisindeki steps alanını sayısal tipe dönüştürdüm.
-- Sonuç:
-- Tarih-saat bilgisinden yalnızca gün bilgisi başarıyla ayrıştırdım.
-- Örnek:
-- tarih_saat              tarih        steps
-- 2026-08-20 09:23:00     2026-08-20   14
-- 2026-08-20 09:22:00     2026-08-20   28
-- Böylece aynı güne ait farklı adım kayıtları günlük düzeyde toplulaştırılabilir hale geldi.

-------------------------------------------------------------------------------------------------------------
SELECT
    CAST(
        DATEADD(
            HOUR,
            3,
            DATEADD(SECOND, [Time], '1970-01-01')
        ) AS DATE
    ) AS tarih,

    SUM(
        TRY_CONVERT(
            INT,
            JSON_VALUE([Value], '$.steps')
        )
    ) AS toplam_adim

FROM dbo.mi_fitness_raw
WHERE [Key] = 'steps'

GROUP BY
    CAST(
        DATEADD(
            HOUR,
            3,
            DATEADD(SECOND, [Time], '1970-01-01')
        ) AS DATE
    )

ORDER BY tarih;

-- Aynı güne ait adım kayıtlarını bir araya getirerek her gün için toplam adım sayısını hesapladım.
-- Sonuç:
-- 16,732 zaman damgalı adım kaydı günlük düzeyde birleştirildi ve 115 farklı güne ait toplam adım değerleri elde edildi.
-- Örnek:
-- tarih        toplam_adim
-- 2026-04-28   5577
-- 2026-04-29   12379
-- 2026-04-30   12189
-- Bundan sonraki analizlerde temel gözlem birimi günlük toplam adım sayısı olacaktır.

-----------------------------------------------------------------------------------------------------------------------------
WITH gunluk_adim AS (
    SELECT
        CAST(
            DATEADD(
                HOUR,
                3,
                DATEADD(SECOND, [Time], '1970-01-01')
            ) AS DATE
        ) AS tarih,

        SUM(
            TRY_CONVERT(
                INT,
                JSON_VALUE([Value], '$.steps')
            )
        ) AS toplam_adim

    FROM dbo.mi_fitness_raw
    WHERE [Key] = 'steps'

    GROUP BY
        CAST(
            DATEADD(
                HOUR,
                3,
                DATEADD(SECOND, [Time], '1970-01-01')
            ) AS DATE
        )
)

SELECT
    COUNT(*) AS gun_sayisi,
    AVG(CAST(toplam_adim AS DECIMAL(10,2))) AS ortalama_adim,
    MIN(toplam_adim) AS en_dusuk_adim,
    MAX(toplam_adim) AS en_yuksek_adim
FROM gunluk_adim;

-- Günlük toplam adım verileri üzerinden gözlem sayısı, ortalama, minimum ve maksimum değerleri hesapladım.
-- Sonuç:
-- gun_sayisi       : 115
-- ortalama_adim    : 8068.61
-- en_dusuk_adim    : 282
-- en_yuksek_adim   : 18416
-- İncelenen 115 günlük dönemde günlük ortalama yaklaşık 8,069 adım olarak hesaplandı.
-- Günlük toplamlar 282 ile 18,416 adım arasında değişmektedir.
-- Özellikle minimum değerin ait olduğu gün veri bütünlüğü ve bağlamsal koşullar açısından ayrıca incelenecektir.

-----------------------------------------------------------------------------------------------------------------------
WITH gunluk_adim AS (
    SELECT
        CAST(
            DATEADD(
                HOUR,
                3,
                DATEADD(SECOND, [Time], '1970-01-01')
            ) AS DATE
        ) AS tarih,

        SUM(
            TRY_CONVERT(
                INT,
                JSON_VALUE([Value], '$.steps')
            )
        ) AS toplam_adim

    FROM dbo.mi_fitness_raw
    WHERE [Key] = 'steps'

    GROUP BY
        CAST(
            DATEADD(
                HOUR,
                3,
                DATEADD(SECOND, [Time], '1970-01-01')
            ) AS DATE
        )
)

SELECT
    YEAR(tarih) AS yil,
    MONTH(tarih) AS ay,
    COUNT(*) AS gun_sayisi,
    SUM(toplam_adim) AS aylik_toplam_adim,
    ROUND(
        AVG(CAST(toplam_adim AS DECIMAL(10,2))),
        2
    ) AS gunluk_ortalama_adim

FROM gunluk_adim
GROUP BY
    YEAR(tarih),
    MONTH(tarih)
ORDER BY
    yil,
    ay;


-- Günlük toplam adım verilerini aylara göre grupladım.
-- Her ay için veri bulunan gün sayısını, toplam adımı ve günlük ortalama adım sayısını hesapladım.
-- Sonuç:
-- yil   ay   gun_sayisi   aylik_toplam_adim   gunluk_ortalama_adim
-- 2026   4        3              25145                8381.67
-- 2026   5       31             301139                9714.16
-- 2026   6       30             214259                7141.97
-- 2026   7       31             232301                7493.58
-- 2026   8       20             155046                7752.30
-- Veri setinde Mayıs, Haziran ve Temmuz ayları tam olaraknkapsanmaktadır. Bu üç ay içerisinde en yüksek günlüknortalama Mayıs ayında yaklaşık 9,714 adım olarak görülmüştür.
-- Haziran ayında günlük ortalama yaklaşık 7,142 adıma düşmüş,nTemmuz ayında ise yaklaşık 7,494 adıma yükselmiştir.
-- Nisan yalnızca 28-30 Nisan tarihlerini, Ağustos isen 1-20 Ağustos tarihlerini kapsamaktadır.
-- Ayrıca veri setinin ilk günü olan 28 Nisan ve son günü olan 20 Ağustos tam gün değildir. Bu nedenle özellikle Nisan vemAğustos değerleri tam ay karşılaştırması için kullanılmamalıdır.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------







