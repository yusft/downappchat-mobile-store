export default async function DownloadView() {
    const app = document.getElementById('app-content');
    
    const apkSize = '60.2 MB';
    const appVersion = '1.0.0';
    const releaseDate = '22 Nisan 2026';

    app.innerHTML = `
    <div class="dl-page">
        <!-- Animated Background Orbs -->
        <div class="dl-bg-orbs">
            <div class="dl-orb dl-orb-1"></div>
            <div class="dl-orb dl-orb-2"></div>
            <div class="dl-orb dl-orb-3"></div>
        </div>

        <!-- Hero Section -->
        <section class="dl-hero">
            <div class="dl-hero-badge">
                <i data-lucide="sparkles" style="width:14px;height:14px"></i>
                <span>Android İçin Hazır</span>
            </div>
            <h1 class="dl-hero-title">
                Down<span class="dl-gradient-text">App</span>
            </h1>
            <p class="dl-hero-subtitle">
                Mesajlaşma, uygulama keşfi ve daha fazlası — tek bir platformda.
            </p>
            
            <div class="dl-hero-image-container">
                <div class="dl-hero-glow"></div>
                <img src="/app-hero.png" alt="DownApp Uygulama" class="dl-hero-image" />
            </div>

            <div class="dl-cta-group">
                <a href="/downappchat.apk" download class="dl-btn-primary" id="dl-download-btn">
                    <i data-lucide="download" style="width:20px;height:20px"></i>
                    <div class="dl-btn-text">
                        <span class="dl-btn-label">APK İndir</span>
                        <span class="dl-btn-meta">v${appVersion} • ${apkSize}</span>
                    </div>
                </a>
                <a href="#/" class="dl-btn-secondary">
                    <i data-lucide="globe" style="width:18px;height:18px"></i>
                    <span>Web Sürümü</span>
                </a>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="dl-stats">
            <div class="dl-stat-card">
                <div class="dl-stat-icon" style="background: rgba(108, 99, 255, 0.15); color: #6c63ff;">
                    <i data-lucide="download-cloud" style="width:22px;height:22px"></i>
                </div>
                <span class="dl-stat-number">500+</span>
                <span class="dl-stat-desc">İndirme</span>
            </div>
            <div class="dl-stat-card">
                <div class="dl-stat-icon" style="background: rgba(255, 101, 132, 0.15); color: #ff6584;">
                    <i data-lucide="star" style="width:22px;height:22px"></i>
                </div>
                <span class="dl-stat-number">4.8</span>
                <span class="dl-stat-desc">Puan</span>
            </div>
            <div class="dl-stat-card">
                <div class="dl-stat-icon" style="background: rgba(0, 210, 255, 0.15); color: #00d2ff;">
                    <i data-lucide="shield-check" style="width:22px;height:22px"></i>
                </div>
                <span class="dl-stat-number">%100</span>
                <span class="dl-stat-desc">Güvenli</span>
            </div>
        </section>

        <!-- Features Section -->
        <section class="dl-features">
            <h2 class="dl-section-title">
                <i data-lucide="zap" style="width:20px;height:20px;color:#6c63ff"></i>
                Öne Çıkan Özellikler
            </h2>
            <div class="dl-features-grid">
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #6c63ff;">
                        <i data-lucide="message-circle" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Anlık Mesajlaşma</h3>
                    <p>Arkadaşlarınla gerçek zamanlı sohbet et, mesajlarını anında ilet.</p>
                </div>
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #ff6584;">
                        <i data-lucide="layout-grid" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Uygulama Mağazası</h3>
                    <p>Binlerce uygulamayı keşfet, incele ve kolayca indir.</p>
                </div>
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #00d2ff;">
                        <i data-lucide="camera" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Hikâyeler</h3>
                    <p>24 saatlik hikâyeler paylaş ve arkadaşlarını takip et.</p>
                </div>
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #fbbf24;">
                        <i data-lucide="user-plus" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Arkadaş Sistemi</h3>
                    <p>Kullanıcıları bul, arkadaşlık isteği gönder ve bağlan.</p>
                </div>
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #a78bfa;">
                        <i data-lucide="palette" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Modern Arayüz</h3>
                    <p>Koyu tema, cam efektleri ve akıcı animasyonlar.</p>
                </div>
                <div class="dl-feature-card">
                    <div class="dl-feature-icon-wrap" style="--accent: #34d399;">
                        <i data-lucide="lock" style="width:24px;height:24px"></i>
                    </div>
                    <h3>Gizlilik Odaklı</h3>
                    <p>Verilerini güvende tut, gizlilik önceliğimizdir.</p>
                </div>
            </div>
        </section>

        <!-- Requirements Section -->
        <section class="dl-requirements">
            <h2 class="dl-section-title">
                <i data-lucide="smartphone" style="width:20px;height:20px;color:#6c63ff"></i>
                Sistem Gereksinimleri
            </h2>
            <div class="dl-req-list">
                <div class="dl-req-item">
                    <i data-lucide="cpu" style="width:18px;height:18px;color:var(--text-tertiary)"></i>
                    <div>
                        <span class="dl-req-label">İşletim Sistemi</span>
                        <span class="dl-req-value">Android 6.0 (Marshmallow) ve üzeri</span>
                    </div>
                </div>
                <div class="dl-req-item">
                    <i data-lucide="hard-drive" style="width:18px;height:18px;color:var(--text-tertiary)"></i>
                    <div>
                        <span class="dl-req-label">Depolama</span>
                        <span class="dl-req-value">En az 120 MB boş alan</span>
                    </div>
                </div>
                <div class="dl-req-item">
                    <i data-lucide="wifi" style="width:18px;height:18px;color:var(--text-tertiary)"></i>
                    <div>
                        <span class="dl-req-label">İnternet</span>
                        <span class="dl-req-value">Aktif internet bağlantısı gerekli</span>
                    </div>
                </div>
                <div class="dl-req-item">
                    <i data-lucide="file-text" style="width:18px;height:18px;color:var(--text-tertiary)"></i>
                    <div>
                        <span class="dl-req-label">Dosya Boyutu</span>
                        <span class="dl-req-value">${apkSize}</span>
                    </div>
                </div>
            </div>
        </section>

        <!-- Install Guide Section -->
        <section class="dl-install-guide">
            <h2 class="dl-section-title">
                <i data-lucide="book-open" style="width:20px;height:20px;color:#6c63ff"></i>
                Nasıl Yüklenir?
            </h2>
            <div class="dl-steps">
                <div class="dl-step">
                    <div class="dl-step-number">1</div>
                    <div class="dl-step-content">
                        <h4>APK Dosyasını İndir</h4>
                        <p>Yukarıdaki "APK İndir" butonuna tıklayarak dosyayı telefonuna indir.</p>
                    </div>
                </div>
                <div class="dl-step-line"></div>
                <div class="dl-step">
                    <div class="dl-step-number">2</div>
                    <div class="dl-step-content">
                        <h4>Bilinmeyen Kaynaklara İzin Ver</h4>
                        <p>Ayarlar → Güvenlik → Bilinmeyen Kaynaklar seçeneğini etkinleştir.</p>
                    </div>
                </div>
                <div class="dl-step-line"></div>
                <div class="dl-step">
                    <div class="dl-step-number">3</div>
                    <div class="dl-step-content">
                        <h4>Yükle ve Başla</h4>
                        <p>İndirilen dosyaya dokun, "Yükle"ye bas ve DownApp'i kullanmaya başla!</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Version Info -->
        <section class="dl-version-info">
            <div class="dl-version-card">
                <div class="dl-version-header">
                    <i data-lucide="tag" style="width:16px;height:16px;color:#6c63ff"></i>
                    <span>Son Sürüm</span>
                </div>
                <div class="dl-version-details">
                    <div class="dl-version-row">
                        <span>Sürüm</span>
                        <span class="dl-version-val">v${appVersion}</span>
                    </div>
                    <div class="dl-version-row">
                        <span>Yayın Tarihi</span>
                        <span class="dl-version-val">${releaseDate}</span>
                    </div>
                    <div class="dl-version-row">
                        <span>Boyut</span>
                        <span class="dl-version-val">${apkSize}</span>
                    </div>
                    <div class="dl-version-row">
                        <span>Platform</span>
                        <span class="dl-version-val">Android</span>
                    </div>
                </div>
            </div>
        </section>

        <!-- Bottom CTA -->
        <section class="dl-bottom-cta">
            <div class="dl-bottom-cta-glow"></div>
            <h2>Hemen İndir, Hemen Keşfet</h2>
            <p>DownApp ile mesajlaşmanın ve uygulama keşfinin yeni yolunu dene.</p>
            <a href="/downappchat.apk" download class="dl-btn-primary dl-btn-lg">
                <i data-lucide="download" style="width:22px;height:22px"></i>
                <div class="dl-btn-text">
                    <span class="dl-btn-label">DownApp'i İndir</span>
                    <span class="dl-btn-meta">Android APK • ${apkSize}</span>
                </div>
            </a>
        </section>

        <!-- Footer -->
        <footer class="dl-footer">
            <div class="dl-footer-logo">Down<span class="dl-gradient-text">App</span></div>
            <p>© 2026 DownApp. Tüm hakları saklıdır.</p>
            <div class="dl-footer-links">
                <a href="#/">Ana Sayfa</a>
                <a href="#/search">Uygulamalar</a>
                <a href="#/profile">Profil</a>
            </div>
        </footer>
    </div>
    `;

    // Animate elements on scroll
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('dl-visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    app.querySelectorAll('.dl-feature-card, .dl-stat-card, .dl-step, .dl-req-item').forEach(el => {
        el.classList.add('dl-animate');
        observer.observe(el);
    });

    // Download button click animation
    const dlBtn = document.getElementById('dl-download-btn');
    if (dlBtn) {
        dlBtn.addEventListener('click', () => {
            dlBtn.classList.add('dl-downloading');
            dlBtn.querySelector('.dl-btn-label').textContent = 'İndiriliyor...';
            setTimeout(() => {
                dlBtn.classList.remove('dl-downloading');
                dlBtn.querySelector('.dl-btn-label').textContent = 'APK İndir';
            }, 3000);
        });
    }

    // Re-init Lucide
    setTimeout(() => {
        if (window.lucide) window.lucide.createIcons();
    }, 50);
}
