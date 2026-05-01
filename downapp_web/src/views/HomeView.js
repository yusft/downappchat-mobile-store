import pb, { getApps, getStories, getFileUrl } from '../api'
import { isLoggedIn } from '../auth'

export default async function HomeView() {
    const appContent = document.getElementById('app-content');
    
    // Initial structure
    appContent.innerHTML = `
        <nav class="navbar">
            <div class="logo">DownApp</div>
            <div class="nav-actions" style="display: flex; gap: 12px; align-items: center;">
                <div id="notif-bell" style="position: relative; cursor: pointer;">
                    <i data-lucide="bell" style="width: 22px; height: 22px; color: var(--text-secondary);"></i>
                    <span id="notif-badge" style="display: none; position: absolute; top: -4px; right: -4px; width: 16px; height: 16px; background: var(--secondary); border-radius: 50%; font-size: 0.55rem; font-weight: 800; color: white; align-items: center; justify-content: center; z-index: 5;">0</span>
                </div>
            </div>
        </nav>

        <!-- Notification Panel -->
        <div id="notif-panel" class="notification-panel">
            <div class="navbar glass" style="position: sticky; top: 0;">
                <div id="notif-close" style="cursor: pointer;">
                    <i data-lucide="x" style="width: 22px; height: 22px;"></i>
                </div>
                <div class="logo">Bildirimler</div>
                <div></div>
            </div>
            <div id="notif-list" style="padding-bottom: 2rem;"></div>
        </div>

        <!-- Story Viewer Modal -->
        <div id="story-viewer" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: #000; z-index: 10000; flex-direction: column; align-items: center; justify-content: center;">
            <div id="story-progress-container" style="position: absolute; top: 20px; left: 0; width: 100%; display: flex; gap: 4px; padding: 0 10px;">
                <div style="flex: 1; height: 3px; background: rgba(255,255,255,0.3); border-radius: 2px;"><div id="story-progress-bar" style="width: 0%; height: 100%; background: #fff; border-radius: 2px;"></div></div>
            </div>
            <div style="position: absolute; top: 40px; left: 20px; display: flex; align-items: center; gap: 10px; z-index: 10;">
                <img id="story-user-avatar" src="" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid var(--primary);">
                <span id="story-user-name" style="color: white; font-weight: 700; font-size: 0.9rem; text-shadow: 0 2px 4px rgba(0,0,0,0.5);"></span>
            </div>
            <button id="story-close" style="position: absolute; top: 40px; right: 20px; background: none; border: none; color: white; cursor: pointer; z-index: 10;">
                <i data-lucide="x" style="width: 30px; height: 30px;"></i>
            </button>
            <img id="story-media" src="" style="max-width: 100%; max-height: 100%; object-fit: contain;">
            <p id="story-caption" style="position: absolute; bottom: 80px; left: 0; width: 100%; text-align: center; color: white; padding: 20px; font-weight: 500; text-shadow: 0 2px 4px rgba(0,0,0,0.8);"></p>
        </div>

        <section class="stories">
            <div id="stories-list" class="stories-container">
                <div class="story-item"><div class="story-circle shimmer"></div></div>
                <div class="story-item"><div class="story-circle shimmer"></div></div>
            </div>
        </section>
        <section class="categories" style="padding: 0.5rem 1rem;">
            <div class="category-list" style="display: flex; gap: 8px; overflow-x: auto; padding-bottom: 10px; scrollbar-width: none;">
                <div class="cat-chip active" data-cat="all" style="padding: 8px 16px; border-radius: 20px; background: var(--primary); font-size: 0.8rem; font-weight: 600; flex-shrink: 0; cursor: pointer;">Hepsi</div>
                <div class="cat-chip" data-cat="Oyunlar" style="padding: 8px 16px; border-radius: 20px; background: var(--card); border: 1px solid var(--border); font-size: 0.8rem; font-weight: 600; flex-shrink: 0; cursor: pointer;">Oyunlar</div>
                <div class="cat-chip" data-cat="Araçlar" style="padding: 8px 16px; border-radius: 20px; background: var(--card); border: 1px solid var(--border); font-size: 0.8rem; font-weight: 600; flex-shrink: 0; cursor: pointer;">Araçlar</div>
                <div class="cat-chip" data-cat="Sosyal" style="padding: 8px 16px; border-radius: 20px; background: var(--card); border: 1px solid var(--border); font-size: 0.8rem; font-weight: 600; flex-shrink: 0; cursor: pointer;">Sosyal</div>
                <div class="cat-chip" data-cat="Eğitim" style="padding: 8px 16px; border-radius: 20px; background: var(--card); border: 1px solid var(--border); font-size: 0.8rem; font-weight: 600; flex-shrink: 0; cursor: pointer;">Eğitim</div>
            </div>
        </section>
        <main class="marketplace">
            <div class="section-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                <h2 style="margin: 0;">Keşfet</h2>
                <span class="view-all" style="font-size: 0.8rem; color: var(--primary); font-weight: 600;">Tümünü Gör</span>
            </div>
            <div id="app-grid" class="app-grid">
                <div class="app-card shimmer" style="height: 180px;"></div>
                <div class="app-card shimmer" style="height: 180px;"></div>
            </div>
        </main>
    `;

    const storiesList = document.getElementById('stories-list');
    const appGrid = document.getElementById('app-grid');
    let allApps = [];

    async function loadData() {
        try {
            const [appsData, storiesData] = await Promise.all([getApps(), getStories()]);
            if (!storiesList || !appGrid) return;
            
            // Render Stories
            storiesList.innerHTML = storiesData.items.map(story => {
                const userRecord = story.expand?.user || {};
                // User records might be in different collections depending on expand, 
                // but usually user files are in _pb_users_auth_
                const avatarFilename = userRecord.avatar || story.userAvatar;
                const avatarUrl = avatarFilename ? getFileUrl('_pb_users_auth_', story.userId, avatarFilename) : 'https://via.placeholder.com/100';
                const userName = userRecord.displayName || story.userName || 'Kullanıcı';
                
                return `
                    <div class="story-item" data-id="${story.id}" style="cursor: pointer;">
                        <div class="story-circle">
                            <div class="story-inner">
                                <img src="${avatarUrl}" alt="${userName}" onerror="this.src='https://via.placeholder.com/100'">
                            </div>
                        </div>
                        <span class="story-name" style="display: block; font-size: 0.7rem; text-align: center; margin-top: 4px; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 72px;">${userName}</span>
                    </div>
                `;
            }).join('') || '<p style="padding: 1rem; color: var(--text-tertiary);">Hikaye yok</p>';

            // Add click events to stories
            document.querySelectorAll('.story-item[data-id]').forEach(item => {
                item.onclick = () => {
                    const story = storiesData.items.find(s => s.id === item.dataset.id);
                    if (story) openStoryViewer(story);
                };
            });

            // Store all apps for filtering
            allApps = appsData.items;
            renderApps(allApps);
            
            if (window.lucide) window.lucide.createIcons();
        } catch (error) {
            console.error('Home data load error:', error);
        }
    }

    // Story Viewer Logic
    let storyTimer = null;
    function openStoryViewer(story) {
        const viewer = document.getElementById('story-viewer');
        const media = document.getElementById('story-media');
        const userAvatar = document.getElementById('story-user-avatar');
        const userName = document.getElementById('story-user-name');
        const caption = document.getElementById('story-caption');
        const progressBar = document.getElementById('story-progress-bar');

        const userRecord = story.expand?.user || {};
        userAvatar.src = userRecord.avatar ? getFileUrl('_pb_users_auth_', story.userId, userRecord.avatar) : 'https://via.placeholder.com/100';
        userName.textContent = userRecord.displayName || story.userName || 'Kullanıcı';
        media.src = getFileUrl('stories', story.id, story.mediaUrl);
        caption.textContent = story.caption || '';
        
        viewer.style.display = 'flex';
        progressBar.style.width = '0%';
        
        if (window.lucide) window.lucide.createIcons();

        // Simple progress animation (5 seconds)
        let prog = 0;
        if (storyTimer) clearInterval(storyTimer);
        storyTimer = setInterval(() => {
            prog += 1;
            progressBar.style.width = prog + '%';
            if (prog >= 100) {
                closeStoryViewer();
            }
        }, 50);
    }

    function closeStoryViewer() {
        const viewer = document.getElementById('story-viewer');
        viewer.style.display = 'none';
        if (storyTimer) clearInterval(storyTimer);
        const media = document.getElementById('story-media');
        media.src = ''; // stop any loading
    }

    document.getElementById('story-close').onclick = closeStoryViewer;

    function renderApps(items) {
        if (items.length === 0) {
            appGrid.innerHTML = '<p style="grid-column: span 2; text-align: center; color: var(--text-tertiary); padding: 2rem;">Bu kategoride uygulama yok.</p>';
            return;
        }
        appGrid.innerHTML = items.map(app => {
            const iconUrl = getFileUrl('apps', app.id, app.icon);
            return `
                <div class="app-card glass" onclick="window.location.hash = '#/app/${app.id}'" style="cursor: pointer; animation: fadeIn 0.4s ease-out;">
                    <img src="${iconUrl}" class="app-icon" alt="${app.name}" onerror="this.src='https://via.placeholder.com/60'">
                    <div class="app-info">
                        <span class="app-name">${app.name}</span>
                        <span class="app-category">${app.category || 'Araçlar'}</span>
                    </div>
                    <div class="app-footer" style="display: flex; justify-content: space-between; align-items: center;">
                        <div class="app-rating" style="display: flex; align-items: center; gap: 3px;">
                            <i data-lucide="star" style="width: 12px; height: 12px; fill: #ffb800; color: #ffb800;"></i>
                            <span style="font-size: 0.8rem; font-weight: 600;">${(app.ratingAverage || 0).toFixed(1)}</span>
                        </div>
                        <button class="download-btn">${(app.fileSize / 1048576).toFixed(1)} MB</button>
                    </div>
                </div>
            `;
        }).join('');
        if (window.lucide) window.lucide.createIcons();
    }

    // Initial load
    await loadData();

    // Category filter
    document.querySelectorAll('.cat-chip').forEach(chip => {
        chip.onclick = () => {
            document.querySelectorAll('.cat-chip').forEach(c => {
                c.style.background = 'var(--card)';
                c.style.border = '1px solid var(--border)';
                c.classList.remove('active');
            });
            chip.style.background = 'var(--primary)';
            chip.style.border = 'none';
            chip.classList.add('active');

            const cat = chip.dataset.cat;
            if (cat === 'all') {
                renderApps(allApps);
            } else {
                renderApps(allApps.filter(a => (a.category || '').toLowerCase() === cat.toLowerCase()));
            }
        };
    });

    // Notification bell + panel
    loadNotifications();

    document.getElementById('notif-bell').onclick = () => {
        document.getElementById('notif-panel').classList.add('open');
    };
    document.getElementById('notif-close').onclick = () => {
        document.getElementById('notif-panel').classList.remove('remove');
        document.getElementById('notif-panel').classList.remove('open');
    };

    // Real-time subscription
    pb.collection('apps').subscribe('*', async (e) => {
        if (e.action !== 'delete') {
            const freshData = await getApps();
            allApps = freshData.items;
            renderApps(allApps);
        }
    });

    window.addEventListener('hashchange', () => {
        pb.collection('apps').unsubscribe('*');
        if (storyTimer) clearInterval(storyTimer);
    }, { once: true });
}

