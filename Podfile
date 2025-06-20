install! 'cocoapods', :disable_input_output_paths => true
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

target 'ArticleApp' do
  # Pods for ArticleApp
  pod 'RxSwift', '~> 6.0'
  pod 'RxCocoa', '~> 6.0'

  target 'ArticleAppTests' do
    inherit! :search_paths
    pod 'RxBlocking', '~> 6.0'
    pod 'RxTest', '~> 6.0'
  end

  target 'ArticleAppUITests' do
    # Pods for testing
  end

end
