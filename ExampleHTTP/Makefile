.PHONY: default
default: setup bootstrap build test

.PHONY: setup
setup:
	bundle install

.PHONY: bootstrap
bootstrap:
	bundle exec pod install

# Xcode resolves a provisioning profile for any target left on automatic signing
# during target validation, before any signing is attempted and regardless of
# destination — gym builds against `generic/platform=iOS`, scan against a
# simulator, and both hit it. The CocoaPods-generated test targets have no
# DEVELOPMENT_TEAM, so resolution fails with:
#
#   Signing for "MobileCoin-Unit-Tests" requires selecting either a development
#   team or a provisioning profile.
#
# Manual signing skips resolution. Nothing here needs a real signature: gym only
# compiles, and the simulator doesn't enforce code signatures.
#
# This can't be fixed in the Xcode UI — `pod install` regenerates Pods.xcodeproj.
CODESIGN_XCARGS = CODE_SIGN_STYLE=Manual CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

GYM_FLAGS = --skip_archive --skip_codesigning --xcargs "$(CODESIGN_XCARGS)"
SCAN_FLAGS = --xcargs "$(CODESIGN_XCARGS)"

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
		--scheme "Unit Tests" \
		$(SCAN_FLAGS)
	bundle exec fastlane scan \
		--scheme "Performance Tests" \
		$(SCAN_FLAGS)
	bundle exec fastlane scan \
		--scheme "Http Protocol Unit Tests" \
		$(SCAN_FLAGS)

.PHONY: clean
clean:
	@[ ! -e test_output ] || rm -r test_output

# Maintenance commands

.PHONY: upgrade-deps
upgrade-deps:
	bundle update
	bundle exec pod update
