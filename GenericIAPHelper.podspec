#
#  Be sure to run `pod spec lint GenericIAPHelper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GenericIAPHelper"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of GenericIAPHelper."

  spec.description  = <<-DESC 
                    IOS In App Purchase Helper Framework to complete In App Purchases.
                   DESC

  spec.homepage     = "https://github.com/KGS-Global/IAPHelper"
  
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "KGS-Global" => "kgs.bitbucket.manager@gmail.com" }
  
  spec.platform     = :ios, "14.0"
  spec.source       = { :git => "https://github.com/KGS-Global/IAPHelper.git", :tag => "#{spec.version}" }

  spec.source_files  = "GenericIAPHelper", "GenericIAPHelper/**/*.{h,m,swift}"
  spec.resources     = "GenericIAPHelper/**/*.{png,xib,plist,xcassets}"

  spec.swift_version = "5.0"

end
