class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-posta adresi boş bırakılamaz';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Geçerli bir e-posta adresi giriniz';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Şifre boş bırakılamaz';
    if (value.length < 6) return 'Şifre en az 6 karakter olmalıdır';
    return null;
  }

  static String? validateCardHolder(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) return 'Kart sahibi adı zorunludur';

    if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(trimmedValue)) {
      return 'Kart sahibi sadece harf içermelidir';
    }

    if (trimmedValue.split(RegExp(r'\s+')).length < 2) {
      return 'Ad ve soyad giriniz';
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Kart numarası girmelisiniz';

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) return 'Kart numarası 16 hane olmalıdır';
    return null;
  }

  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'SKT giriniz';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
      return 'Geçerli format AA/YY olmalı';
    }

    final parts = value.split('/');
    final month = int.tryParse(parts[0]) ?? 0;
    final yearTwoDigit = int.tryParse(parts[1]) ?? 0;

    if (month < 1 || month > 12) return 'Ay 01-12 arası olmalı';

    final now = DateTime.now();
    final currentYearTwoDigit = now.year % 100;
    if (yearTwoDigit < currentYearTwoDigit) {
      return 'Geçmiş bir tarih girilemez';
    }
    if (yearTwoDigit == currentYearTwoDigit && month < now.month) {
      return 'Geçmiş bir tarih girilemez';
    }

    return null;
  }

  static String? validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'CVV giriniz';
    if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) return 'CVV 3 hane olmalı';
    return null;
  }
}
