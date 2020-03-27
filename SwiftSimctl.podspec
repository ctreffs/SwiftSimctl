#
#  Be sure to run `pod spec lint SwiftSimctl.podspec" to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it"s definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "SwiftSimctl"
  spec.version      = "0.1.0"
  spec.summary      = "Swift client-server tool to call xcrun simctl from your simulator. Automate push notification testing!"
  spec.description  = <<-DESC
   This is a small tool (SimctlCLI) and library (Simctl), written in Swift, to automate xcrun simctl commands for Simulator in unit and UI tests.
   It enables, among other things, reliable fully automated testing of Push Notifications with dynamic content, and driven by a UI Test you control.
                   DESC

  spec.homepage     = "https://github.com/ctreffs/SwiftSimctl"
  spec.screenshots  = "https://raw.githubusercontent.com/ctreffs/SwiftSimctl/master/docs/SimctlExample.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are "MIT", "BSD" and "Apache License, Version 2.0".
  #

  spec.license = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you"d rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "Christian Treffs" => "ctreffs@gmail.com" }
  spec.social_media_url   = "https://twitter.com/chrisdailygrind"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # spec.platform     = :ios
  # spec.platform     = :ios, "5.0"

  #  When using multiple platforms
  spec.osx.deployment_target = "10.12"
  spec.ios.deployment_target = "11.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  spec.swift_version = "5.2"
  spec.source       = { :git => "https://github.com/ctreffs/SwiftSimctl.git", :tag => "#{spec.version}" }
  

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #
  spec.source_files  = "Sources/**/*.swift"
  spec.exclude_files = ".swift-version"
  # spec.public_header_files = "Classes/**/*.h"
  spec.requires_arc = true

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don"t preserve
  #  non-essential files like tests, examples and documentation.
  #

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  spec.xcconfig       = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/" }

  spec.preserve_paths = "bin/*"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #
  
  
  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  #spec.osx.deployment_target = "10.12"
  #spec.ios.deployment_target = "11.0"

  spec.default_subspecs = "Simctl"

  spec.subspec "SimctlShared" do |sp|
    sp.osx.deployment_target = "10.12"
    sp.ios.deployment_target = "11.0"
    
    sp.source_files = "Sources/SimctlShared/**/*.swift"
    sp.framework  = "Foundation"
  end

  spec.subspec "SimctlCLI" do |sp|
    sp.osx.deployment_target = "10.12"
    
    sp.dependency "SwiftSimctl/SimctlShared"
    sp.dependency "Swifter", "1.4.7"
    sp.dependency "ShellOut", "~> 2.0.0"

    sp.source_files = "Sources/SimctlCLI/**/*.swift"

    sp.framework = "AppKit"
    
  end

  spec.subspec "Simctl" do |sp|
    sp.ios.deployment_target = "11.0"

    sp.dependency "SwiftSimctl/SimctlShared"
    sp.dependency "Swifter", "1.4.7"

    sp.source_files = "Sources/Simctl/**/*.swift"

    sp.framework  = "UIKit"
  end


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"


end
