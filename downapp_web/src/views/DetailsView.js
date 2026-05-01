import { getAppDetail, getAppReviews, getFileUrl } from '../api'
import { isLoggedIn } from '../auth'

const SHARE_BASE_URL = 'https://YOUR_DOMAIN';

export default async function DetailsView(appId) {
    const appContent = document.getElementById('app-content');
    
    try {
        const [app, reviewsData] = await Promise.all([
            getAppDetail(appId),
            getAppReviews(appId)
        ]);

        const iconUrl = getFileUrl('apps', app.id, app.icon);
        const fileSizeMb = (app.fileSize / 1048576).toFixed(1);
        const apkUrl = getFileUrl('apps', app.id, app.apk);
        const shareUrl = `${SHARE_BASE_URL}/app/${app.id}`;

        appContent.innerHTML = `
            <div class="details-page" style="background: var(--background); min-height: 100%;">
                <nav class="navbar glass">
                    <div class="nav-back" onclick="window.location.hash = '#/'" style="cursor: pointer;">
                        <i data-lucide="chevron-left"></i>
                    </div>
                    <div class="logo">Detaylar</div>
                    <button id="share-nav-btn" class="share-btn" title="Paylaş">
                        <i data-lucide="share-2" style="width: 18px; height: 18px;"></i>
                    </button>
                </nav>

                <header class="details-header">
                    <div class="details-icon-container">
                        <img src="${iconUrl}" class="details-icon" onerror="this.src='https://via.placeholder.com/100'" alt="${app.name}">
                    </div>
                    <div class="details-main-info">
                        <h1>${app.name}</h1>
                        <p style="color: var(--primary); font-weight: 600; cursor: pointer;" onclick="window.location.hash = '#/profile/${app.developer}'">
                            ${app.expand?.developer?.displayName || app.developerName || 'Geliştirici'}
                        </p>
                        <div class="app-rating" style="margin-top: 5px; display: flex; align-items: center; gap: 4px;">
                            <i data-lucide="star" style="width: 14px; height: 14px; fill: #ffb800; color: #ffb800;"></i>
                            <span style="font-weight: 700;">${(app.ratingAverage || 0).toFixed(1)}</span>
                            <span style="font-size: 0.7rem; color: var(--text-tertiary); margin-left: 2px;">(${app.ratingCount || 0} yorum)</span>
                        </div>
                    </div>
                </header>

                <div class="stats-bar">
                    <div class="stat-item">
                        <span class="stat-value">${(app.ratingAverage || 0).toFixed(1)}</span>
                        <span class="stat-label">Puan</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">${app.downloadCount || 0}</span>
                        <span class="stat-label">İndirme</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">${fileSizeMb} MB</span>
                        <span class="stat-label">Boyut</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">v${app.version || '1.0.0'}</span>
                        <span class="stat-label">Sürüm</span>
                    </div>
                </div>

                <div style="padding: 0.75rem 1.25rem; display: flex; gap: 10px;">
                    <a href="${apkUrl}" id="download-action-btn" class="download-btn" style="flex: 1; padding: 14px; font-size: 1rem; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px; border-radius: 16px;" ${apkUrl ? `download="${app.name}.apk"` : ''}>
                        <i data-lucide="download" style="width: 18px; height: 18px;"></i>
                        Hemen İndir (${fileSizeMb} MB)
                    </a>
                    <button id="share-action-btn" class="share-btn" style="padding: 14px 16px; border-radius: 16px;" title="Paylaş">
                        <i data-lucide="share-2" style="width: 20px; height: 20px;"></i>
                    </button>
                </div>

                ${(app.screenshots && Array.isArray(app.screenshots) && app.screenshots.length > 0) ? `
                <section class="screenshots-section" style="margin-top: 0.5rem;">
                    <h2 style="padding: 0 1.25rem 0.75rem; font-size: 1.1rem; color: var(--text-primary);">Ekran Görüntüleri</h2>
                    <div class="screenshots-container">
                        ${app.screenshots.map(s => `
                            <img src="${getFileUrl('apps', app.id, s)}" class="screenshot-img" alt="Screenshot" onerror="this.style.display='none'">
                        `).join('')}
                    </div>
                </section>
                ` : ''}

                <section class="content-section">
                    <h2 style="margin-bottom: 0.5rem; font-size: 1.1rem;">Açıklama</h2>
                    <div class="description-text" style="font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6;">
                        ${app.description || 'Açıklama bulunmuyor.'}
                    </div>
                </section>

                <section class="reviews-section" style="padding: 0 1.25rem 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <h2 style="font-size: 1.1rem; margin: 0;">Yorumlar</h2>
                    </div>
                    <div class="reviews-list">
                        ${reviewsData.items.length > 0 ? reviewsData.items.map(review => {
                            const userRecord = review.expand?.user || {};
                            const userName = userRecord.displayName || userRecord.username || review.userName || 'Kullanıcı';
                            const userAvatar = userRecord.avatar ? getFileUrl('users', review.user, userRecord.avatar) : null;
                            
                            return `
                                <div class="review-card" style="background: var(--surface); padding: 12px; border-radius: 16px; margin-bottom: 12px;">
                                    <div class="review-header" style="cursor: pointer; display: flex; gap: 10px; align-items: center;" onclick="window.location.hash = '#/profile/${review.user}'">
                                        <img src="${userAvatar || 'https://via.placeholder.com/40'}" class="review-avatar" style="width: 36px; height: 36px; border-radius: 50%;" onerror="this.src='https://via.placeholder.com/40'">
                                        <div style="display: flex; flex-direction: column;">
                                            <span style="font-weight: 600; font-size: 0.85rem;">${userName}</span>
                                            <div class="app-rating" style="display: flex; gap: 2px;">
                                                ${Array(5).fill(0).map((_, i) => `
                                                    <i data-lucide="star" style="width: 8px; height: 8px; ${i < review.rating ? 'fill: #ffb800; color: #ffb800;' : 'color: var(--text-tertiary);'}"></i>
                                                `).join('')}
                                            </div>
                                        </div>
                                    </div>
                                    <p style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 8px; line-height: 1.4;">${review.comment}</p>
                                </div>
                            `;
                        }).join('') : (app.ratingCount > 0 ? `<p style="color: var(--text-tertiary); text-align: center; padding: 1rem;">Bu uygulama için ${app.ratingCount} yorum bulunuyor ancak listelenemedi.</p>` : '<p style="color: var(--text-tertiary); text-align: center; padding: 1rem;">Henüz yorum yapılmamış.</p>')}
                    </div>
                </section>
            </div>
        `;

        if (window.lucide) window.lucide.createIcons();

        // Share functionality
        const shareData = {
            title: `${app.name} - DownApp`,
            text: `${app.name} uygulamasına göz at!`,
            url: shareUrl
        };

        const handleShare = async () => {
            if (navigator.share) {
                try {
                    await navigator.share(shareData);
                } catch (err) {
                    if (err.name !== 'AbortError') fallbackCopy(shareUrl);
                }
            } else {
                fallbackCopy(shareUrl);
            }
        };

        document.getElementById('share-nav-btn').onclick = handleShare;
        document.getElementById('share-action-btn').onclick = handleShare;

    } catch (error) {
        console.error('Details load error:', error);
        appContent.innerHTML = `<div style="padding: 2rem; text-align: center;">Hata oluştu: ${error.message}</div>`;
    }
}

function fallbackCopy(url) {
    navigator.clipboard.writeText(url).then(() => {
        showToast('Link kopyalandı!');
    }).catch(() => {
        showToast('Link: ' + url);
    });
}

function showToast(msg) {
    const existing = document.getElementById('toast-msg');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.id = 'toast-msg';
    toast.textContent = msg;
    Object.assign(toast.style, {
        position: 'fixed',
        bottom: '120px',
        left: '50%',
        transform: 'translateX(-50%)',
        background: 'var(--primary)',
        color: 'white',
        padding: '10px 24px',
        borderRadius: '12px',
        fontSize: '0.85rem',
        fontWeight: '600',
        zIndex: '9999',
        animation: 'fadeIn 0.3s ease',
        boxShadow: '0 8px 20px rgba(108, 99, 255, 0.4)'
    });
    document.body.appendChild(toast);
    setTimeout(() => toast.remove(), 2500);
}
