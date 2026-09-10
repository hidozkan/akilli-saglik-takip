# Akıllı Sağlık Takip Sistemi

<p align="center">
  <strong>Flutter ile geliştirilen, nabız ve tansiyon takibini kolaylaştıran mobil sağlık uygulaması</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI">
  <img src="https://img.shields.io/badge/OpenAI_API-412991?style=for-the-badge&logo=openai&logoColor=white" alt="OpenAI API">
</p>

## Proje hakkında

Akıllı Sağlık Takip Sistemi, kullanıcıların nabız ve tansiyon ölçümlerini kaydetmesine, geçmiş verilerini görüntülemesine ve ölçüm sonuçları üzerinden genel risk bilgilendirmesi almasına yardımcı olan bir mobil uygulama projesidir.

Bu proje, Sistem Analizi ve Tasarım dersi kapsamında gereksinim analizi, UML modelleme, veri tasarımı, mobil uygulama geliştirme ve temel backend entegrasyonu konularını birlikte uygulamak amacıyla geliştirilmiştir.

> Uygulama tıbbi teşhis koymaz, ilaç veya tedavi önermez. Sağlık bilgilerinin değerlendirilmesinde doktor görüşü esas alınmalıdır. Ciddi belirtilerde acil sağlık hizmetlerine başvurulmalıdır.

## Temel özellikler

- Kullanıcı kayıt ve giriş işlemleri
- Firebase Authentication ile oturum yönetimi
- Nabız ve tansiyon ölçümlerinin kaydedilmesi
- Ölçüm geçmişinin görüntülenmesi
- Akıllı saat veya tansiyon cihazından veri alma akışı için cihaz bağlantısı kontrolü
- Ölçüm sonuçlarının analiz edilmesi
- Risk seviyesine göre bilgilendirme ve uyarı oluşturulması
- Doktorun hasta verilerini ve önerilerini görüntüleyebilmesi
- Yerel bildirim desteği
- Nabız ve tansiyon bilgilerini dikkate alan Türkçe AI sağlık asistanı
- RAG yaklaşımıyla sağlık bilgilendirme metinlerinden ilgili içeriklerin seçilmesi

## Sistem akışı

Kullanıcı giriş yaptıktan sonra nabız veya tansiyon ölçümünü başlatır. Sistem cihaz bağlantısını kontrol eder, ölçüm verisini alır ve veritabanına kaydeder. Daha sonra ölçüm verisi analiz edilir. Risk görülmezse normal durum mesajı gösterilir; risk görülürse kullanıcıya uyarı, öneri ve gerektiğinde doktor yönlendirmesi sunulur.

```text
Kullanıcı → Giriş → Ölçüm başlatma → Cihaz kontrolü
                         ↓
                 Veri kaydetme
                         ↓
                  Veri analizi
                         ↓
             Risk durumu ve bilgilendirme
```

## Kullanılan teknolojiler

| Katman | Teknolojiler |
| --- | --- |
| Mobil uygulama | Flutter, Dart |
| Kimlik doğrulama | Firebase Authentication |
| Yerel veri saklama | SharedPreferences |
| HTTP iletişimi | Dart HTTP |
| Bildirimler | Flutter Local Notifications |
| Backend | Python, FastAPI, Uvicorn |
| AI entegrasyonu | OpenAI API |
| Bilgi erişimi | RAG veri dosyası ve anahtar kelime tabanlı ilgili içerik seçimi |

## Proje yapısı

```text
.
├── lib/
│   └── main.dart                 # Mobil uygulama ekranları, modeller ve servisler
├── backend/
│   ├── main.py                   # FastAPI sağlık asistanı servisi
│   ├── rag_data.txt              # Bilgilendirme ve güvenli yanıt kuralları
│   ├── requirements.txt          # Python bağımlılıkları
│   └── .env.example              # Yerel API anahtarı şablonu
├── assets/                       # Uygulama logosu ve görseller
├── docs/images/                  # UML diyagramları ve uygulama ekranları
├── android/                      # Android platform dosyaları
├── ios/                          # iOS platform dosyaları
├── web/                          # Web platform dosyaları
├── pubspec.yaml                  # Flutter bağımlılıkları
└── README.md
```

## Sistem analizi ve tasarım çalışmaları

Proje kapsamında aşağıdaki analiz ve tasarım çalışmaları hazırlandı:

- Kullanıcı, doktor ve akıllı saat/tansiyon cihazı aktörlerini içeren kullanım durumu diyagramı
- Kullanıcı, doktor, cihaz, sağlık verisi, veri analizi, risk analizi, uyarı ve öneri sınıflarını gösteren sınıf diyagramı
- Kullanıcı, sistem, cihaz ve veritabanı arasındaki ölçüm veri akışını gösteren sıralama diyagramı
- Giriş, nabız/tansiyon ölçümü ve risk analizi için aktivite diyagramları
- Kullanıcı, sağlık verisi, analiz, risk, uyarı, öneri ve doktor tablolarını gösteren varlık-ilişki diyagramı

## Uygulama ekranları

Projeden seçilmiş uygulama ekranları:

