## What is Phoenix LiveView?
# Is a librrary that provides real-time user experiences with server-rendered HTML.

##unique features:
# Since live views are server-rendered, the initial request is just a regular HTTP request. So the client gets a fast initial response of static HTML which has the added benefit of making it SEO friendly without a need for extra complexity.

# LiveView uses a persistent websocket connection after the initial request so LiveView applications react almost instantly to user events. Changes on the server can also be pushed to multiple clients. That’s really important for building distributed, real-time applications.

# While other technologies that perform server-side rendering often send the whole page on every user event, LiveView knows exactly what changed and it sends clients only the changed values.

# LiveView is built on top of the battle-tested Phoenix platform so it can reliably handle millions of concurrent websocket connections.

# The results are dramatic and game-changing:
# # both client and server in sync, always and seamlessly
# # persistent connections highly-optimized for web scale
# # robust and resilient UIs so you can rock and roll
# # a unified code base that’s easier to maintain
# # no custom JavaScript or external dependencies
