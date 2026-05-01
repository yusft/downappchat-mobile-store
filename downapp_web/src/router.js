export default class Router {
    constructor(routes) {
        this.routes = routes;
        this.app = document.getElementById('app-content');
        
        window.addEventListener('hashchange', () => this.handleRoute());
        window.addEventListener('load', () => this.handleRoute());
    }

    async handleRoute() {
        if (!window.location.hash && window.location.pathname && window.location.pathname.length > 1) {
            window.location.hash = '#' + window.location.pathname;
            return;
        }
        
        const hash = window.location.hash || '#/';
        const parts = hash.split('/').filter(p => p !== '#');
        const path = parts[0] || '';
        const id = parts[1] || '';
        
        let routeKey = '/' + path;
        let route = this.routes[routeKey];

        if (route) {
            // Loading state
            this.app.innerHTML = '<div class="loader-container"><div class="shimmer" style="width: 100%; height: 400px; border-radius: 20px;"></div></div>';
            
            // Execute route logic
            await route(id);
            
            // Re-initialize icons with a small delay for safety
            setTimeout(() => {
                if (window.lucide) {
                    window.lucide.createIcons();
                }
            }, 50);
            
            // Scroll to top
            window.scrollTo(0, 0);

            // Hide bottom nav on download page
            const bottomNav = document.querySelector('.bottom-nav');
            if (bottomNav) {
                bottomNav.style.display = (path === 'download') ? 'none' : 'flex';
            }
            // Remove bottom padding on download page
            if (path === 'download') {
                this.app.style.paddingBottom = '0';
            } else {
                this.app.style.paddingBottom = '90px';
            }

            // Update Active Nav Tab
            this.updateActiveNav(path);
        }
    }

    updateActiveNav(path) {
        document.querySelectorAll('.nav-item').forEach(item => {
            const href = item.getAttribute('href');
            item.classList.remove('active');
            
            if (path === '' && href === '#/') item.classList.add('active');
            else if (path === 'search' && href === '#/search') item.classList.add('active');
            else if ((path === 'profile' || path === 'login' || path === 'register') && href === '#/profile') item.classList.add('active');
        });
    }

    navigateTo(path) {
        window.location.hash = path;
    }
}
