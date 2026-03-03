import 'package:flutter/material.dart';

import '../widgets/transaction_item.dart';
import 'login_screen.dart';
import 'payment_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Uygulama genelinde tutarlılık olması için renkleri burada sabit tutuyorum.
  static const Color _primary = Color(0xFF3D31B4);
  static const Color _bg = Color(0xFFF0F2F8);

  int _selectedTab = 0; // Alt menüdeki geçişleri kontrol etmek için index tutuyorum.
  double _balance = 3469.52; // Simülasyon amaçlı başlangıç bakiyesi.

  // Ödeme ekranına giderken verileri buradan yolluyorum.
  void _openPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          amount: 450.00,
          initialCardHolder: 'Mustafa Kaya',
          initialCardNumber: '4756 1234 5678 9018',
          initialExpiry: '12/30',
          onPaymentSuccess: (amount) {
            // Ödeme başarılı dönerse bakiyeyi anlık güncelliyoruz.
            setState(() => _balance += amount);
          },
        ),
      ),
    );
  }

  // Para çekme işlemi için asenkron bir yapı kurdum, çünkü kullanıcıdan veri gelmesini bekliyoruz.
  Future<void> _openWithdraw() async {
    final amount = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => const _WithdrawScreen()),
    );
    
    // Kullanıcı vazgeçip geri dönerse veya tutar girmezse işlem yapma.
    if (!mounted || amount == null) return;

    // Bakiyeden fazla çekim yapılmasını engellemek için basit bir kontrol.
    if (amount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yetersiz bakiye.')));
      return;
    }

    setState(() => _balance -= amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Çekim tamamlandı: TRY ${amount.toStringAsFixed(2)}')),
    );
  }

  // Henüz hazır olmayan özellikler için bilgilendirme penceresi açan genel bir fonksiyon.
  void _showFeature(String title, String message) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _InfoScreen(title: title, message: message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        // Notch (çentik) ve alt bar ile çakışmaması için SafeArea kullandım.
        bottom: false,
        child: IndexedStack(
          // Sekmeler arası geçişte sayfa durumunu (scroll pozisyonu vb.) korumak için IndexedStack tercih ettim.
          index: _selectedTab,
          children: [
            _buildHome(),
            _buildTransactions(),
            _buildMessages(),
            _buildSettings(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- ANA SAYFA GÖRÜNÜMÜ ---
  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // Kaydırma hissi daha akıcı olsun diye iOS tarzı efekt verdim.
      child: Column(
        children: [
          // Üstteki mavi panel ve kullanıcı bilgileri.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, Color(0xFF5C51D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(42)),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.26),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hoş geldin,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('Mustafa Kaya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
                const Spacer(),
                const _NotificationBadge(),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _buildCard(), // Kredi kartı tasarımını temiz kod için ayrı metoda taşıdım.
          ),
          const SizedBox(height: 34),
          // Uygulama aksiyon butonları.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Column içinde olduğu için scroll'u kapattım.
              crossAxisCount: 3,
              mainAxisSpacing: 26,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildAction(Icons.account_balance_wallet_rounded, 'Hesaplar', const Color(0xFF7E7BFF), () {
                  _showFeature('Hesaplar', 'Tüm kartlarınız ve hesap hareketleriniz burada listelenir.');
                }),
                _buildAction(Icons.swap_horizontal_circle_rounded, 'Transfer', const Color(0xFF58B0FF), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const _TransferScreen()));
                }),
                _buildAction(Icons.atm_rounded, 'Para çek', const Color(0xFF7D65F8), _openWithdraw),
                _buildAction(Icons.payment_rounded, 'Ödeme Yap', const Color(0xFF4FC7C7), _openPayment),
                _buildAction(Icons.receipt_long_rounded, 'Faturalar', const Color(0xFF8C8AFD), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const _BillsScreen()));
                }),
                _buildAction(Icons.savings_rounded, 'Birikim', const Color(0xFF5A9BFF), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const _SavingsScreen()));
                }),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- BANKA KARTI TASARIMI ---
  Widget _buildCard() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Kartın havada durma efektini bu shadow ile sağladım.
          BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 25, offset: const Offset(0, 15)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          children: [
            // Kartın arka planındaki dekoratif daire detayı.
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mustafa Kaya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      Icon(Icons.contactless, color: Colors.white, size: 28),
                    ],
                  ),
                  const Text('4756  **** **** 9018', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dinamik bakiye buraya basılıyor.
                      Text('TRY ${_balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      const Text('VISA', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 22)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- IZGARA BUTONLARI (ACTION) ---
  Widget _buildAction(IconData icon, String label, Color accent, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // İkonun altındaki hafif renkli parlama efekti.
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [accent.withValues(alpha: 0.28), accent.withValues(alpha: 0.0)]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: accent.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 10)),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(8, 8)),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.white, accent.withValues(alpha: 0.08)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: accent.withValues(alpha: 0.18)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                        ),
                        Icon(icon, color: _primary, size: 31),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2D2D5E))),
        ],
      ),
    );
  }

  // --- İŞLEM GEÇMİŞİ LİSTESİ ---
  Widget _buildTransactions() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: const [
        Text('İşlem Geçmişi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        // Tekrar kullanılabilir widget'ı burada çağırıyorum.
        TransactionItem(title: 'Market Alışverişi', date: '27 Feb 2026', amount: '- TRY 385.40', icon: Icons.shopping_bag_outlined, iconColor: Colors.redAccent),
        TransactionItem(title: 'Maaş Ödemesi', date: '26 Feb 2026', amount: '+ TRY 22,000.00', icon: Icons.account_balance_wallet_outlined, iconColor: Colors.green),
        TransactionItem(title: 'Elektrik Faturası', date: '24 Feb 2026', amount: '- TRY 640.00', icon: Icons.flash_on_outlined, iconColor: Colors.orange),
      ],
    );
  }

  // --- BİLDİRİM SAYFASI ---
  Widget _buildMessages() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        const Text('Bildirimler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _messageCard('Ödeme Başarılı', 'Telefon faturası ödemeniz tamamlandı.'),
        _messageCard('Güvenlik', 'Son giriş: Gaziantep / Android Cihaz.'),
        _messageCard('Kampanya', 'Nakit iade kampanyası aktif!'),
      ],
    );
  }

  Widget _messageCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  // --- AYARLAR SAYFASI ---
  Widget _buildSettings() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        const Text('Ayarlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _settingTile(Icons.person_outline, 'Profil Bilgileri', 'Hesap bilgilerini düzenle'),
        _settingTile(Icons.lock_outline, 'Güvenlik', 'Şifre ve cihaz güvenliği'),
        _settingTile(Icons.help_outline, 'Destek', 'Canlı destek ve yardım merkezi'),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              // Çıkış yapınca geri dönmeyi engellemek için Navigator.pushAndRemoveUntil kullandım.
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Çıkış Yap', style: TextStyle(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: _primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title açıldı.')));
        },
      ),
    );
  }

  // --- ALT NAVİGASYON BAR ---
  Widget _buildBottomNav() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(icon: Icons.home_filled, index: 0),
          _buildNavIcon(icon: Icons.history_rounded, index: 1),
          _buildNavIcon(icon: Icons.notifications_none_rounded, index: 2),
          _buildNavIcon(icon: Icons.settings_outlined, index: 3),
        ],
      ),
    );
  }

  Widget _buildNavIcon({required IconData icon, required int index}) {
    final isActive = _selectedTab == index;
    final color = isActive ? const Color(0xFF6A4BF7) : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

// --- BİLDİRİM BALONU (BADGE) ---
class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 32),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

