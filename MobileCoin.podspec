Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "MobileCoin"
  s.version      = "5.0.4"
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

  s.platform     = :ios, "11.0"


  # ――― Subspecs ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.default_subspec = :none

  s.test_spec do |test_spec|
    test_spec.source_files = "Tests/{Unit,Common}/**/*.swift"
    test_spec.resources = [
      "Tests/Common/FixtureData/**/*",
      "Vendor/libmobilecoin/Vendor/mobilecoin/test-vectors/vectors/**/*",
    ]
  end

  s.test_spec 'IntegrationTransactingTests' do |test_spec|
    test_spec.source_files = "Tests/{Common,Integration/Common,Integration/Transacting}/**/*.swift"
    test_spec.resource = "Tests/Common/FixtureData/**/*",
    test_spec.resource = "Tests/Common/Secrets/process_info.json"
  end

  s.test_spec 'IntegrationNonTransactingTests' do |test_spec|
    test_spec.source_files = "Tests/{Common,Util,Integration/Common,Integration/NonTransacting}/**/*.swift"
    test_spec.resource = "Tests/Common/FixtureData/**/*",
    test_spec.resource = "Tests/Common/Secrets/process_info.json"
  end

  s.test_spec 'PerformanceTests' do |test_spec|
    test_spec.source_files = "Tests/{Performance,Common}/**/*.swift"

    test_spec.test_type = :ui
    test_spec.requires_app_host = true
  end

  s.subspec "Core" do |subspec|
    subspec.source_files = [
      "Sources/{Common,GRPC,HTTPS}/**/*.swift",
      "CocoapodsOnly/*.{h,m,swift}",
    ]

    subspec.dependency "LibMobileCoin/Core", "~> 5.0.5"

    subspec.dependency "gRPC-Swift", "1.0.0"
    subspec.dependency "Logging", "~> 1.4"
    subspec.dependency "SwiftNIO", "~> 2.40.0"
    subspec.dependency "SwiftNIOHPACK", "~> 1.16.3"
    subspec.dependency "SwiftNIOHTTP1", "~> 2.40.0"
    subspec.dependency "SwiftProtobuf"

    subspec.test_spec 'ProtocolUnitTests' do |test_spec|
      test_spec.source_files = "Tests/{Common,ProtocolSpecific}/**/*.swift"
      test_spec.resource = "Tests/{ProtocolSpecific/Http,ProtocolSpecific/Grpc}/FixtureData/**/*"
    end

    unless ENV["MC_ENABLE_SWIFTLINT_SCRIPT"].nil?
      subspec.dependency 'SwiftLint'
    end
  end



  s.subspec "CoreHTTP" do |subspec|
    subspec.source_files = [
      "Sources/{Common,HTTPS}/**/*.swift",
      "CocoapodsOnly/*.{h,m,swift}",
      "HTTPOnly/WrappedNIOSSLCertificateValidator.swift"
    ]

    subspec.dependency "LibMobileCoin/CoreHTTP", "~> 5.0.5"

    subspec.dependency "Logging", "~> 1.4"

    subspec.test_spec 'HttpProtocolUnitTests' do |test_spec|
      test_spec.source_files = "Tests/ProtocolSpecific/Http/**/*.swift"
      test_spec.resource = "Tests/ProtocolSpecific/Http/FixtureData/**/*"
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
