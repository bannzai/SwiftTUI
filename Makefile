PROJECT?=SwiftTUI
PACKAGE?=SwiftTUI-Package

build:
	# https://stackoverflow.com/questions/56251835/swift-package-manager-unable-to-compile-ncurses-installed-through-homebrew
	export PKG_CONFIG_PATH="/usr/local/opt/ncurses/lib/pkgconfig"
	swift build -Xcc -D__NCURSES_H 
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
