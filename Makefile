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

.PHONY: lint
lint: swiftlint

.PHONY: lint-strict
lint-strict: 
	@PATH="./ExampleHTTP/Pods/SwiftLint:$$PATH" swiftlint --strict --quiet

.PHONY: autocorrect
autocorrect: 
	@PATH="./ExampleHTTP/Pods/SwiftLint:$$PATH" swiftlint --fix

.PHONY: lint-all
lint-all: lint lint-podspec lint-docs

.PHONY: publish
publish: tag-release publish-podspec

# Release

.PHONY: tag-release
tag-release:
	VERSION="$$(bundle exec pod ipc spec MobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push origin "refs/tags/v$$VERSION"

# MobileCoin pod

# Dynamic linkage, matching what `pod trunk push` validates at release time.
# pod lint strips linker errors from xcodebuild output; add --verbose to see them.
POD_LINT_FLAGS = --skip-tests

.PHONY: lint-locally-podspec
lint-locally-podspec:
	cd ExampleHTTP; bundle exec pod repo update;
	bundle exec pod lib lint MobileCoin.podspec $(POD_LINT_FLAGS) --allow-warnings

.PHONY: lint-locally-strict-podspec
lint-locally-strict-podspec:
	cd ExampleHTTP; bundle exec pod repo update;
	bundle exec pod lib lint MobileCoin.podspec $(POD_LINT_FLAGS)

.PHONY: lint-podspec
lint-podspec:
	cd ExampleHTTP; bundle exec pod repo update;
	bundle exec pod spec lint MobileCoin.podspec $(POD_LINT_FLAGS)

.PHONY: publish-podspec
publish-podspec:
	cd ExampleHTTP; bundle exec pod repo update;
	bundle exec pod trunk push MobileCoin.podspec --skip-tests

# Documentation

.PHONY: docs
docs:
	bundle exec jazzy

.PHONY: clean-docs
clean-docs:
	@[ ! -e docs ] || rm -r docs

.PHONY: lint-docs
lint-docs:
	@[ -e docs ] || $(MAKE) docs

	@# Check that there are no categories that start with `Other `, since that signifies that a new public
	@# type was added but was not added to a category in `.jazzy.yaml`
	@[[ "$$( \
		name_regex='^Other (?:Classes|Constants|Enumerations|Extensions|Functions|Protocols|Structures|Type Aliases|Type Definitions)$$'; \
		cat docs/search.json | jq ".[] \
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
