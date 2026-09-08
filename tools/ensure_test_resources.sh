#!/bin/bash
# Create the gitignored test resources from their committed samples when they
# are absent or empty. Package.swift declares all three, and from
# swift-tools-version 6.0 the build fails on a declared resource that is
# missing.
#
# Never overwrites a file holding bytes. generate_secrets_json.sh and
# generate_process_info_jsons.sh write the real values over whatever is here.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

for sample in \
    "$REPO_ROOT/Tests/Common/Secrets/secrets.json.sample" \
    "$REPO_ROOT/Tests/Common/Secrets/process_info.json.sample" \
    "$REPO_ROOT/tools/TestSetupClient/TestSetupClientTests/process_info.json.sample"
do
    target="${sample%.sample}"
    if [ ! -s "$target" ]; then
        cp "$sample" "$target"
        echo "created ${target#"$REPO_ROOT/"} from its sample"
    fi
done
