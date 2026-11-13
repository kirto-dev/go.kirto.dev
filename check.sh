#!/usr/bin/env bash
# Fails where 404.html has drifted from index.html, or where the live site
# answers a module path without its tag. Run it after a change and after
# the first deploy.
#
#   ./check.sh          the files only
#   ./check.sh live     the files, then https://go.kirto.dev
set -euo pipefail
cd "$(dirname "$0")"

cmp -s index.html 404.html || { echo "404.html differs from index.html; cp index.html 404.html" >&2; exit 1; }

[[ ${1:-} == live ]] || exit 0
for path in apimachinery platform/raftstore flow-broker flow/brokerhost flow-sdk/jobsv1 gate/operator flow-conformance; do
	root=${path%%/*}
	# No -f: a nested path is served by 404.html, and its body is what
	# the go command reads.
	curl -sS "https://go.kirto.dev/${path}?go-get=1" | grep -q "content=\"go.kirto.dev/${root} git " ||
		{ echo "go.kirto.dev/${path}: no go-import tag for ${root}" >&2; exit 1; }
	echo "go.kirto.dev/${path} -> ${root}"
done