// --- ÖZELLİK DETAY EKRANI ---
class _InfoScreen extends StatelessWidget {
  final String title;
  final String message;

  const _InfoScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Text(message, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

// --- TRANSFER EKRANI ---
class _TransferScreen extends StatefulWidget {
  const _TransferScreen();

  @override
  State<_TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<_TransferScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için controller'ları dispose etmeyi unutmamak lazım.
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Alıcı', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Tutar', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Basit bir boş kontrolü yapıp kullanıcıyı uyarıyorum.
                  if (_nameController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alıcı ve tutar zorunlu.')));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer talimatı alındı.')));
                  Navigator.pop(context);
                },
                child: const Text('Transfer Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PARA ÇEKME EKRANI ---
class _WithdrawScreen extends StatefulWidget {
  const _WithdrawScreen();

  @override
  State<_WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<_WithdrawScreen> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para Çek')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Çekilecek tutar', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Virgül ile girilen sayıları noktaya çevirip double'a parse ediyorum.
                  final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli tutar girin.')));
                    return;
                  }
                  // Girilen tutarı bir önceki ekrana geri gönderiyorum.
                  Navigator.pop(context, amount);
                },
                child: const Text('Onayla'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- FATURA ÖDEME LİSTESİ ---
class _BillsScreen extends StatelessWidget {
  const _BillsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faturalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _billTile(context, 'Elektrik', 640.00),
          _billTile(context, 'İnternet', 410.00),
          _billTile(context, 'Su', 185.00),
        ],
      ),
    );
  }

  Widget _billTile(BuildContext context, String title, double amount) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text(title),
        subtitle: Text('TRY ${amount.toStringAsFixed(2)}'),
        trailing: TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title faturası ödendi.')));
          },
          child: const Text('Öde'),
        ),
      ),
    );
  }
}

// --- BİRİKİM HEDEFLERİ ---
class _SavingsScreen extends StatelessWidget {
  const _SavingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birikim')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hedef: Tatil Fonu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // İlerlemeyi görselleştirmek için progress bar kullandım.
            ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.62, minHeight: 10)),
            const SizedBox(height: 10),
            const Text('TRY 31,000 / TRY 50,000'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Birikim hesabınıza TRY 500 eklendi.')));
                },
                child: const Text('TRY 500 Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
