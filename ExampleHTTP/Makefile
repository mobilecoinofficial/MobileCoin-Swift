.PHONY: default
default: setup bootstrap build test

.PHONY: setup
setup:
	bundle install

.PHONY: bootstrap
bootstrap:
	bundle exec pod install

# `--skip_codesigning` passes CODE_SIGNING_ALLOWED=NO, which suppresses the
# codesign step but not provisioning profile resolution: gym builds against
# `generic/platform=iOS` (a device), and Xcode still resolves a profile for any
# target left on automatic signing. The CocoaPods-generated test targets have no
# DEVELOPMENT_TEAM, so that resolution fails before the disabled signing step is
# ever reached. Manual signing skips resolution entirely.
#
# This can't be fixed in the Xcode UI — `pod install` regenerates Pods.xcodeproj.
GYM_FLAGS = --skip_archive --skip_codesigning --xcargs CODE_SIGN_STYLE=Manual

.PHONY: build
build:
	bundle exec fastlane gym \
		--scheme "Unit Tests" \
		$(GYM_FLAGS)
	bundle exec fastlane gym \
		--scheme "Integration NonTransacting Tests" \
		$(GYM_FLAGS)
	bundle exec fastlane gym \
		--scheme "Integration Transacting Tests" \
		$(GYM_FLAGS)
	bundle exec fastlane gym \
		--scheme "Performance Tests" \
		$(GYM_FLAGS)
	bundle exec fastlane gym \
		--scheme "Http Protocol Unit Tests" \
		$(GYM_FLAGS)

.PHONY: test
test:
	bundle exec fastlane scan \
		--scheme "Unit Tests"
	bundle exec fastlane scan \
		--scheme "Performance Tests"
	bundle exec fastlane scan \
		--scheme "Http Protocol Unit Tests"

.PHONY: clean
clean:
	@[ ! -e test_output ] || rm -r test_output

# Maintenance commands

.PHONY: upgrade-deps
upgrade-deps:
	bundle update
	bundle exec pod update
