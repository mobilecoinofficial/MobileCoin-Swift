#!/bin/bash

MODE=$1

echo $@

SWIFT_LINT="$(git rev-parse --show-toplevel)/ExampleHTTP/Pods/SwiftLint/swiftlint"

# Change directory to repo root
cd "$(git rev-parse --show-toplevel)" || exit;

if [[ -e "${SWIFT_LINT}" ]]; then
    # Export files in SCRIPT_INPUT_FILE_$count to lint against later
    count=0
    while IFS= read -r file_path; do
        export SCRIPT_INPUT_FILE_$count="$file_path"
        count=$((count + 1))
    done < <(git diff --name-only --cached --diff-filter=d | grep ".swift$")
    export SCRIPT_INPUT_FILE_COUNT=$count

    if [ "$count" -eq 0 ]; then
        echo "No files to lint!"
        exit 0
    fi

    echo "Found $count files! $MODE now.."
    $SWIFT_LINT $MODE --use-script-input-files --strict --config "$(git rev-parse --show-toplevel)/.swiftlint.yml"
    RESULT=$? # swiftline exit value is number of errors

    if [ $RESULT -eq 0 ]; then
        echo "🎉  Well done. No violation."
    fi
    exit $RESULT
else
    echo "⚠️  WARNING: SwiftLint not found in $SWIFT_LINT"
    echo "⚠️  You might want to edit .git/hooks/pre-commit to locate your swiftlint"
    exit 0
fi
