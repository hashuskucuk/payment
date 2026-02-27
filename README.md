# Payment App (Flutter)

Payment App, Flutter ile gelistirilmis moduler bir mobil odeme uygulamasidir.

# Mimari Yaklaşım
Bu proje, küçük/orta ölçekli bir mobil uygulama için modüler ve bakım yapılabilir bir yapı hedeflenerek geliştirilmiştir.
Kod organizasyonu, ekranların görsel sorumlulukları ile iş kuralları ve yardımcı fonksiyonların ayrılmasına dayanır.

Bu projede state yönetimi için Flutter StatefulWidget + setState yaklaşımı kullanılmıştır.
Projenin mevcut kapsamı için en düşük karmaşıklıkla yeterli kontrol sağlar.

Not: Uygulama ölçeği büyüdüğünde bu yapı Provider, Riverpod veya Bloc gibi bir çözüme taşınarak feature bazlı state ayrıştırması yapılabilir.

 # Yönetilen başlıca state alanları
Login ekranı: loading, şifre göster/gizle
Payment ekranı: form tamamlanma durumu, loading, form controller’ları
Dashboard: aktif alt sekme, bakiye, ödeme/çekim sonrası güncellemeler

## Ozellikler

- Giriş ekranı (e-posta + şifre doğrulama)

- Şifre göster/gizle

- Asenkron giriş işlemi ve loading durumu

- Dashboard ekranı ve işlevsel alt navigasyon

- Kart bilgileri ile ödeme ekranına yönlendirme

- Kart numarası otomatik 4'lü formatlama

- Son kullanma tarihi AA/YY formatlama

- CVV maskeli ve 3 hane limiti

- Form tamamlanmadan ödeme butonu pasif

- Mock servis katmanı (MockApiService)

- Ortak bileşenler (CustomInput, CustomButton)


## Proje Yapisi

lib/
  main.dart
  app.dart
  components/
    custom_button.dart
    custom_input.dart
  screens/
    login_screen.dart
    dashboard_screen.dart
    payment_screen.dart
    register_screen.dart
    forgot_password.dart
  services/
    mock_api_service.dart
  utils/
    input_formatters.dart
    validators.dart
  widgets/
    transaction_item.dart
test/
  widget_test.dart

Klasör Yapısı
- screens/: Sayfa seviyesindeki UI ve kullanıcı akışı
- components/: Tekrar kullanılabilir ortak bileşenler (CustomInput, CustomButton)
- services/: API/işlem katmanı (MockApiService)
- utils/: Saf yardımcılar (validators, input_formatters)
- widgets/: Ekrana özel tekrar kullanılabilir küçük widgetlar (TransactionItem)
Bu ayrım sayesinde yeni ekran ekleme, validasyon güncelleme veya servis değiştirme işlemleri tek noktadan yönetilebilir.

# Servis ve İş Kuralı Ayrımı
UI katmanına iş kuralı gömmemek için:

- Validasyonlar validators.dart içinde tutulur.
- Mock asenkron işlemler mock_api_service.dart üzerinden çağrılır.
- Input formatlama (kart no, SKT) input_formatters.dart içinde yönetilir.