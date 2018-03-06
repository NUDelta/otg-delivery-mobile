#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/

xcodebuild clean -project otg-delivery-mobile -configuration Release -alltargets
xcodebuild archive -project otg-delivery-mobile.xcodeproj -scheme another_example -archivePath otg-delivery-mobile.xcarchive

xcodebuild -exportArchive -archivePath otg-delivery-mobile.xcarchive -exportOptionsPlist exportEnterprise.plist -exportPath otg-delivery-mobile.ipa
