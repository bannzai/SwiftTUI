PROJECT?=SwiftTUI
PACKAGE?=SwiftTUI-Package

.PHONY: build
build: 
	# https://stackoverflow.com/questions/56251835/swift-package-manager-unable-to-compile-ncurses-installed-through-homebrew
ifndef PKG_CONFIG_PATH
	$(error PKG_CONFIG_PATH is undefined)
endif
	swift build -Xcc -D__NCURSES_H 

.PHONY: xcodeproj
xcodeproj: 
	swift package generate-xcodeproj

.PHONY: remove-log
remove-log:
	rm -f $(DEBUG_LOGGER_PATH)
	
.PHONY: clean
clean: remove-log
	rm -rf $(PROJECT).xcodeproj

.PHONY: dry-run
dry-run: build
	.build/x86_64-apple-macosx/debug/Demo

.PHONY: test
test: build xcodeproj
	xcodebuild clean build test -project $(PROJECT).xcodeproj \
		-scheme $(PACKAGE) \
		-destination platform="macOS" \
		-enableCodeCoverage YES \
		-derivedDataPath .build/derivedData \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		ONLY_ACTIVE_ARCH=NO
