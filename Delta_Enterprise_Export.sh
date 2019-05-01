#!/bin/bash
xcodebuild clean \
    -project otg-delivery-mobile.xcodeproj/ \
    -scheme otg-delivery-mobile

xcodebuild \
    -project otg-delivery-mobile.xcodeproj \
    -scheme otg-delivery-mobile \
    -archivePath build/otg-delivery-mobile.xcarchive \
    archive

xcodebuild \
	-exportArchive \
	-archivePath build/otg-delivery-mobile.xcarchive \
	-exportOptionsPlist exportEnterprise.plist \
	-exportPath otg-delivery-mobile.ipa
