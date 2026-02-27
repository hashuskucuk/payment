import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payment/app.dart';

void main() {
  testWidgets('Login screen renders expected fields', (WidgetTester tester) async {
    await tester.pumpWidget(const PaymentApp());

    expect(find.text('Giriş'), findsOneWidget);
    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Giriş Yap'), findsOneWidget);
  });

  testWidgets('Login shows validation errors for invalid inputs', (WidgetTester tester) async {
    await tester.pumpWidget(const PaymentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'wrong-format');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
    await tester.pump();

    expect(find.text('Geçerli bir e-posta adresi giriniz'), findsOneWidget);
    expect(find.text('Şifre en az 6 karakter olmalıdır'), findsOneWidget);
  });

  testWidgets('Valid login navigates to dashboard after mock delay', (WidgetTester tester) async {
    await tester.pumpWidget(const PaymentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Mustafa Kaya'), findsWidgets);
    expect(find.text('Ödeme Yap'), findsOneWidget);
  });

  testWidgets('Dashboard payment action opens payment screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PaymentApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Giriş Yap'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Giriş Yap'));

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Ödeme Yap'));
    await tester.tap(find.text('Ödeme Yap'));
    await tester.pumpAndSettle();

    expect(find.text('Ödeme'), findsOneWidget);
    expect(find.text('Toplam Tutar'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ödemeyi Tamamla'), findsOneWidget);
  });
}
