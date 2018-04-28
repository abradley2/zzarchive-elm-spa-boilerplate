const fs = require('fs')
const path = require('path')
const logger = require('pino')()
const Koa = require('koa')
const cors = require('@koa/cors')
const serve = require('koa-static')
const bodyParser = require('koa-bodyparser')
const Redis = require('ioredis')
const config = require('../config')

logger.info('starting api')

// Write the public config file
const clientConfig = {
    apiUrl: config.API_URL,
    env: process.env.NODE_ENV
}

fs.writeFileSync(path.join(__dirname, '../static/local-config.js'), `
  window.config = JSON.parse('${JSON.stringify(clientConfig)}')
`)
const index = fs.readFileSync(path.join(__dirname, '../static/index.html'), 'utf8')

async function start() {
    const app = new Koa()
    const host = process.env.HOST || '127.0.0.1'
    const port = process.env.PORT || 3000
    const redis = new Redis(config.REDIS_URL)

    app.use(cors())
    app.use(bodyParser())
    app.use(serve(path.join(__dirname, '../static')))
    app.use(async (ctx, next) => {
        ctx.logger = logger
        ctx.config = config
        ctx.redis = redis
        try {
            await next()
        } catch (err) {
            global.console.error(err)
            ctx.response.status = 500
            ctx.response.body = {error: err.message}
        }
    })

    require('./routes/_index')(app)

    app.use(async (ctx, next) => {
        await next()
        // Support pushstate routing
        if (
            !ctx.response.body &&
            !ctx.response.status &&
            ctx.request.get('Accept').toLowerCase().includes('html')
        ) {
            ctx.response.body = index
            ctx.response.status = 200
        }
    })

    app.listen(port, host)
    logger.info('Server listening on ' + host + ':' + port)
}

start()
