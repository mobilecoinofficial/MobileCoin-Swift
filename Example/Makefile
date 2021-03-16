.PHONY: default
default: setup bootstrap build test

.PHONY: setup
setup:
	bundle install

.PHONY: bootstrap
bootstrap:
	bundle exec pod install

.PHONY: build
build:
	bundle exec fastlane gym \
		--scheme "Unit Tests" \
		--skip_archive \
		--skip_codesigning
	bundle exec fastlane gym \
		--scheme "Integration Tests" \
		--skip_archive \
		--skip_codesigning
	bundle exec fastlane gym \
		--scheme "Performance Tests" \
		--skip_archive \
		--skip_codesigning

.PHONY: test
test:
	bundle exec fastlane scan \
		--scheme "Unit Tests"
	bundle exec fastlane scan \
		--scheme "Performance Tests"

.PHONY: clean
clean:
	@[ ! -e test_output ] || rm -r test_output

# Maintenance commands

.PHONY: upgrade-deps
upgrade-deps:
	bundle update
	bundle exec pod update
