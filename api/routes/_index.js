const route = require('koa-route')

module.exports = function (app) {
    app.use(route.get('/hello', require('./hello').get))
}
