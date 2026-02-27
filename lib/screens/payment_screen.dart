import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/custom_button.dart';
import '../components/custom_input.dart';
import '../services/mock_api_service.dart';
import '../utils/input_formatters.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final ValueChanged<double>? onPaymentSuccess;
  final String initialCardHolder;
  final String initialCardNumber;
  final String initialExpiry;

  const PaymentScreen({
    super.key,
    required this.amount,
    this.onPaymentSuccess,
    this.initialCardHolder = '',
    this.initialCardNumber = '',
    this.initialExpiry = '',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _holderController;
  late final TextEditingController _cardController;
  late final TextEditingController _expiryController;
  final _cvvController = TextEditingController();
  final _api = const MockApiService();

  bool _isLoading = false;
  bool _isFormComplete = false;

  @override
  void initState() {
    super.initState();
    _holderController = TextEditingController(text: widget.initialCardHolder);
    _cardController = TextEditingController(text: widget.initialCardNumber);
    _expiryController = TextEditingController(text: widget.initialExpiry);

    _holderController.addListener(_updateFormState);
    _cardController.addListener(_updateFormState);
    _expiryController.addListener(_updateFormState);
    _cvvController.addListener(_updateFormState);
    _updateFormState();
  }

  @override
  void dispose() {
    _holderController
      ..removeListener(_updateFormState)
      ..dispose();
    _cardController
      ..removeListener(_updateFormState)
      ..dispose();
    _expiryController
      ..removeListener(_updateFormState)
      ..dispose();
    _cvvController
      ..removeListener(_updateFormState)
      ..dispose();
    super.dispose();
  }

  void _updateFormState() {
    final holder = _holderController.text.trim();
    final cardDigits = _cardController.text.replaceAll(RegExp(r'\D'), '');
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

    final isComplete = holder.isNotEmpty && cardDigits.length == 16 && expiry.length == 5 && cvv.length == 3;

    if (_isFormComplete != isComplete) {
      setState(() => _isFormComplete = isComplete);
    }
  }

  String _formatAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integer = parts[0];
    final decimal = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < integer.length; i++) {
      final posFromRight = integer.length - i;
      buffer.write(integer[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()},$decimal TL';
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await _api.processPayment();

    if (!mounted) return;
    setState(() => _isLoading = false);

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ödeme Başarılı'),
        content: Text('İşleminiz tamamlandı. Tutar: ${_formatAmount(widget.amount)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );

    if (!mounted) return;

    widget.onPaymentSuccess?.call(widget.amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3D31B4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ödeme'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Toplam Tutar', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(14)),
                child: Text(
                  _formatAmount(widget.amount),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
                ),
              ),
              const SizedBox(height: 18),
              CustomInput(
                controller: _holderController,
                label: 'Kart Üzerindeki İsim',
                hint: 'Ad Soyad',
                prefixIcon: Icons.person_outline,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z\s]'))],
                validator: (v) => _api.validatePayment(
                  cardHolder: v ?? '',
                  cardNumberDigits: _cardController.text,
                  expiry: _expiryController.text,
                  cvv: _cvvController.text,
                )['cardHolder'],
              ),
              const SizedBox(height: 14),
              CustomInput(
                controller: _cardController,
                label: 'Kart Numarası',
                hint: '1234 5678 1234 5678',
                prefixIcon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
                validator: (v) => _api.validatePayment(
                  cardHolder: _holderController.text,
                  cardNumberDigits: v ?? '',
                  expiry: _expiryController.text,
                  cvv: _cvvController.text,
                )['cardNumber'],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _expiryController,
                      label: 'Son Kullanma',
                      hint: 'AA/YY',
                      prefixIcon: Icons.date_range_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateFormatter()],
                      validator: (v) => _api.validatePayment(
                        cardHolder: _holderController.text,
                        cardNumberDigits: _cardController.text,
                        expiry: v ?? '',
                        cvv: _cvvController.text,
                      )['expiry'],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInput(
                      controller: _cvvController,
                      label: 'CVV',
                      hint: '***',
                      prefixIcon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                      validator: (v) => _api.validatePayment(
                        cardHolder: _holderController.text,
                        cardNumberDigits: _cardController.text,
                        expiry: _expiryController.text,
                        cvv: v ?? '',
                      )['cvv'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Ödemeyi Tamamla',
                isLoading: _isLoading,
                onPressed: (!_isFormComplete || _isLoading) ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
