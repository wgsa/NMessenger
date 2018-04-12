# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'nMessenger' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for nMessenger
#  pod 'AsyncDisplayKit', '~> 1.9.92'
  pod 'AsyncDisplayKit', :git => 'https://github.com/wgsa/AsyncDisplayKit.git'
  pod 'ImageViewer', :git => 'https://github.com/wgsa/ImageViewer.git'
  target 'nMessengerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'nMessengerUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  # Configure installed pods to use Swift 3.0
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '3.0'
          end
      end
  end

end
