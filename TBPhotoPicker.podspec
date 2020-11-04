#
#  Created by teambition-ios on 2020/7/27.
#  Copyright © 2020 teambition. All rights reserved.
#     

Pod::Spec.new do |s|
  s.name             = 'TBPhotoPicker'
  s.version          = '1.8.4'
  s.summary          = 'A image picker for iOS , written by Swift.'
  s.description      = <<-DESC
  A image picker for iOS , written by Swift.
                       DESC

  s.homepage         = 'https://github.com/teambition/PhotoPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'teambition mobile' => 'teambition-mobile@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/teambition/PhotoPicker.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'PhotoPicker/*.swift', 'PhotoPicker/*.storyboard'

  s.dependency 'TBPhotoBrowser'#, :git => 'https://github.com/teambition/PhotoBrowser.git' 
  # dependency无法指定git
  # PhotoBrowser仓库没有提交到Cocoapods
  # 在项目中pod PhotoPicker后还需要指定:
  # `pod 'PhotoBrowser', :git => 'https://github.com/teambition/PhotoBrowser.git'`

end
