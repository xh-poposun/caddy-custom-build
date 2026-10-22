#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -f versions.env ]]; then
  echo "Missing versions.env; copy versions.env.example and set fixed versions." >&2
  exit 1
fi
# versions.env is repository-maintained configuration.
# shellcheck disable=SC1091
source versions.env

for name in CADDY_VERSION L4_VERSION JSONC_VERSION; do
  value="${!name:-}"
  if [[ -z "$value" || "$value" == *REPLACE_* || "$value" == "latest" ]]; then
    echo "$name must be set to a fixed, reviewed version" >&2
    exit 1
  fi
done

mkdir -p dist
export CGO_ENABLED=0
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
"$(go env GOPATH)/bin/xcaddy" build "$CADDY_VERSION" \
  --with "github.com/mholt/caddy-l4@$L4_VERSION" \
  --with "github.com/caddyserver/jsonc-adapter@$JSONC_VERSION" \
  --output "$ROOT/dist/caddy"

"$ROOT/dist/caddy" version
"$ROOT/dist/caddy" list-modules > "$ROOT/dist/modules.txt"
grep -Eq '^layer4($|\\.)' "$ROOT/dist/modules.txt" || {
  echo "Expected caddy-l4 module not found" >&2; exit 1;
}
grep -Eq 'jsonc' "$ROOT/dist/modules.txt" || {
  echo "Expected JSONC adapter module not found" >&2; exit 1;
}
(cd dist && sha256sum caddy modules.txt > SHA256SUMS)
go version -m dist/caddy > dist/build-info.txt
echo "Build complete: $ROOT/dist/caddy"
