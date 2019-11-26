PROJECT?=SwiftTUI
PACKAGE?=SwiftTUI-Package

build:
	swift build
xcodeproj: 
	swift package generate-xcodeproj
clean:
	rm -rf $(PROJECT).xcodeproj
dry-run: build
	.build/x86_64-apple-macosx/debug/Demo

test: build xcodeproj
	xcodebuild clean build test -project $(PROJECT).xcodeproj \
		-scheme $(PACKAGE) \
		-destination platform="macOS" \
		-enableCodeCoverage YES \
		-derivedDataPath .build/derivedData \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		ONLY_ACTIVE_ARCH=NO
