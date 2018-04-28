const config = {
    API_URL: process.env.NODE_ENV === 'development' ? `http://127.0.0.1:${process.env.PORT}` : '',
    REDIS_URL: process.env.REDIS_URL,
    REDIS_PREFIX: process.env.REDIS_PREFIX,
    GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID,
    GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET,
    OAUTH_REDIRECT_URI: process.env.OAUTH_REDIRECT_URI,
    ADMINS: process.env.ADMINS,
    SECRET: process.env.SECRET
}
if (process.env.NODE_ENV === 'development') {
    try {
        Object.assign(config, require('./local-config'))
    } catch (err) {
        global.console.log('no local-config.json found in root directory, add one!')
    }
}

module.exports = config
