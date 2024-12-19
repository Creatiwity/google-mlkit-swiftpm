PROJECT_ROOT=$(cd $(dirname $0); cd ..; pwd)
PODS_ROOT="./Pods"
PODS_PROJECT="$(PODS_ROOT)/Pods.xcodeproj"
SYMROOT="$(PODS_ROOT)/Build"
IPHONEOS_DEPLOYMENT_TARGET = 16

#bootstrap-cocoapods:
#	@bundle install
#	@bundle exec pod install

bootstrap-builder:
	@cd xcframework-maker && swift build -c release

build-cocoapods: 
	@xcodebuild -project "$(PODS_PROJECT)" \
	-sdk iphoneos \
	-configuration Release -alltargets \
  ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=NO SYMROOT="$(SYMROOT)" \
  CLANG_ENABLE_MODULE_DEBUGGING=NO \
	IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)"
	@xcodebuild -project "$(PODS_PROJECT)" \
	-sdk iphonesimulator \
	-configuration Release -alltargets \
  ONLY_ACTIVE_ARCH=NO ENABLE_TESTABILITY=NO SYMROOT="$(SYMROOT)" \
  CLANG_ENABLE_MODULE_DEBUGGING=NO \
	IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)"

copy-resource-bundle:
	@cp -rf "./Pods/Pods/Build/Release-iphoneos/MLKitFaceDetection/GoogleMVFaceDetectorResources.bundle" "./Sources/FaceDetection/GoogleMVFaceDetectorResources.bundle"

prepare-info-plist:
	@cp -rf "./Resources/MLKitCommon-Info.plist" "./Pods/MLKitCommon/Frameworks/MLKitCommon.framework/Info.plist"
	@cp -rf "./Resources/MLKitFaceDetection-Info.plist" "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/Info.plist"
	@cp -rf "./Resources/MLKitVision-Info.plist" "./Pods/MLKitVision/Frameworks/MLKitVision.framework/Info.plist"
	@cp -rf "./Resources/MLImage-Info.plist" "./Pods/MLImage/Frameworks/MLImage.framework/Info.plist"
	@cp -rf "./Resources/MLKitImageLabeling-Info.plist" "./Pods/MLKitImageLabeling/Frameworks/MLKitImageLabeling.framework/Info.plist"
	@cp -rf "./Resources/MLKitImageLabelingCommon-Info.plist" "./Pods/MLKitImageLabelingCommon/Frameworks/MLKitImageLabelingCommon.framework/Info.plist"
	@cp -rf "./Resources/MLKitObjectDetectionCommon-Info.plist" "./Pods/MLKitObjectDetectionCommon/Frameworks/MLKitObjectDetectionCommon.framework/Info.plist"
	@cp -rf "./Resources/MLKitVisionKit-Info.plist" "./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework/Info.plist"

create-xcframework: build-cocoapods prepare-info-plist
	@vtool -arch arm64 -set-build-version ios 15.5 17.4 -replace -output "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/MLKitFaceDetection" "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/MLKitFaceDetection"
	@vtool -arch x86_64 -set-build-version 7 15.5 17.4 -replace -output "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/MLKitFaceDetection" "./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework/MLKitFaceDetection"
	@vtool -arch arm64 -set-build-version ios 15.5 17.4 -replace -output "./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework/MLKitVisionKit" "./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework/MLKitVisionKit"
	@vtool -arch x86_64 -set-build-version 7 15.5 17.4 -replace -output "./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework/MLKitVisionKit" "./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework/MLKitVisionKit"
	@rm -rf GoogleMLKit
	@xcodebuild -create-xcframework \
		-framework Pods/Pods/Build/Release-iphonesimulator/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-framework Pods/Pods/Build/Release-iphoneos/GoogleToolboxForMac/GoogleToolboxForMac.framework \
		-output GoogleMLKit/GoogleToolboxForMac.xcframework
	@xcodebuild -create-xcframework \
		-framework Pods/Pods/Build/Release-iphonesimulator/GoogleUtilities/GoogleUtilities.framework \
		-framework Pods/Pods/Build/Release-iphoneos/GoogleUtilities/GoogleUtilities.framework \
		-output GoogleMLKit/GoogleUtilities.xcframework
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLImage/Frameworks/MLImage.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitCommon/Frameworks/MLKitCommon.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitVision/Frameworks/MLKitVision.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitFaceDetection/Frameworks/MLKitFaceDetection.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitImageLabeling/Frameworks/MLKitImageLabeling.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitImageLabelingCommon/Frameworks/MLKitImageLabelingCommon.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitObjectDetectionCommon/Frameworks/MLKitObjectDetectionCommon.framework \
	-output GoogleMLKit
	@xcframework-maker/.build/release/make-xcframework \
	-ios ./Pods/MLKitVisionKit/Frameworks/MLKitVisionKit.framework \
	-output GoogleMLKit

