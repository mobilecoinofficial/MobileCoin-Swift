#!/bin/bash

# Checks the `lookup` helper in scripts/secrets_manager against a synthetic
# payload. It decrypts nothing, so it runs without any age key.

set -eo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/scripts/secrets_manager"

PAYLOAD='DEV_NETWORK_AUTH_USERNAME=alice
DYNAMIC_FOG_AUTHORITY_SPKI="MIIBIjANBgkq=="
SRC=aGVsbG8=
SRC_ACCT_ENTROPY_STRING=one two three
DUP=first
DUP=second
EMPTYVAL=

BAREKEY'

FAILURES=0

expect_value() {
  local key="$1" want="$2" got
  got="$(lookup "$key" "$PAYLOAD" 2>/dev/null)" || got="<lookup failed>"
  if [[ "$got" != "$want" ]]; then
    echo "lookup $key: want [$want], got [$got]" >&2
    FAILURES=$((FAILURES + 1))
  fi
}

# The generators read every value as `lookup KEY "$SECRETS" | xargs`.
expect_trimmed() {
  local key="$1" want="$2" got
  got="$(lookup "$key" "$PAYLOAD" 2>/dev/null | xargs)" || got="<lookup failed>"
  if [[ "$got" != "$want" ]]; then
    echo "lookup $key | xargs: want [$want], got [$got]" >&2
    FAILURES=$((FAILURES + 1))
  fi
}

expect_failure() {
  local key="$1" err status=0
  err="$(lookup "$key" "$PAYLOAD" 2>&1 >/dev/null)" || status=$?
  if [[ "$status" -eq 0 ]]; then
    echo "lookup $key: want a non-zero status, got 0" >&2
    FAILURES=$((FAILURES + 1))
  elif [[ "$err" != *"no $key in the decrypted payload"* ]]; then
    echo "lookup $key: want a message naming the key, got [$err]" >&2
    FAILURES=$((FAILURES + 1))
  fi
}

expect_value DEV_NETWORK_AUTH_USERNAME alice
expect_value DYNAMIC_FOG_AUTHORITY_SPKI '"MIIBIjANBgkq=="'
expect_value SRC 'aGVsbG8='
expect_trimmed DYNAMIC_FOG_AUTHORITY_SPKI 'MIIBIjANBgkq=='
expect_value SRC_ACCT_ENTROPY_STRING 'one two three'
expect_value DUP first
expect_value EMPTYVAL ''
expect_failure SRC_ACCT
expect_failure ABSENT
expect_failure BAREKEY
expect_failure ''

if [[ "$FAILURES" -ne 0 ]]; then
  echo "$FAILURES lookup checks failed" >&2
  exit 1
fi

echo "lookup checks passed"
