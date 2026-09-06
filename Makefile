.PHONY: default
default: build-spm test-spm

# Commands

# `build` and `test` are the names the README and years of muscle memory use.
.PHONY: build
build: build-spm

.PHONY: test
test: test-spm

.PHONY: lint-strict
lint-strict: 
	@tools/swiftlint.sh --strict --quiet

.PHONY: autocorrect
autocorrect: 
	@tools/swiftlint.sh --fix

.PHONY: lint-all
# `lint-docs` is out of this list because no route in this repo installs jazzy,
# so it cannot generate the output it checks. It rejoins when jazzy comes back.
lint-all: lint-strict

# Release

# The changelog's newest released heading is the version source for the tag.
# The pattern takes a `## [x.y.z] - date` line and nothing else, so an
# unreleased or malformed heading yields no version and the recipe says so.
# `git ls-remote --exit-code` exits 2 for an absent tag and 128 when it cannot
# read origin. The branch reads the code, so a failure is never an absence.
.PHONY: tag-release
tag-release:
	VERSION="$$(sed -n 's/^## \[\([0-9][^]]*\)\] - .*/\1/p' CHANGELOG.md | head -1)" && \
		{ [ -n "$$VERSION" ] || { \
			echo "No released version heading in CHANGELOG.md. The newest one must read '## [6.1.0] - 2026-09-01'." >&2; \
			exit 1; \
		}; } && \
		{ git ls-remote --exit-code --tags origin "refs/tags/v$$VERSION" >/dev/null; LOOKUP=$$?; } && \
		if [ $$LOOKUP -eq 0 ]; then \
			echo "Tag v$$VERSION already exists on origin."; \
		elif [ $$LOOKUP -ne 2 ]; then \
			echo "Cannot read the tags on origin. git exited $$LOOKUP and made no tag." >&2; \
			exit $$LOOKUP; \
		elif git rev-parse -q --verify "refs/tags/v$$VERSION" >/dev/null; then \
			echo "Tag v$$VERSION already exists in this clone and not on origin." >&2; \
			exit 1; \
		else \
			git tag "v$$VERSION" && \
			git push origin "refs/tags/v$$VERSION"; \
		fi

# Documentation

# Where jazzy writes, matching `output` in `.jazzy.yaml`. Never `docs/`, which is
# the authored GitBook guide and is tracked.
API_DOCS = output/api-docs

.PHONY: docs
docs:
	jazzy

.PHONY: clean-docs
clean-docs:
	@[ ! -e $(API_DOCS) ] || rm -r $(API_DOCS)

.PHONY: lint-docs
lint-docs:
	@[ -e $(API_DOCS) ] || $(MAKE) docs

	@# Check that there are no categories that start with `Other `, since that signifies that a new public
	@# type was added but was not added to a category in `.jazzy.yaml`
	@[[ "$$( \
		name_regex='^Other (?:Classes|Constants|Enumerations|Extensions|Functions|Protocols|Structures|Type Aliases|Type Definitions)$$'; \
		cat $(API_DOCS)/search.json | jq ".[] \
			| select(has(\"parent_name\") | not) \
			| select(has(\"name\")) \
			| select(.name | test(\"$$name_regex\"))" \
	)" == "" ]] || { echo 'Error: Found one or more public types not categorized in jazzy.'; exit 1; }

# Swiftlint

.PHONY: swiftlint
swiftlint:
	@tools/swiftlint.sh

# Maintenance

.PHONY: generate-local-process-info
generate-local-process-info:
	tools/generate_process_info_jsons.sh

# Builds every target in Package.swift, test targets included. Plain `swift
# build` skips those, so a test target that cannot compile still goes green.
# The test targets declare generated resources, which from tools 6.0 must exist
# before the build, hence the ensure step.
.PHONY: build-spm
build-spm:
	tools/ensure_test_resources.sh
	swift build --build-tests

# The offline test lane. It runs against the sample fixtures, so it needs no
# credential and no network.
# The skips are the suites that do need them: the whole of Tests/Integration,
# whose 22 classes these three patterns cover exactly, and the account funding
# tool, which reads a real seed from process_info.json.
.PHONY: test-spm
test-spm:
	tools/ensure_test_resources.sh
	swift test \
		--skip "IntTests" \
		--skip "MistyswapTests" \
		--skip "TransactionIdempotenceTests" \
		--skip "TestSetupClientTests"

.PHONY: fund-test-wallets-spm
fund-test-wallets-spm:
	tools/ensure_test_resources.sh
	tools/generate_process_info_jsons.sh
	swift test --filter "TestSetupClientTests"

.PHONY: run-all-tests-spm
run-all-tests-spm:
	tools/ensure_test_resources.sh
	tools/generate_process_info_jsons.sh
	tools/generate_secrets_json.sh
	swift test --filter "MobileCoinTests"
