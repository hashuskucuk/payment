import 'package:flutter/material.dart';

/// Kullanıcı kayıt işlemlerinin gerçekleştirildiği ekran bileşeni.
/// Modern bir üst bar tasarımı ve aşağıdan yukarıya açılan beyaz form alanına sahiptir.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Form üzerindeki tüm validasyonları ve durumu kontrol eden anahtar.
  final _formKey = GlobalKey<FormState>();
  
  /// Kullanıcı verilerini toplamak ve işlemek için kullanılan kontrolcüler.
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Kullanıcı sözleşme onayı ve işlem devam ediyor (loading) durumu takibi.
  bool _isAgreed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    /// Memory leak (bellek sızıntısı) önlemek için kontrolcüler serbest bırakılır.
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Kayıt işlemini başlatan asenkron metot.
  /// Form validasyonu, sözleşme onayı ve sahte bir API gecikmesi içerir.
  Future<void> _submit() async {
    // Önce form üzerindeki tüm TextFormField'ların validator metotlarını çalıştırır.
    if (!_formKey.currentState!.validate()) return;
    
    // Sözleşme onayı kontrolü (İş mantığı gereği zorunludur).
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devam etmek için sözleşmeyi onaylayın.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // API simülasyonu (Ajanın test etmesi için eklenen gecikme).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarılı. Şimdi giriş yapabilirsiniz.')),
    );

    // Başarılı kayıttan sonra bir önceki ekrana (genelde login) döner.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Kurumsal kimliğin ana mor tonu.
    const primary = Color(0xFF3D31B4);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Kayıt Ol', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          // Modern, yuvarlatılmış üst köşeler.
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Yeni hesap oluşturun', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                
                // İsim soyisim girişi ve boşluk/format kontrolü.
                _buildInput(
                  controller: _nameController,
                  label: 'Ad Soyad',
                  hint: 'Örnek: Mustafa Kaya',
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ad soyad zorunludur';
                    if (v.trim().split(' ').length < 2) return 'Ad ve soyad girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Telefon girişi: Sadece rakam kabul eden klavye tipiyle.
                _buildInput(
                  controller: _phoneController,
                  label: 'Telefon',
                  hint: '05xxxxxxxxx',
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) return 'Geçerli telefon girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Şifre girişi: Karakter gizleme özelliği aktif.
                _buildInput(
                  controller: _passwordController,
                  label: 'Şifre',
                  hint: 'En az 6 karakter',
                  icon: Icons.lock_outline,
                  isPass: true,
                  validator: (v) {
                    if ((v ?? '').length < 6) return 'Şifre en az 6 karakter olmalı';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                
                // Gizlilik Politikası Onay Kutusu
                Row(
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      onChanged: (value) => setState(() => _isAgreed = value ?? false),
                      activeColor: primary,
                    ),
                    const Expanded(
                      child: Text(
                        'Koşulları ve gizlilik politikasını kabul ediyorum.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Kayıt Butonu: İşlem sürerken CircularProgressIndicator gösterir.
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tekrarlanan giriş alanlarını yöneten yardımcı widget metodu.
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPass = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF3D31B4)),
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
