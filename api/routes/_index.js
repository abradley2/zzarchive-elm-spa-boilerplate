const withValidation = require('../middleware/validate')

module.exports = function (app) {
    app.use(withValidation.get('/hello', require('./hello').get))
}