| Ekran | Önizleme |
| --- | --- |
| Uygulama ekranı 1 | ![Uygulama ekranı 1](docs/images/app-screen-01.jpg) |
| Uygulama ekranı 2 | ![Uygulama ekranı 2](docs/images/app-screen-02.jpg) |
| Uygulama ekranı 3 | ![Uygulama ekranı 3](docs/images/app-screen-03.jpg) |
| Uygulama ekranı 4 | ![Uygulama ekranı 4](docs/images/app-screen-04.jpg) |
| Uygulama ekranı 5 | ![Uygulama ekranı 5](docs/images/app-screen-05.jpg) |
| Uygulama ekranı 6 | ![Uygulama ekranı 6](docs/images/app-screen-06.jpg) |
| Uygulama ekranı 7 | ![Uygulama ekranı 7](docs/images/app-screen-07.jpg) |
| Uygulama ekranı 8 | ![Uygulama ekranı 8](docs/images/app-screen-08.jpg) |
| Uygulama ekranı 9 | ![Uygulama ekranı 9](docs/images/app-screen-09.jpg) |
| Uygulama ekranı 10 | ![Uygulama ekranı 10](docs/images/app-screen-10.jpg) |
| Uygulama ekranı 11 | ![Uygulama ekranı 11](docs/images/app-screen-11.jpg) |
| Uygulama ekranı 12 | ![Uygulama ekranı 12](docs/images/app-screen-12.jpg) |
| Uygulama ekranı 13 | ![Uygulama ekranı 13](docs/images/app-screen-13.jpg) |
| Uygulama ekranı 14 | ![Uygulama ekranı 14](docs/images/app-screen-14.jpg) |
| Uygulama ekranı 15 | ![Uygulama ekranı 15](docs/images/app-screen-15.jpg) |

## Diyagramlar

### Kullanım durumu diyagramı

![Akıllı Sağlık Takip Sistemi kullanım durumu diyagramı](docs/images/use-case-diagram.jpg)

### Sınıf diyagramı

![Akıllı Sağlık Takip Sistemi sınıf diyagramı](docs/images/class-diagram.jpg)

### Varlık-ilişki diyagramı

![Akıllı Sağlık Takip Sistemi varlık ilişki diyagramı](docs/images/entity-relationship-diagram.jpg)

### Giriş aktivitesi

![Giriş aktivite diyagramı](docs/images/activity-login.jpg)

### Nabız ve tansiyon ölçümü aktivitesi

![Nabız ve tansiyon ölçümü aktivite diyagramı](docs/images/activity-pulse-measurement.jpg)

### Risk analizi aktivitesi

![Risk analizi aktivite diyagramı](docs/images/activity-risk-analysis.jpg)

### Giriş sıralama diyagramı

![Giriş sıralama diyagramı](docs/images/sequence-login.jpg)

### Ölçüm ve veri kaydetme sıralama diyagramı

![Ölçüm ve veri kaydetme sıralama diyagramı](docs/images/sequence-pulse-measurement.jpg)

### Risk analizi ve uyarı sıralama diyagramı

![Risk analizi ve uyarı sıralama diyagramı](docs/images/sequence-risk-analysis.jpg)

## Backend kurulumu

Backend klasörüne geçip Python sanal ortamı oluşturun:

```bash
cd backend
python -m venv .venv
```

Windows:

```powershell
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Linux/macOS:

```bash
source .venv/bin/activate
pip install -r requirements.txt
```

`.env.example` dosyasını `.env` olarak kopyalayın ve OpenAI anahtarınızı yalnızca yerel ortamda tanımlayın:

```env
OPENAI_API_KEY=your_api_key_here
```

Backend’i çalıştırmak için:

```bash
uvicorn main:app --reload
```

## Flutter kurulumu

Flutter SDK ve Dart `^3.11.0` ile uyumlu bir sürüm kurulduktan sonra:

```bash
flutter pub get
flutterfire configure
flutter run
```

`flutterfire configure` komutu, kendi Firebase projen için gerekli `lib/firebase_options.dart` dosyasını oluşturur. Bu dosya ve platforma özel Firebase yapılandırmaları güvenlik nedeniyle repoya dahil edilmemiştir.

## Güvenlik ve gizlilik

- Gerçek API anahtarları, `.env` dosyası ve Firebase yapılandırma dosyaları repoya eklenmez.
- Kullanıcı sağlık verileri hassas kişisel veriler olarak ele alınmalıdır.
- Üretim ortamında kimlik doğrulama, yetkilendirme, veri şifreleme ve erişim kuralları ayrıca yapılandırılmalıdır.
- OpenAI anahtarı mobil uygulamaya gömülmemeli, backend ortamında saklanmalıdır.
- Uygulama çıktıları bilgilendirme amaçlıdır ve doktor değerlendirmesinin yerini tutmaz.

## Gelecek geliştirmeler

- Gerçek akıllı saat ve tansiyon cihazı entegrasyonu
- Ölçüm trendlerinin grafiklerle gösterilmesi
- Doktor ve hasta için ayrı yetkilendirme seviyeleri
- Daha kapsamlı risk değerlendirme modeli
- Üretim ortamı için güvenli veritabanı ve dağıtım yapılandırması

## Lisans

Bu proje eğitim ve portföy amaçlı geliştirilmiştir.