archive: create-xcframework
	@cd ./GoogleMLKit/MLKitFaceDetection.xcframework/ios-arm64/MLKitFaceDetection.framework \
	 && mv MLKitFaceDetection MLKitFaceDetection.o \
	 && ar r MLKitFaceDetection MLKitFaceDetection.o \
	 && ranlib MLKitFaceDetection \
	 && rm MLKitFaceDetection.o
	@cd ./GoogleMLKit/MLKitFaceDetection.xcframework/ios-x86_64-simulator/MLKitFaceDetection.framework \
	 && mv MLKitFaceDetection MLKitFaceDetection.o \
	 && ar r MLKitFaceDetection MLKitFaceDetection.o \
	 && ranlib MLKitFaceDetection \
	 && rm MLKitFaceDetection.o
	@cd ./GoogleMLKit/MLKitImageLabeling.xcframework/ios-arm64/MLKitImageLabeling.framework \
	 && mv MLKitImageLabeling MLKitImageLabeling.o \
	 && ar r MLKitImageLabeling MLKitImageLabeling.o \
	 && ranlib MLKitImageLabeling \
	 && rm MLKitImageLabeling.o
	@cd ./GoogleMLKit/MLKitImageLabeling.xcframework/ios-x86_64-simulator/MLKitImageLabeling.framework \
	 && mv MLKitImageLabeling MLKitImageLabeling.o \
	 && ar r MLKitImageLabeling MLKitImageLabeling.o \
	 && ranlib MLKitImageLabeling \
	 && rm MLKitImageLabeling.o
	@cd ./GoogleMLKit \
	 && zip -r MLKitFaceDetection.xcframework.zip MLKitFaceDetection.xcframework \
	 && zip -r MLKitImageLabeling.xcframework.zip MLKitImageLabeling.xcframework \
	 && zip -r GoogleToolboxForMac.xcframework.zip GoogleToolboxForMac.xcframework \
	 && zip -r GoogleUtilities.xcframework.zip GoogleUtilities.xcframework \
	 && zip -r MLImage.xcframework.zip MLImage.xcframework \
	 && zip -r MLKitCommon.xcframework.zip MLKitCommon.xcframework \
	 && zip -r MLKitVision.xcframework.zip MLKitVision.xcframework \
	 && zip -r MLKitVisionKit.xcframework.zip MLKitVisionKit.xcframework \
	 && zip -r MLKitObjectDetectionCommon.xcframework.zip MLKitObjectDetectionCommon.xcframework \
	 && zip -r MLKitImageLabelingCommon.xcframework.zip MLKitImageLabelingCommon.xcframework

checksum: archive
	@swift package compute-checksum ./GoogleMLKit/MLKitFaceDetection.xcframework.zip > ./GoogleMLKit/MLKitFaceDetection.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/GoogleToolboxForMac.xcframework.zip > ./GoogleMLKit/GoogleToolboxForMac.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/GoogleUtilities.xcframework.zip > ./GoogleMLKit/GoogleUtilities.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLImage.xcframework.zip > ./GoogleMLKit/MLImage.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitCommon.xcframework.zip > ./GoogleMLKit/MLKitCommon.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitVision.xcframework.zip > ./GoogleMLKit/MLKitVision.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitVisionKit.xcframework.zip > ./GoogleMLKit/MLKitVisionKit.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitObjectDetectionCommon.xcframework.zip > ./GoogleMLKit/MLKitObjectDetectionCommon.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitImageLabeling.xcframework.zip > ./GoogleMLKit/MLKitImageLabeling.xcframework.zip.sha256
	@swift package compute-checksum ./GoogleMLKit/MLKitImageLabelingCommon.xcframework.zip > ./GoogleMLKit/MLKitImageLabelingCommon.xcframework.zip.sha256
.PHONY:
run: checksum
