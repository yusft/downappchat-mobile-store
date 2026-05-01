import './style.css'
import Router from './router'
import HomeView from './views/HomeView'
import DetailsView from './views/DetailsView'
import SearchView from './views/SearchView'
import ProfileView from './views/ProfileView'
import LoginView from './views/LoginView'
import RegisterView from './views/RegisterView'
import DownloadView from './views/DownloadView'

// Define routes
const routes = {
    '/': HomeView,
    '/app': DetailsView,
    '/search': SearchView,
    '/profile': ProfileView,
    '/login': LoginView,
    '/register': RegisterView,
    '/download': DownloadView
};

// Initialize Router
const router = new Router(routes);

// Global Lucide initialization (fallback)
document.addEventListener('DOMContentLoaded', () => {
    if (window.lucide) {
        window.lucide.createIcons();
    }
});
