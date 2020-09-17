# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GitHubUsers' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GitHubUsers
  pod 'Kingfisher'
  pod 'Kingfisher/SwiftUI'
  pod 'lottie-ios'
  pod 'SwiftLint'
  pod 'Alamofire'

end

# Swiftlint warning fix - sets min target for PODS to 9
post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
end
