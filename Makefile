.PHONY: default
default: setup bootstrap build test

# Commands

.PHONY: setup
setup:
	bundle install
	@$(MAKE) --directory=ExampleHTTP setup

.PHONY: bootstrap
bootstrap:
	@$(MAKE) --directory=ExampleHTTP bootstrap

.PHONY: build
build:
	@$(MAKE) --directory=ExampleHTTP build

.PHONY: test
test:
	@$(MAKE) --directory=ExampleHTTP test

.PHONY: lock
lock:
	$(info making locks with setup & boostrap)
	$(info ExampleHTTP setup)
	@$(MAKE) --directory=ExampleHTTP setup
	$(info ExampleHTTP bootstrap)
	@$(MAKE) --directory=ExampleHTTP bootstrap

.PHONY: setup-example-http
setup-example-http:
	bundle install
	@$(MAKE) --directory=ExampleHTTP setup

.PHONY: bootstrap-example-http
bootstrap-example-http:
	@$(MAKE) --directory=ExampleHTTP bootstrap

.PHONY: build-example-http
build-example-http:
	@$(MAKE) --directory=ExampleHTTP build

.PHONY: test-example-http
test-example-http:
	@$(MAKE) --directory=ExampleHTTP test

.PHONY: clean-example-http
clean-example-http: clean-docs
	@$(MAKE) --directory=ExampleHTTP clean

.PHONY: lint-strict
lint-strict: 
	@PATH="./ExampleHTTP/Pods/SwiftLint:$$PATH" swiftlint --strict --quiet

.PHONY: autocorrect
autocorrect: 
	@PATH="./ExampleHTTP/Pods/SwiftLint:$$PATH" swiftlint --fix

.PHONY: lint-all
# `lint-docs` is out of this list because the Gemfile keeps jazzy commented out,
# so it cannot generate the output it checks. It rejoins when jazzy comes back.
lint-all: lint-strict

# Release

# The podspec is the version source for the tag. `jq -e` stops a null,
# unreadable or non-string version, and `[ -n ]` stops an empty string.
# `git ls-remote --exit-code` exits 2 for an absent tag and 128 when it cannot
# read origin. The branch reads the code, so a failure is never an absence.
.PHONY: tag-release
tag-release:
	VERSION="$$(bundle exec pod ipc spec MobileCoin.podspec | jq -er '.version | select(type == "string")')" && \
		[ -n "$$VERSION" ] && \
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
	bundle exec jazzy

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
	@PATH="./ExampleHTTP/Pods/SwiftLint:$$PATH" swiftlint

# Maintenance

.PHONY: upgrade-deps
upgrade-deps:
	bundle update
	$(MAKE) -C ExampleHTTP upgrade-deps

.PHONY: generate-local-process-info
generate-local-process-info:
	tools/generate_process_info_jsons.sh

# Builds every target in Package.swift, test targets included. Plain `swift
# build` skips those, so a test target that cannot compile still goes green.
# Unlike `run-all-tests-spm` this needs no secrets, so it is the one SPM check
# CI can run today. The test targets declare generated resources, which from
# tools 6.0 must exist before the build, hence the ensure step.
.PHONY: build-spm
build-spm:
	tools/ensure_test_resources.sh
	swift build --build-tests

# The offline test lane, and the parity replacement for the ExampleHTTP
# schemes. It runs every suite those schemes compiled, against the sample
# fixtures, so it needs no credential and no network.
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
