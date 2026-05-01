import { searchApps, getFileUrl } from '../api'

export default async function SearchView() {
    const appContent = document.getElementById('app-content');
    
    appContent.innerHTML = `
        <div class="search-page" style="padding: 1rem;">
            <div class="search-box" style="margin-bottom: 1.5rem;">
                <input type="text" id="search-input" placeholder="Uygulama, kategori veya geliştirici ara..." 
                    style="width: 100%; padding: 14px; border-radius: 16px; border: 1px solid var(--border); background: var(--card); color: white; font-size: 1rem; outline: none; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
            </div>
            
            <div id="search-results" class="app-grid">
                <p style="grid-column: 1/-1; text-align: center; color: var(--text-tertiary); padding: 2rem;">
                    Aramak istediğiniz uygulamayı yazın...
                </p>
            </div>
        </div>
    `;

    const searchInput = document.getElementById('search-input');
    const searchResults = document.getElementById('search-results');

    let debounceTimer;

    searchInput.addEventListener('input', (e) => {
        const query = e.target.value.trim();
        clearTimeout(debounceTimer);
        
        if (query.length < 2) {
            searchResults.innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: var(--text-tertiary); padding: 2rem;">En az 2 harf girin...</p>';
            return;
        }

        debounceTimer = setTimeout(async () => {
            searchResults.innerHTML = '<div class="app-card shimmer" style="height: 180px;"></div><div class="app-card shimmer" style="height: 180px;"></div>';
            
            try {
                const data = await searchApps(query);
                renderResults(data.items);
            } catch (error) {
                console.error('Search error:', error);
                searchResults.innerHTML = '<p>Arama sırasında bir hata oluştu.</p>';
            }
        }, 500);
    });

    function renderResults(apps) {
        if (!apps || apps.length === 0) {
            searchResults.innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: var(--text-tertiary); padding: 2rem;">Sonuç bulunamadı.</p>';
            return;
        }

        searchResults.innerHTML = apps.map(app => {
            const iconUrl = getFileUrl('apps', app.id, app.icon);
            return `
                <div class="app-card glass" onclick="window.location.hash = '#/app/${app.id}'">
                    <img src="${iconUrl}" class="app-icon" alt="${app.name}">
                    <div class="app-info">
                        <span class="app-name">${app.name}</span>
                        <span class="app-category">${app.category || 'Araçlar'}</span>
                    </div>
                    <div class="app-footer">
                        <div class="app-rating">
                            <i data-lucide="star" style="width: 12px; height: 12px; fill: #ffb800;"></i>
                            <span>${(app.ratingAverage || 0).toFixed(1)}</span>
                        </div>
                        <button class="download-btn">İndir</button>
                    </div>
                </div>
            `;
        }).join('');
        
        if (window.lucide) window.lucide.createIcons();
    }

    searchInput.focus();
}
