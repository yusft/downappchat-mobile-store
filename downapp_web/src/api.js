import PocketBase from 'pocketbase';

const pb = new PocketBase('https://YOUR_POCKETBASE_DOMAIN');
pb.autoCancellation(false);

export default pb;

export const getApps = async () => {
    // Mobil uygulamadaki filter mantığı: Approved ve silinmemiş olanlar
    return await pb.collection('apps').getList(1, 50, {
        filter: 'status = "approved"',
        sort: '-created',
        expand: 'developer'
    });
};

export const getStories = async () => {
    const now = new Date().toISOString();
    return await pb.collection('stories').getList(1, 20, {
        filter: `expiresAt > "${now}"`,
        sort: '-created',
        expand: 'user'
    });
};

export const getAppDetail = async (id) => {
    return await pb.collection('apps').getOne(id, {
        expand: 'developer'
    });
};

export const getAppReviews = async (appId) => {
    const cleanId = (appId || '').trim();
    return await pb.collection('reviews').getList(1, 50, {
        filter: `app = "${cleanId}"`,
        sort: '-created',
        expand: 'user,app'
    });
};

export const searchApps = async (query) => {
    return await pb.collection('apps').getList(1, 20, {
        filter: `name ~ "${query}" || category ~ "${query}"`,
        expand: 'developer'
    });
};

export const getUserProfile = async (id) => {
    try {
        return await pb.collection('users').getOne(id);
    } catch (e) {
        // Fallback or rethrow
        throw e;
    }
};

export const getUserReviews = async (userId) => {
    return await pb.collection('reviews').getList(1, 50, {
        filter: `user = "${userId}"`,
        sort: '-created',
        expand: 'app'
    });
};

export const getUserFavorites = async (userId) => {
    return await pb.collection('favorites').getList(1, 50, {
        filter: `user = "${userId}"`,
        sort: '-created',
        expand: 'app'
    });
};

export const getFileUrl = (collection, recordId, filename) => {
    if (!filename) return '';
    return `https://YOUR_POCKETBASE_DOMAIN/api/files/${collection}/${recordId}/${filename}`;
};