async function loadNotifications() {
    const notifList = document.getElementById('notif-list');
    const notifBadge = document.getElementById('notif-badge');
    
    try {
        const recentApps = await pb.collection('apps').getList(1, 10, {
            filter: 'status = "approved"',
            sort: '-created',
        });

        const items = recentApps.items;
        
        if (items.length > 0) {
            notifBadge.style.display = 'flex';
            notifBadge.textContent = items.length > 9 ? '9+' : items.length;
        }
        
        notifList.innerHTML = items.map(app => {
            const iconUrl = getFileUrl('apps', app.id, app.icon);
            const timeAgo = getTimeAgo(new Date(app.created));
            return `
                <div class="notification-item" onclick="window.location.hash = '#/app/${app.id}'; document.getElementById('notif-panel').classList.remove('open');">
                    <div class="notification-dot"></div>
                    <img src="${iconUrl}" style="width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;" onerror="this.src='https://via.placeholder.com/40'">
                    <div style="flex: 1;">
                        <p style="font-weight: 600; font-size: 0.85rem; color: var(--text-primary);">${app.name}</p>
                        <p style="font-size: 0.75rem; color: var(--text-tertiary);">Yeni uygulama eklendi • ${timeAgo}</p>
                    </div>
                </div>
            `;
        }).join('') || '<p style="text-align: center; padding: 3rem; color: var(--text-tertiary);">Bildirim yok</p>';

        if (window.lucide) window.lucide.createIcons();
    } catch (e) {
        console.error('Notification load error:', e);
        notifList.innerHTML = '<p style="text-align: center; padding: 3rem; color: var(--text-tertiary);">Bildirimler yüklenemedi</p>';
    }
}

function getTimeAgo(date) {
    const now = new Date();
    const diff = Math.floor((now - date) / 1000);
    if (diff < 60) return 'Az önce';
    if (diff < 3600) return `${Math.floor(diff / 60)} dk önce`;
    if (diff < 86400) return `${Math.floor(diff / 3600)} saat önce`;
    return `${Math.floor(diff / 86400)} gün önce`;
}
