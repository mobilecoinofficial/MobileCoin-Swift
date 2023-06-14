#!/bin/bash

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/scripts/secrets_manager"

# execute check_dependencies silently, only report errors
# and exit if any dependencies are installed
check_dependencies -exit_on_install > /dev/null

TEST_ACCOUNT_SEED="$(security find-generic-password -w -s swift-repo-public | head -c32 | base64)"

# test account seed will be 32 bytes of your contribution key
jq --null-input \
  --arg TEST_ACCOUNT_SEED "$TEST_ACCOUNT_SEED" \
  '{ "testAccountSeed": $TEST_ACCOUNT_SEED }' > $REPO_ROOT/Tests/Common/Secrets/process_info.json

lookup() {
if [[ -z "$1" ]] ; then
  echo ""
else
  awk -v "id=$1" 'BEGIN { FS = "=" } $1 == id { print $2 ; exit }' $2
fi
}

SRC_ACCT_ENTROPY_STRING=$(lookup SRC_ACCT_ENTROPY_STRING <(decrypt_secrets| sed 's/export //'))

jq --null-input \
  --arg TEST_ACCOUNT_SEED "$TEST_ACCOUNT_SEED" \
  --arg SRC_ACCT_ENTROPY_STRING "$(echo $SRC_ACCT_ENTROPY_STRING | xargs)" \
  '{ "testAccountSeed": $TEST_ACCOUNT_SEED, "srcAcctEntropyString": $SRC_ACCT_ENTROPY_STRING }' > $REPO_ROOT/tools/TestSetupClient/TestSetupClientTests/process_info.json
