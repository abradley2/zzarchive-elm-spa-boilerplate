const app = window.Elm.Main.embed(document.getElementById('app'), window.config)

// Useful hack for an "on mount" hook that enables easy use of ports
// for js components.
document.addEventListener('animationstart', e => {
    if (e.animationName === 'nodeInserted') {
        // Inserted element = e.target
    }
})

window.addEventListener('online', () => app.ports.onlineStatus.send(true))
window.addEventListener('offline', () => app.ports.onlineStatus.send(false))

// Handle the prevent-default of link clicks and use ports for push-state
// based routing. This is just so much easier
document.addEventListener('click', e => {
    const {href, replaceState} = (function isLink(node, count) {
        const href = node.getAttribute && node.getAttribute('data-link')
        const parent = e.target.parentNode
        const next = count + 1

        if (href) {
            return {href, replaceState: Boolean(node.getAttribute('data-replace-state'))}
        }
        if (!parent || count >= 4) {
            return {href: false, replaceState: false}
        }
        if (parent && count < 4) {
            return isLink(parent, next)
        }
    })(e.target, 0)

    if (href) {
        e.preventDefault()
        e.stopPropagation()
        app.ports.navigate.send([href, replaceState])
    }
})
