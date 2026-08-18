.PHONY: default
default: setup bootstrap build test

.PHONY: setup
setup:
	bundle install

.PHONY: bootstrap
bootstrap:
	bundle exec pod install

# The CocoaPods-generated test targets have no DEVELOPMENT_TEAM, so Xcode's
# automatic-signing profile resolution fails target validation for gym and scan
# ("requires selecting either a development team or a provisioning profile").
# Manual signing skips resolution, and nothing here needs a real signature:
# gym only compiles and the simulator doesn't enforce signatures.
# Not fixable in the Xcode UI because `pod install` regenerates Pods.xcodeproj.
CODESIGN_XCARGS = CODE_SIGN_STYLE=Manual CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

# scan needs an explicit destination. Without one xcodebuild resolves a
# platform per target, and the SUPPORTS_MACCATALYST mismatch between the
# MobileCoin and LibMobileCoin podspecs splits the build across Mac Catalyst
# and iphoneos, failing with `no such module 'LibMobileCoin'`. gym always
# passes `-destination generic/platform=iOS`, so it is unaffected.
IOS_SIM_DEVICE ?= iPhone 16

GYM_FLAGS = --skip_archive --skip_codesigning --xcargs "$(CODESIGN_XCARGS)"
# Without ensure_devices_found a device mismatch falls back to scan's
# default_os_version lookup, which crashes opaquely on Xcode 26.
SCAN_FLAGS = --device "$(IOS_SIM_DEVICE)" --ensure_devices_found --xcargs "$(CODESIGN_XCARGS)"

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
