import { login } from '../auth';

export default async function LoginView() {
    const appContent = document.getElementById('app-content');
    
    appContent.innerHTML = `
        <div class="login-page" style="min-height: calc(100vh - 70px); display: flex; align-items: center; justify-content: center; padding: 2rem;">
            <div class="login-card glass" style="width: 100%; max-width: 400px; padding: 2.5rem; border-radius: 30px; animation: slideUp 0.5s ease;">
                <div style="text-align: center; margin-bottom: 2rem;">
                    <div style="width: 80px; height: 80px; background: var(--primary-gradient); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem; box-shadow: 0 10px 30px var(--glow);">
                        <i data-lucide="user-lock" style="color: white; width: 40px; height: 40px;"></i>
                    </div>
                    <h1 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Hoş Geldiniz</h1>
                    <p style="color: var(--text-tertiary);">DownApp profilinize erişin</p>
                </div>

                <form id="login-form">
                    <div class="form-group" style="margin-bottom: 1.5rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">E-posta</label>
                        <input type="email" id="email" required placeholder="ornek@mail.com" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; outline: none; transition: 0.3s;">
                    </div>

                    <div class="form-group" style="margin-bottom: 2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">Şifre</label>
                        <input type="password" id="password" required placeholder="••••••••" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; outline: none; transition: 0.3s;">
                    </div>

                    <div id="login-error" style="color: #ff4b4b; font-size: 0.85rem; text-align: center; margin-bottom: 1rem; display: none;"></div>

                    <button type="submit" id="login-btn" class="download-btn" style="width: 100%; padding: 16px; font-size: 1rem; weight: 700;">
                        Giriş Yap
                    </button>
                </form>

                <div style="text-align: center; margin-top: 2rem; font-size: 0.9rem; color: var(--text-tertiary);">
                    Henüz hesabınız yok mu? <a href="#/register" style="color: var(--primary); font-weight: 600;">Kayıt Ol</a>
                </div>
            </div>
        </div>
    `;

    if (window.lucide) window.lucide.createIcons();

    const loginForm = document.getElementById('login-form');
    const loginError = document.getElementById('login-error');
    const loginBtn = document.getElementById('login-btn');

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;

        loginBtn.disabled = true;
        loginBtn.innerHTML = 'Giriş yapılıyor...';
        loginError.style.display = 'none';

        try {
            await login(email, password);
            // Redirect to profile
            window.location.hash = '#/profile';
        } catch (error) {
            console.error('Login error:', error);
            loginError.textContent = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
            loginError.style.display = 'block';
            loginBtn.disabled = false;
            loginBtn.innerHTML = 'Giriş Yap';
        }
    });

    // Add focus effects
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
        input.addEventListener('focus', () => {
            input.style.border = '1px solid var(--primary)';
            input.style.background = 'rgba(255,255,255,0.08)';
        });
        input.addEventListener('blur', () => {
            input.style.border = '1px solid rgba(255,255,255,0.1)';
            input.style.background = 'rgba(255,255,255,0.05)';
        });
    });
}
