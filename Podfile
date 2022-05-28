use_frameworks!

workspace 'RintoneProZ.xcworkspace'

def app_pods
  pod "SoundWave"
  pod 'YPImagePicker'
  pod 'Alamofire', '~> 4.8.2'
  pod 'PKHUD'
  pod 'SDWebImage'
  pod "Texture"
  pod 'Firebase/Analytics'
  pod 'SwiftyStoreKit'
  pod 'Firebase/RemoteConfig'
  pod 'SwiftyDropbox'
  pod "RxMusicPlayer"
  pod 'Google-Mobile-Ads-SDK'
end

target 'RingtoneProLib' do
    project './RingtoneProLib/RingtoneProLib.xcodeproj'
app_pods
end

target 'RingtoneProZ' do
    project './RingtoneProZ/RingtoneProZ.xcodeproj'
    app_pods
end
