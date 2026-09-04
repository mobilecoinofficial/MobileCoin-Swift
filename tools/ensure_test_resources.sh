#!/bin/bash
# Create the gitignored test resources from their committed samples when they
# are absent. Package.swift declares both, and from swift-tools-version 6.0 a
# declared resource that does not exist is a build error, not a warning.
#
# Never overwrites. generate_secrets_json.sh and generate_process_info_jsons.sh
# write the real values over whatever is here.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

for sample in \
    "$REPO_ROOT/Tests/Common/Secrets/secrets.json.sample" \
    "$REPO_ROOT/tools/TestSetupClient/TestSetupClientTests/process_info.json.sample"
do
    target="${sample%.sample}"
    if [ ! -f "$target" ]; then
        cp "$sample" "$target"
        echo "created ${target#"$REPO_ROOT/"} from its sample"
    fi
done
