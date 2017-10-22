target 'ShowlistDC' do
use_frameworks!
	platform :ios, '9.0'
	inherit! :search_paths
	pod 'JTAppleCalendar', '~> 6.1.6'
	pod 'RealmSwift'
	pod 'FLEX', :configurations => ['Debug']
	post_install do |installer|
  		installer.pods_project.targets.each do |target|
    		target.build_configurations.each do |config|
      			config.build_settings['SWIFT_VERSION'] = '3.1'
    		end
  		end
	end
end

