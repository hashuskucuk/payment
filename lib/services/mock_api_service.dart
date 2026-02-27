import '../utils/validators.dart';

class MockApiService {
  const MockApiService();

  Map<String, String?> validateLogin({
    required String email,
    required String password,
  }) {
    return {
      'email': Validators.validateEmail(email),
      'password': Validators.validatePassword(password),
    };
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return email.isNotEmpty && password.length >= 6;
  }

  Map<String, String?> validatePayment({
    required String cardHolder,
    required String cardNumberDigits,
    required String expiry,
    required String cvv,
  }) {
    return {
      'cardHolder': Validators.validateCardHolder(cardHolder),
      'cardNumber': Validators.validateCardNumber(cardNumberDigits),
      'expiry': Validators.validateExpiry(expiry),
      'cvv': Validators.validateCvv(cvv),
    };
  }

  Future<void> processPayment() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
