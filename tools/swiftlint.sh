#!/bin/bash
# Runs the pinned SwiftLint, downloading it first when it is absent.
#
# The version matches the one ExampleHTTP's Pods vendored, so the rule set and
# the results do not move. SwiftLint 0.58.2 reports 219 violations on this tree.
set -euo pipefail

VERSION="0.47.1"
SHA256="61d335766a39ba8fa499017a560950bd9fa0b0e5bc318559a9c1c7f4da679256"
URL="https://github.com/realm/SwiftLint/releases/download/$VERSION/portable_swiftlint.zip"

REPO_ROOT="$(git rev-parse --show-toplevel)"
BIN="$REPO_ROOT/.tools/swiftlint/swiftlint"

install_swiftlint() {
    local tmp
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN

    curl --fail --location --silent --show-error --output "$tmp/swiftlint.zip" "$URL"

    if ! printf '%s  %s\n' "$SHA256" "$tmp/swiftlint.zip" | shasum -a 256 --check --status; then
        echo "SwiftLint $VERSION does not match the pinned sha256. Refusing to install it." >&2
        return 1
    fi

    unzip -oq "$tmp/swiftlint.zip" -d "$tmp/unpacked"
    mkdir -p "$(dirname "$BIN")"
    cp "$tmp/unpacked/swiftlint" "$BIN"
    chmod +x "$BIN"
    echo "installed SwiftLint $VERSION in ${BIN#"$REPO_ROOT/"}" >&2
}

# `version` on a binary of the wrong version reinstalls, so a bumped pin takes
# effect without a manual clean.
if [ ! -x "$BIN" ] || [ "$("$BIN" version 2>/dev/null || true)" != "$VERSION" ]; then
    install_swiftlint
fi

exec "$BIN" "$@"
