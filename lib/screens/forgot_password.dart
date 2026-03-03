import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Formun doğruluğunu kontrol etmek ve hata mesajlarını yönetmek için GlobalKey kullanıyorum.
  final _formKey = GlobalKey<FormState>();
  
  // Kullanıcının girdiği telefon numarasını metin olarak okumak için controller tanımladım.
  final _phoneController = TextEditingController();
  
  // Kod gönderilirken butonun üzerine bir yükleme simgesi koymak için kullandığım durum değişkeni.
  bool _isLoading = false;

  @override
  void dispose() {
    // Hafıza sızıntısını (memory leak) önlemek için ekran kapandığında controller'ı temizliyorum.
    _phoneController.dispose();
    super.dispose();
  }

  // Kod gönderme butonuna tıklandığında tetiklenen asenkron fonksiyon.
  Future<void> _sendCode() async {
    // Eğer telefon numarası geçerli formatta değilse işlemi durdurur ve hatayı ekranda gösterir.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Gerçek bir API isteğini simüle etmek için 1 saniyelik yapay bir gecikme ekledim.
    await Future.delayed(const Duration(seconds: 1));

    // Eğer kullanıcı beklerken geri tuşuna basıp ekrandan çıktıysa, setState yapıp hata almamak için kontrol ekledim.
    if (!mounted) return;
    setState(() => _isLoading = false);

    // İşlem başarılı olduğunda kullanıcıya geri bildirim veriyorum.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doğrulama kodu gönderildi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Şifremi Unuttum'),
        foregroundColor: Colors.black, // Başlık rengini tasarım bütünlüğü için siyah yaptım.
        backgroundColor: Colors.white,
        elevation: 0, // AppBar'ın altındaki gölgeyi kaldırarak daha modern ve düz bir görünüm elde ettim.
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), // İçeriğin kenarlardan nefes alması için standart bir boşluk bıraktım.
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Metinleri sola hizalamak için kullandım.
            children: [
              const Text('Telefon numaranızı girin', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone, // Kullanıcıya doğrudan rakam klavyesini açarak kolaylık sağlıyorum.
                validator: (v) {
                  // Girilen metindeki rakam olmayan her şeyi (boşluk, tire vb.) temizleyip uzunluk kontrolü yapıyorum.
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 10) return 'Geçerli telefon numarası girin';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '05xxxxxxxxx',
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA), // Arka planı hafif gri yaparak giriş alanını belirginleştirdim.
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none, // Kenarlıkları kaldırıp sadece radius vererek modern bir kutu yaptım.
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Numaranıza tek kullanımlık kod göndereceğiz.',
                style: TextStyle(color: Color(0xFF3D31B4), fontSize: 12),
              ),
              const SizedBox(height: 28),
              // Butonun tüm genişliği kaplaması için SizedBox ile sarmaladım.
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  // İşlem devam ederken (loading) butonu pasif hale getirerek mükerrer istekleri önlüyorum.
                  onPressed: _isLoading ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D31B4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          // Yüklenme sırasında dönen beyaz bir halka gösteriyorum.
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Kod Gönder', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
