use_frameworks!

workspace 'RintoneProZ.xcworkspace'

def app_pods
    pod 'YPImagePicker'
    pod 'SVProgressHUD'
    pod 'lame'
    pod 'SwiftyDropbox'
    pod 'HSGoogleDrivePicker'
    pod 'SwiftyStoreKit'
    pod 'Firebase/Analytics'
    pod 'Firebase/RemoteConfig'
end

target 'RingtoneProLib' do
    project './RingtoneProLib/RingtoneProLib.xcodeproj'
app_pods
end

target 'RingtoneProZ' do
    project './RingtoneProZ/RingtoneProZ.xcodeproj'
    app_pods
end
