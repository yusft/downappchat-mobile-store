import { getUserProfile, getUserReviews, getUserFavorites, getFileUrl } from '../api'
import { isLoggedIn, getCurrentUser, logout } from '../auth'

export default async function ProfileView(userId) {
    const appContent = document.getElementById('app-content');
    
    // If no userId provided, try to show the logged-in user
    let targetUserId = userId;
    let isMyProfile = false;

    if (!targetUserId) {
        if (!isLoggedIn()) {
            window.location.hash = '#/login';
            return;
        }
        const currentUser = getCurrentUser();
        targetUserId = currentUser.id;
        isMyProfile = true;
    } else {
        const currentUser = getCurrentUser();
        if (currentUser && currentUser.id === targetUserId) {
            isMyProfile = true;
        }
    }

    // Show skeleton ...
    appContent.innerHTML = `
        <div class="loader-container">
            <div class="shimmer" style="height: 200px; border-radius: 0 0 24px 24px;"></div>
            <div style="padding: 1rem; display: flex; gap: 1rem; align-items: flex-end; margin-top: -50px;">
                <div class="shimmer" style="width: 100px; height: 100px; border-radius: 50%; border: 4px solid var(--background);"></div>
                <div style="flex: 1; padding-bottom: 10px;">
                    <div class="shimmer" style="height: 24px; width: 60%; border-radius: 4px; margin-bottom: 8px;"></div>
                    <div class="shimmer" style="height: 16px; width: 40%; border-radius: 4px;"></div>
                </div>
            </div>
        </div>
    `;

    try {
        const [user, reviews, favorites] = await Promise.all([
            getUserProfile(targetUserId),
            getUserReviews(targetUserId),
            getUserFavorites(targetUserId)
        ]);

        const avatarUrl = getFileUrl('users', user.id, user.avatar);
        const bannerUrl = user.cover ? getFileUrl('users', user.id, user.cover) : null;
        
        const reviewItems = reviews.items || [];
        const favoriteItems = favorites.items || [];

        appContent.innerHTML = `
            <div class="profile-page">
                <nav class="navbar glass" style="position: absolute; background: transparent; border: none;">
                    <div class="nav-back" onclick="history.back()" style="cursor: pointer; background: rgba(0,0,0,0.3); padding: 8px; border-radius: 50%; width: 36px; height: 36px; display: flex; align-items: center; justify-content: center;">
                        <i data-lucide="chevron-left" style="color: white; width: 20px;"></i>
                    </div>
                </nav>

                <header class="profile-header">
                    <div class="profile-banner" style="height: 220px; background: ${bannerUrl ? `url(${bannerUrl}) center/cover` : 'var(--primary-gradient)'};"></div>
                    
                    <div class="profile-info-container" style="padding: 0 1.25rem; margin-top: -60px; position: relative;">
                        <div style="display: flex; align-items: flex-end; gap: 1rem; margin-bottom: 1rem;">
                            <img src="${avatarUrl || 'https://via.placeholder.com/150'}" class="profile-avatar" style="width: 110px; height: 110px; border-radius: 50%; border: 4px solid var(--background); background: var(--card); object-fit: cover;" onerror="this.src='https://via.placeholder.com/150'">
                            <div style="flex: 1; padding-bottom: 8px;">
                                <div style="display: flex; align-items: center; justify-content: space-between;">
                                    <div>
                                        <div style="display: flex; align-items: center; gap: 6px;">
                                            <h1 style="font-size: 1.3rem;">${user.displayName || user.username}</h1>
                                            ${(user.badges || []).includes('verified') ? '<i data-lucide="verified" style="color: #00d2ff; width: 18px;"></i>' : ''}
                                        </div>
                                        <span style="color: var(--text-tertiary); font-size: 0.85rem;">@${user.username}</span>
                                    </div>
                                    ${isMyProfile ? `
                                        <button id="logout-btn" class="glass" style="padding: 8px 12px; border-radius: 12px; border: 1px solid rgba(255,0,0,0.3); color: #ff4b4b; font-size: 0.8rem; font-weight: 600; cursor: pointer;">
                                            Çıkış Yap
                                        </button>
                                    ` : ''}
                                </div>
                            </div>
                        </div>
                        
                        <p class="profile-bio" style="margin-bottom: 1rem; font-size: 0.95rem; line-height: 1.5;">${user.bio || 'Henüz bir biyografi eklenmemiş.'}</p>
                        
                        <div class="profile-badges" style="display: flex; gap: 8px; margin-bottom: 1.5rem;">
                            ${(user.badges || []).map(badge => `
                                <span class="badge-chip" style="background: var(--surface); padding: 4px 10px; border-radius: 8px; font-size: 0.65rem; font-weight: 700; color: var(--accent); border: 1px solid rgba(0, 210, 255, 0.2); text-transform: uppercase;">
                                    ${badge}
                                </span>
                            `).join('')}
                        </div>
                    </div>
                </header>

                <div class="profile-tabs" style="border-top: 1px solid var(--border);">
                    <div class="tabs-header" style="display: flex; background: var(--surface);">
                        <div class="tab-item active" id="tab-reviews" style="flex: 1; text-align: center; padding: 1rem; border-bottom: 2px solid var(--primary); font-weight: 600; cursor: pointer;">Yorumlar (${reviewItems.length})</div>
                        <div class="tab-item" id="tab-favorites" style="flex: 1; text-align: center; padding: 1rem; color: var(--text-tertiary); cursor: pointer;">Favoriler (${favoriteItems.length})</div>
                    </div>

                    <div id="tab-content" style="padding: 1rem 1.25rem;">
                        <!-- Tab content will be rendered here -->
                    </div>
                </div>
            </div>
        `;

        if (window.lucide) window.lucide.createIcons();

        // Initial Tab render
        renderReviewsTab(reviewItems);

        // Tab logic
        document.getElementById('tab-reviews').onclick = () => {
            setActiveTab('tab-reviews');
            renderReviewsTab(reviewItems);
        };
        document.getElementById('tab-favorites').onclick = () => {
            setActiveTab('tab-favorites');
            renderFavoritesTab(favoriteItems);
        };

        if (isMyProfile) {
            document.getElementById('logout-btn').onclick = () => {
                logout();
                window.location.hash = '#/';
                window.location.reload();
            };
        }

    } catch (error) {
        console.error('Profile load error:', error);
        appContent.innerHTML = `<div style="padding: 4rem 2rem; text-align: center;"><h2>Kullanıcı bulunamadı</h2><button onclick="history.back()" style="margin-top: 1rem; padding: 10px 20px; border-radius: 12px; background: var(--primary); color: white; border: none;">Geri Dön</button></div>`;
    }

    function setActiveTab(id) {
        document.querySelectorAll('.tab-item').forEach(t => {
            t.style.color = 'var(--text-tertiary)';
            t.style.borderBottom = 'none';
        });
        const active = document.getElementById(id);
        active.style.color = 'var(--text-primary)';
        active.style.borderBottom = '2px solid var(--primary)';
    }

    function renderReviewsTab(items) {
        const container = document.getElementById('tab-content');
        if (items.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: var(--text-tertiary); padding: 2rem;">Henüz yorum yok.</p>';
            return;
        }

        container.innerHTML = items.map(review => {
            const app = review.expand?.app || {};
            const appIcon = getFileUrl('apps', app.id, app.icon);
            return `
                <div class="review-card glass" style="margin-bottom: 12px; padding: 12px; border-radius: 16px; cursor: pointer;" onclick="window.location.hash = '#/app/${app.id}'">
                    <div style="display: flex; gap: 12px; align-items: center; margin-bottom: 10px;">
                        <img src="${appIcon || 'https://via.placeholder.com/40'}" style="width: 40px; height: 40px; border-radius: 10px;">
                        <div>
                            <div style="font-weight: 600; font-size: 0.9rem;">${app.name || 'Uygulama'}</div>
                            <div class="app-rating">
                                ${Array(5).fill(0).map((_, i) => `
                                    <i data-lucide="star" style="width: 10px; height: 10px; ${i < review.rating ? 'fill: #ffb800;' : 'color: var(--text-tertiary);'}"></i>
                                `).join('')}
                            </div>
                        </div>
                    </div>
                    <p style="font-size: 0.85rem; color: var(--text-secondary);">${review.comment}</p>
                </div>
            `;
        }).join('');
        if (window.lucide) window.lucide.createIcons();
    }

    function renderFavoritesTab(items) {
        const container = document.getElementById('tab-content');
        if (items.length === 0) {
            container.innerHTML = '<p style="text-align: center; color: var(--text-tertiary); padding: 2rem;">Henüz favori yok.</p>';
            return;
        }

        container.innerHTML = `
            <div class="app-grid" style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
                ${items.map(fav => {
                    const app = fav.expand?.app || {};
                    const appIcon = getFileUrl('apps', app.id, app.icon);
                    return `
                        <div class="app-card glass" style="padding: 10px; border-radius: 16px; text-align: center; cursor: pointer;" onclick="window.location.hash = '#/app/${app.id}'">
                            <img src="${appIcon}" class="app-icon" style="width: 48px; height: 48px; border-radius: 12px; margin-bottom: 8px;">
                            <div class="app-name" style="font-size: 0.75rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: white;">${app.name}</div>
                        </div>
                    `;
                }).join('')}
            </div>
        `;
    }
}
