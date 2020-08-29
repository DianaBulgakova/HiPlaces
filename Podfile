source 'https://github.com/CocoaPods/Specs.git'

project_target_version = '13.0'
platform :ios, :deployment_target => project_target_version

use_frameworks!
inhibit_all_warnings!

target 'HiPlaces' do
  pod 'SwiftLint'
  pod 'SwiftClasses', :git => 'https://github.com/ubank/SwiftClasses.git'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = project_target_version
    end
  end
end
