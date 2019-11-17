PROJECT?=SwiftTUI

build:
	swift build
xcodeproj: 
	swift package generate-xcodeproj
dry-run: build
	.build/x86_64-apple-macosx/debug/Demo
