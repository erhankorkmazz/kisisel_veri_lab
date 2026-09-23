# Adım Analizi

Bu projede Mi Fitness üzerinden elde ettiğim kişisel aktivite verilerini kullanarak günlük adım örüntülerimi inceliyorum.

Projenin temel amacı, gerçek bir veri seti üzerinde SQL ve Python kullanarak veri seçme, temizleme, gruplama, analiz etme ve görselleştirme pratiği yapmaktır.

## Veri Kaynağı

Veriler Mi Fitness uygulamasından dışa aktardığım kişisel sağlık ve aktivite kayıtlarından elde edilmiştir.

Ham veri setim nabız, uyku, stres, adım, kalori ve benzeri farklı sağlık ve aktivite kayıtlarını içeren toplam **628.770 gözlemden** oluşmaktadır. Bu proje kapsamında yalnızca "steps" türündeki kayıtlar kullanılmıştır.

Adım verisi  **28 Nisan 2026 – 20 Ağustos 2026** tarihleri arasında 115 farklı güne yayılmış 16.732 zaman damgalı ham kayıttan oluşmaktadır. Her kayıt gün içerisindeki belirli bir anda kaydedilen adım miktarını temsil etmektedir. Analiz sırasında bu kayıtlar günlük düzeyde birleştirilerek toplam günlük adım sayıları oluşturulacaktır.

Gizlilik nedeniyle ham veri dosyası bu depoda paylaşılmamaktadır.

## Araştırma Soruları

- Veri setinde kaç günlük adım kaydı bulunuyor?
- Günlük ortalama kaç adım atıyorum?
- En fazla ve en az adım attığım günler hangileri?
- Aylara göre günlük adım ortalamam değişiyor mu?
- Hafta içi ve hafta sonu arasında bir fark var mı?

## Kullanılan Araçlar

- SQL
- Python
- Pandas
- Matplotlib
