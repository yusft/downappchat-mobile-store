import pb from './api';

export const login = async (email, password) => {
    try {
        const authData = await pb.collection('users').authWithPassword(email, password);
        return authData;
    } catch (error) {
        throw error;
    }
};

export const register = async (email, password, displayName, username) => {
    try {
        const data = {
            email: email,
            password: password,
            passwordConfirm: password,
            displayName: displayName,
            username: username || email.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '') + Math.floor(Math.random() * 1000),
            name: displayName,
        };
        const record = await pb.collection('users').create(data);
        // Auto-login after registration
        return await login(email, password);
    } catch (error) {
        throw error;
    }
};

export const logout = () => {
    pb.authStore.clear();
};

export const isLoggedIn = () => {
    return pb.authStore.isValid;
};

export const getCurrentUser = () => {
    return pb.authStore.record;
};

export const getAuthToken = () => {
    return pb.authStore.token;
};
