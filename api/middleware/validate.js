const route = require('koa-route')

const withValidation = method => (path, routeHandler) => {
    const schema = routeHandler.schema
    const validators = Object.keys(schema).reduce((acc, cur) => {
        return acc.concat([
            {
                requestKey: cur,
                validator: require('is-my-json-valid')(schema[cur])
            }
        ])
    }, [])

    return route[method](path, async ctx => {
        const errors = validators.reduce((errs, {requestKey, validator}) => {
            validator(ctx.request[requestKey])

            return validator.errors ? errs.concat(validator.errors) : errs
        }, [])
        if (errors.length !== 0) {
            ctx.response.status = 400
            ctx.response.body = errors
            return
        }
        await routeHandler(ctx)
    })
}

module.exports = ['get', 'patch', 'put', 'post', 'del'].reduce((obj, method) => {
    return Object.assign(obj, {[method]: withValidation(method)})
}, {})
