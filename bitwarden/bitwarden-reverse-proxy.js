addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
    // An error is thrown that immutable headers can’t be modified
    request = new Request(request);

    let url = new URL(request.url);
    if (url.pathname.indexOf('/' + BW_OBS) !== 0) {
        return new Response('Hello world')
    }

    request.headers.set('bw', BW_HEADER)

    let host = BW_HOST;
    let hosts = url.hostname.split(":")[0].split(".").slice(-2);
    if (hosts.length === 2) {
        host += ".";
        host += hosts.join('.');
    }

    return fetch('http://' + host +
        url.pathname.replace(new RegExp(`^\/${BW_OBS}`), ''),
        {
            method: request.method,
            body: request.body,
            headers: request.headers,
            keepalive: request.keepalive,
        }
    );
}