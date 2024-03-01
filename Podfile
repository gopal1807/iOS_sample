platform :ios, '14.0'
use_frameworks!

def shared_pods
  pod 'GoogleSignIn', '~> 6.0'
  pod 'FirebaseMessaging', '~> 8.8'
  pod 'FirebaseAnalytics', '~> 8.8'
  pod 'SDWebImageSwiftUI', '~> 2.0'
  pod 'Stripe', '~> 21.8'
end

project = Xcodeproj::Project.open "./FunnyCow.xcodeproj"
targets = project.targets.map { |target| target.name }
#  targets.delete_if { |target| target == "Pockets"}
targets.each do |name|
  target name do
#    shared_pods
  end
end

