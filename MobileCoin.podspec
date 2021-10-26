Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "MobileCoin"
  s.version      = "1.2.0-pre2"
  s.summary      = "A library for communicating with MobileCoin network"

  s.author       = "MobileCoin"
  s.homepage     = "https://www.mobilecoin.com/"

  s.license      = { :type => "GPLv3" }

  s.source       = { 
    :git => "https://github.com/mobilecoinofficial/MobileCoin-Swift.git",
    :tag => "v#{s.version}",
    :submodules => true
  }


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform     = :ios, "10.0"


  # ――― Subspecs ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.default_subspec = "Core"

  s.subspec "Core" do |subspec|
    subspec.source_files = [
      "Sources/**/*.{h,m,swift}",
    ]

    subspec.dependency "LibMobileCoin", "~> 1.2.0-pre2"

    subspec.dependency "gRPC-Swift"
    subspec.dependency "Logging", "~> 1.4"
    subspec.dependency "SwiftNIO"
    subspec.dependency "SwiftNIOHPACK"
    subspec.dependency "SwiftNIOHTTP1"
    subspec.dependency "SwiftProtobuf"

    subspec.test_spec do |test_spec|
      test_spec.source_files = "Tests/{Unit,Common}/**/*.swift"
      test_spec.resources = [
        "Tests/Common/FixtureData/**/*",
        "Vendor/libmobilecoin-ios-artifacts/Vendor/mobilecoin/test-vectors/vectors/**/*",
      ]
    end

    subspec.test_spec 'IntegrationTests' do |test_spec|
      test_spec.source_files = "Tests/{Integration,Common}/**/*.swift"
      test_spec.resource = "Tests/Common/FixtureData/**/*"
    end

    subspec.test_spec 'PerformanceTests' do |test_spec|
      test_spec.source_files = "Tests/{Performance,Common}/**/*.swift"

      test_spec.test_type = :ui
      test_spec.requires_app_host = true
    end

    unless ENV["MC_ENABLE_SWIFTLINT_SCRIPT"].nil?
      subspec.dependency 'SwiftLint'
    end
  end


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.swift_version = "5.2"

  # The LibMobileCoin podspec specifies these xcconfig values in
  # `user_target_xcconfig`, however that only applies to app targets, not to the
  # intermediary frameworks. These must be speicifed here for CocoaPods to set them
  # on the framework target and any testspec targets for this pod.
  pod_target_xcconfig = {
    "GCC_OPTIMIZATION_LEVEL" => "z",
    "LLVM_LTO" => "YES",
    "ENABLE_BITCODE" => "YES",
    "SUPPORTS_MACCATALYST" => "YES",
    # The LibMobileCoin vendored binary doesn't include support for 32-bit
    # architectures or for arm64 iphonesimulator.
    "VALID_ARCHS[sdk=iphoneos*]" => "arm64",
    "VALID_ARCHS[sdk=iphonesimulator*]" => "x86_64 arm64",
  }

  unless ENV["MC_ENABLE_WARN_LONG_COMPILE_TIMES"].nil?
    pod_target_xcconfig['OTHER_SWIFT_FLAGS'] = '-Xfrontend -warn-long-function-bodies=500'
    pod_target_xcconfig['OTHER_SWIFT_FLAGS'] += ' -Xfrontend -warn-long-expression-type-checking=500'
  end

  s.pod_target_xcconfig = pod_target_xcconfig

  unless ENV["MC_ENABLE_SWIFTLINT_SCRIPT"].nil?
    s.script_phases = [
      {
        :name => "Run SwiftLint",
        :execution_position => :any,
        :script => <<~'EOS'
          SWIFTLINT="${PODS_ROOT}/SwiftLint/swiftlint"
          if which ${SWIFTLINT} >/dev/null; then
            cd "${PODS_TARGET_SRCROOT}"
            ${SWIFTLINT}
          else
            echo "warning: SwiftLint not installed, run \`pod install\`"
          fi
        EOS
      },
    ]
  end
end

