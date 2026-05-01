import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Gizlilik Politikası'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''DOWNAPP GİZLİLİK POLİTİKASI VE KVKK AYDINLATMA METNİ

Son Güncelleme: 11 Nisan 2026

1. VERİ SORUMLUSU
DownApp olarak kişisel verilerinizin güvenliğine büyük önem veriyoruz. Bu politika, 6698 Sayılı Kişisel Verilerin Korunması Kanunu (KVKK) ve Avrupa Genel Veri Koruma Tüzüğü (GDPR) kapsamında hazırlanmıştır.

2. TOPLANAN VERİLER
• Kimlik Bilgileri: Ad soyad, kullanıcı adı, email adresi
• İletişim Bilgileri: Email adresi
• Profil Bilgileri: Profil fotoğrafı, biyografi, web sitesi
• Kullanım Verileri: İndirme geçmişi, favoriler, yorumlar
• Cihaz Bilgileri: Cihaz modeli, işletim sistemi versiyonu
• Konum Bilgileri: Ülke (IP tabanlı, yaklaşık)

3. VERİLERİN İŞLENME AMAÇLARI
• Hesap oluşturma ve yönetimi
• Hizmetlerimizi sunma ve iyileştirme
• Bildirimlerin gönderilmesi
• Güvenlik ve dolandırıcılık önleme
• Yasal yükümlülüklerin yerine getirilmesi

4. VERİLERİN PAYLAŞIMI
• Kişisel verileriniz üçüncü taraflarla satılmaz.
• Yalnızca yasal zorunluluklar ve hizmet sunumu için güvenilir iş ortaklarıyla paylaşılabilir.
• Firebase (Google) altyapısı kullanılmaktadır.

5. VERİ GÜVENLİĞİ
• Verileriniz şifreli olarak saklanır.
• Firebase güvenlik kuralları ile korunur.
• Düzenli güvenlik denetimleri yapılır.

6. ÇEREZ POLİTİKASI
• Platform, gerekli çerezleri kullanır.
• Analitik çerezleri için onayınız alınır.

7. HAKLARINIZ (KVKK Madde 11 / GDPR)
• Verilerinize erişim hakkı
• Verilerinizin düzeltilmesini talep hakkı
• Verilerinizin silinmesini talep hakkı (unutulma hakkı)
• Veri taşınabilirliği hakkı
• İşlemeye itiraz hakkı
• Otomatik karar almaya itiraz hakkı

8. VERİ SAKLAMA SÜRESİ
• Hesap aktif olduğu sürece veriler saklanır.
• Hesap silme sonrası 30 gün içinde tüm veriler kalıcı olarak silinir.

9. İLETİŞİM
Veri koruma ile ilgili talepleriniz için:
Email: privacy@downapp.com

Bu politikayı kabul ederek verilerinizin yukarıda belirtilen şekilde işlenmesine onay vermiş olursunuz.
''',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}
