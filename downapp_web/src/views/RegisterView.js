import { register } from '../auth';

export default async function RegisterView() {
    const appContent = document.getElementById('app-content');
    
    appContent.innerHTML = `
        <div class="login-page" style="min-height: calc(100vh - 70px); display: flex; align-items: center; justify-content: center; padding: 2rem;">
            <div class="login-card glass" style="width: 100%; max-width: 400px; padding: 2.5rem; border-radius: 30px; animation: slideUp 0.5s ease;">
                <div style="text-align: center; margin-bottom: 2rem;">
                    <div style="width: 80px; height: 80px; background: var(--primary-gradient); border-radius: 20px; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem; box-shadow: 0 10px 30px var(--glow);">
                        <i data-lucide="user-plus" style="color: white; width: 40px; height: 40px;"></i>
                    </div>
                    <h1 style="font-size: 1.8rem; margin-bottom: 0.5rem;">Kayıt Ol</h1>
                    <p style="color: var(--text-tertiary);">DownApp dünyasına katılın</p>
                </div>

                <form id="register-form">
                    <div class="form-group" style="margin-bottom: 1.2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">Kullanıcı Adı</label>
                        <input type="text" id="username" required placeholder="kullanici_adi" minlength="3" maxlength="30" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary); outline: none; transition: 0.3s; box-sizing: border-box;">
                        <small style="display: block; font-size: 0.75rem; color: var(--text-tertiary); margin-top: 4px; margin-left: 10px;">En az 3 karakter, harf, rakam ve alt çizgi</small>
                    </div>

                    <div class="form-group" style="margin-bottom: 1.2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">Ad Soyad</label>
                        <input type="text" id="displayName" required placeholder="Adınız Soyadınız" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary); outline: none; transition: 0.3s; box-sizing: border-box;">
                    </div>

                    <div class="form-group" style="margin-bottom: 1.2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">E-posta</label>
                        <input type="email" id="email" required placeholder="ornek@mail.com" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary); outline: none; transition: 0.3s; box-sizing: border-box;">
                    </div>

                    <div class="form-group" style="margin-bottom: 1.2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">Şifre</label>
                        <input type="password" id="password" required placeholder="••••••••" minlength="8" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary); outline: none; transition: 0.3s; box-sizing: border-box;">
                    </div>

                    <div class="form-group" style="margin-bottom: 2rem;">
                        <label style="display: block; font-size: 0.85rem; color: var(--text-tertiary); margin-bottom: 0.5rem; margin-left: 10px;">Şifre Tekrar</label>
                        <input type="password" id="passwordConfirm" required placeholder="••••••••" minlength="8" style="width: 100%; padding: 14px 20px; border-radius: 16px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary); outline: none; transition: 0.3s; box-sizing: border-box;">
                    </div>

                    <div id="register-error" style="color: #ff4b4b; font-size: 0.85rem; text-align: center; margin-bottom: 1rem; display: none; background: rgba(255,75,75,0.1); padding: 10px 14px; border-radius: 12px;"></div>

                    <button type="submit" id="register-btn" class="download-btn" style="width: 100%; padding: 16px; font-size: 1rem; font-weight: 700;">
                        Kayıt Ol
                    </button>
                </form>

                <div style="text-align: center; margin-top: 2rem; font-size: 0.9rem; color: var(--text-tertiary);">
                    Zaten hesabınız var mı? <a href="#/login" style="color: var(--primary); font-weight: 600;">Giriş Yap</a>
                </div>
            </div>
        </div>
    `;

    if (window.lucide) window.lucide.createIcons();

    const registerForm = document.getElementById('register-form');
    const registerError = document.getElementById('register-error');
    const registerBtn = document.getElementById('register-btn');

    registerForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const username = document.getElementById('username').value.trim();
        const displayName = document.getElementById('displayName').value.trim();
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const passwordConfirm = document.getElementById('passwordConfirm').value;

        // Client-side validation
        if (password !== passwordConfirm) {
            registerError.textContent = 'Şifreler eşleşmiyor.';
            registerError.style.display = 'block';
            return;
        }

        if (password.length < 8) {
            registerError.textContent = 'Şifre en az 8 karakter olmalıdır.';
            registerError.style.display = 'block';
            return;
        }

        if (!/^[a-zA-Z0-9_]{3,}$/.test(username)) {
            registerError.textContent = 'Kullanıcı adı en az 3 karakter olmalı ve sadece harf, rakam ve alt çizgi içermelidir.';
            registerError.style.display = 'block';
            return;
        }

        registerBtn.disabled = true;
        registerBtn.innerHTML = '<span style="display: inline-flex; align-items: center; gap: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10" stroke-dasharray="40" stroke-dashoffset="10"/></svg> Kaydediliyor...</span>';
        registerError.style.display = 'none';

        try {
            await register(email, password, displayName, username);
            // Redirect to profile after successful registration and login
            window.location.hash = '#/profile';
            window.location.reload();
        } catch (error) {
            console.error('Registration error:', error);
            let msg = 'Kayıt başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.';
            
            // PocketBase errors usually live in error.response.data
            const errData = error?.response?.data || {};
            const errStr = JSON.stringify(errData).toLowerCase();
            
            if (errStr.includes('email')) {
                if (errStr.includes('validation_is_email') || errStr.includes('valid')) {
                    msg = 'Lütfen geçerli bir e-posta adresi girin (örn: isim@gmail.com).';
                } else {
                    msg = 'Bu e-posta adresi zaten kullanımda.';
                }
            } else if (errStr.includes('username')) {
                msg = 'Bu kullanıcı adı zaten alınmış veya geçersiz. Lütfen değiştirin.';
            } else if (errStr.includes('password')) {
                msg = 'Şifre gereksinimleri karşılanmıyor. En az 8 karakter kullanın.';
            } else if (error?.message) {
                msg = error.message;
            }
            
            registerError.textContent = msg;
            registerError.style.display = 'block';
            registerBtn.disabled = false;
            registerBtn.innerHTML = 'Kayıt Ol';
        }
    });

    // Add focus effects
    const inputs = document.querySelectorAll('#register-form input');
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

    // Username sanitizer
    const usernameInput = document.getElementById('username');
    usernameInput.addEventListener('input', (e) => {
        e.target.value = e.target.value.toLowerCase().replace(/[^a-z0-9_]/g, '');
    });
}
