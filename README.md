# go.kirto.dev

The import path host for Kirto's Go modules. A module named
`go.kirto.dev/<root>/...` is fetched from the repository its root's tag
names. GitHub Pages serves this repository at `https://go.kirto.dev`.

| Root | Repository |
|---|---|
| `go.kirto.dev/apimachinery` | `kirto-dev/apimachinery` |
| `go.kirto.dev/platform` | `kirto-dev/platform` |
| `go.kirto.dev/flow-broker` | `kirto-dev/flow-broker` |
| `go.kirto.dev/flow` | `kirto-dev/flow` |
| `go.kirto.dev/flow-sdk` | `kirto-dev/flow`, under `sdk/` |
| `go.kirto.dev/gate` | `kirto-dev/gate` |
| `go.kirto.dev/flow-conformance` | `kirto-dev/flow-conformance` |

## How it answers

`index.html` carries one `go-import` tag per root, and `404.html` is the
same page. The go command asks for `https://go.kirto.dev/<path>?go-get=1`
and takes the tag whose root the path starts with, by path element, so
`go.kirto.dev/flow-sdk` never matches the `go.kirto.dev/flow` root. A path
under a root has no file of its own, so Pages answers it with `404.html`.
The go command reads the tags from that body and treats the status as an
error only when the body holds none (`metaImportsForPrefix` in
`cmd/go/internal/vcs`).

`flow-sdk` uses the tag's fourth field, the subdirectory, which Go 1.25
added. When the SDK moves to a repository of its own, its tag loses that
field.

A browser is sent on to the documentation at kirto.com/docs.

The tags name private repositories, so this repository is public and their
names are too. Their contents are not: fetching one needs a credential,
and every build sets `GOPRIVATE=go.kirto.dev`.

## Adding a root

Add its tag to `index.html`, copy the page over `404.html`, add its row
above, and run `./check.sh`, which fails where the two pages differ. A
nested module needs no tag: its root's repository serves it.

## Setting it up

Once, in this order:

1. In the organization's settings, under Pages, verify `kirto.dev`. GitHub
   asks for a TXT record on the zone. A verified domain stops another
   account from serving one of its subdomains.
2. In the Cloudflare zone `kirto.dev`: `go` CNAME `kirto-dev.github.io`,
   DNS only. Proxied, GitHub cannot issue the certificate.
3. In this repository's settings, under Pages: deploy from the `main`
   branch, root folder. The custom domain comes from `CNAME`. Enforce
   HTTPS once GitHub has issued the certificate.

Then `./check.sh live` asks the site for a path under every root.
