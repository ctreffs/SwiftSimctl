# frozen_string_literal: true

Pod::Spec.new do |spec|
  spec.name = 'SimctlCLI'
  spec.version = '0.2.0'
  spec.summary = 'Swift client-server tool to call xcrun simctl from your simulator. Automate push notification testing!'
  spec.description = <<-DESC
   This is a small tool (SimctlCLI) and library (Simctl), written in Swift, to automate xcrun simctl commands for Simulator in unit and UI tests.
   It enables, among other things, reliable fully automated testing of Push Notifications with dynamic content, and driven by a UI Test you control.
  DESC
  spec.homepage = 'https://github.com/ctreffs/SwiftSimctl'
  spec.screenshots = 'https://raw.githubusercontent.com/ctreffs/SwiftSimctl/master/docs/SimctlExample.gif'
  spec.author = { 'Christian Treffs' => 'ctreffs@gmail.com' }
  spec.social_media_url = 'https://twitter.com/chrisdailygrind'
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.source = { git: 'https://github.com/ctreffs/SwiftSimctl.git', tag: spec.version.to_s }
  spec.swift_version = '5.2'
  spec.requires_arc = true
  spec.exclude_files = '.swift-version'
  spec.preserve_paths = 'bin/*'
  spec.resource_bundles = {
    'SimctlCLI' => ['bin/SimctlCLI']
  }
  spec.source_files = 'Sources/SimctlCLI/**/*.swift'
  spec.osx.dependency 'SimctlShared', '~> 0.2.0'
  spec.osx.dependency 'ShellOut', '~> 2.0.0'
  spec.osx.dependency 'Swifter', '~> 1.4.7'
  spec.osx.deployment_target = '10.12'
  spec.osx.framework = 'AppKit'
end
