FRAMEWORK_NAME="MyFramework"

echo "🔨 Creating XCFramework"

increment_build_number () {
    xcrun agvtool next-version -all
}
increment_build_number

cd StubVersionOfMyFrameworkThatDoesNotSupportSimulator && xcodebuild archive -scheme $FRAMEWORK_NAME -arch x86_64 -configuration Release -destination="generic/platform=iOS Simulator" -archivePath ../build/x86_64-simulator.xcarchive -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES && cd -
cd StubVersionOfMyFrameworkThatDoesNotSupportSimulator && xcodebuild archive -scheme $FRAMEWORK_NAME -arch arm64 -configuration Release -destination="generic/platform=iOS Simulator" -archivePath ../build/arm64-simulator.xcarchive -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES && cd -
cd MyFrameworkThatDoesNotSupportSimulator && xcodebuild archive -scheme $FRAMEWORK_NAME -arch arm64 -configuration Release -destination="generic/platform=iOS" -archivePath ../build/arm64.xcarchive -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES && cd -

mkdir -p "build/x86_64_arm64-simulator-generated/${FRAMEWORK_NAME}.framework"
rsync -a "build/x86_64-simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework"  "build/x86_64_arm64-simulator-generated/"
rsync -a "build/arm64-simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework"  "build/x86_64_arm64-simulator-generated/"
lipo -create "build/arm64-simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" "build/x86_64-simulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}" -output "build/x86_64_arm64-simulator-generated/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"

xcodebuild -create-xcframework \
-framework build/x86_64_arm64-simulator-generated/$FRAMEWORK_NAME.framework \
-debug-symbols "$(pwd -P)"/build/x86_64-simulator.xcarchive/dSYMs/$FRAMEWORK_NAME.framework.dSYM \
-framework build/arm64.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework \
-debug-symbols "$(pwd -P)"/build/arm64.xcarchive/dSYMs/$FRAMEWORK_NAME.framework.dSYM \
-output "${FRAMEWORK_NAME}.xcframework"

echo("✅ Moving $FRAMEWORK_NAME.xcframework to SampleApp/$FRAMEWORK_NAME.xcframework")
mv "$FRAMEWORK_NAME.xcframework" "SampleApp/$FRAMEWORK_NAME.xcframework"