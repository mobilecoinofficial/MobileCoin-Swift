.PHONY: default
default: setup bootstrap build test

# Commands

.PHONY: setup
setup:
	bundle install
	@$(MAKE) --directory=Example setup

.PHONY: bootstrap
bootstrap:
	@$(MAKE) --directory=Example bootstrap

.PHONY: build
build:
	@$(MAKE) --directory=Example build

.PHONY: test
test:
	@$(MAKE) --directory=Example test

.PHONY: clean
clean: clean-docs
	@$(MAKE) --directory=Example clean

.PHONY: lint
lint: swiftlint

.PHONY: lint-all
lint-all: lint lint-circleci lint-podspec lint-docs

.PHONY: publish
publish: tag-release publish-podspec

# Release

.PHONY: tag-release
tag-release:
	VERSION="$$(bundle exec pod ipc spec MobileCoin.podspec | jq -r '.version')" && \
		git tag "v$$VERSION" && \
		git push git@github.com:mobilecoinofficial/MobileCoin-Swift.git "refs/tags/v$$VERSION"

# MobileCoin pod

.PHONY: lint-podspec
lint-podspec:
	bundle exec pod spec lint MobileCoin.podspec --skip-tests

.PHONY: publish-podspec
publish-podspec:
	bundle exec pod trunk push MobileCoin.podspec --skip-tests

# CircleCI

.PHONY: install-circleci
install-circleci:
	brew install circleci

.PHONY: lint-circleci
lint-circleci:
	@command -v circleci >/dev/null || $(MAKE) install-circleci
	circleci config validate

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

.PHONY: autocorrect
autocorrect:
	@PATH="./Example/Pods/SwiftLint:$$PATH" swiftlint autocorrect

.PHONY: swiftlint
swiftlint:
	@PATH="./Example/Pods/SwiftLint:$$PATH" swiftlint

# Maintenance

.PHONY: upgrade-deps
upgrade-deps:
	bundle update
	$(MAKE) -C Example upgrade-deps
