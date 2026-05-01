import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Kullanım Koşulları'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          '''DOWNAPP KULLANIM KOŞULLARI

Son Güncelleme: 11 Nisan 2026

1. GENEL HÜKÜMLER
DownApp platformunu kullanarak bu koşulları kabul etmiş olursunuz. Platform, kullanıcılara uygulama keşfetme, indirme, paylaşma ve geliştirme imkânı sunan bir dijital platformdur.

2. HESAP OLUŞTURMA
• Hesap oluşturmak için 16 yaşından büyük olmanız gerekmektedir.
• Bilgilerinizin doğru ve güncel olması sizin sorumluluğunuzdadır.
• Hesabınızın güvenliğinden siz sorumlusunuz.

3. KULLANICI YÜKÜMLÜLÜKLERİ
• Yasadışı içerik yüklemek yasaktır.
• Diğer kullanıcılara taciz, spam veya kötüye kullanım yasaktır.
• Zararlı yazılım yüklemek yasaktır.
• Telif haklarına saygı gösterilmelidir.

4. GELİŞTİRİCİ YÜKÜMLÜLÜKLERİ
• Yüklenen uygulamaların güvenliği geliştiricinin sorumluluğundadır.
• Uygulamalar virüs taramasından geçirilir ve admin onayına tabidir.
• Yanıltıcı açıklama veya görseller kullanılamaz.

5. İÇERİK POLİTİKASI
• Müstehcen, şiddete teşvik eden veya nefret söylemi içeren içerikler yasaktır.
• Platform, uygun bulmadığı içerikleri kaldırma hakkını saklı tutar.

6. FİKRİ MÜLKİYET
• Platformda paylaşılan tüm içeriklerin fikri mülkiyet hakları sahibine aittir.
• DownApp, içeriklerin platformda gösterilmesi için lisans hakkına sahiptir.

7. SORUMLULUK SINIRLAMASI
• DownApp, kullanıcıların yüklediği uygulamalardan doğan zararlardan sorumlu değildir.
• Platform "olduğu gibi" sunulmaktadır.

8. HESAP FESHİ
• DownApp, koşulları ihlal eden hesapları askıya alma veya silme hakkını saklı tutar.
• Kullanıcılar hesaplarını istedikleri zaman silebilir.

9. DEĞİŞİKLİKLER
• Bu koşullar önceden haber verilmeksizin güncellenebilir.
• Güncellemeler yayınlandığında platformu kullanmaya devam etmeniz kabul anlamına gelir.

İletişim: support@downapp.com
''',
          style: TextStyle(height: 1.6),
        ),
      ),
    );
  }
}
