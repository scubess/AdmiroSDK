
rm -rf Build
mkdir -p Release/

rm -rf Release/AdmiroSDK.xcframework/

xcrun xcodebuild -target AdmiroSDK -scheme AdmiroSDK -configuration Release -sdk iphonesimulator
xcrun xcodebuild -target AdmiroSDK -scheme AdmiroSDK -configuration Release -sdk iphoneos
	
xcodebuild -create-xcframework -output Release/AdmiroSDK.xcframework \
	-framework Build/Products/Release-iphoneos/AdmiroSDK.framework \
	-framework Build/Products/Release-iphonesimulator/AdmiroSDK.framework

