#!/bin/bash
# original source from http://www.thecave.com/2014/09/16/using-xcodebuild-to-export-a-ipa-from-an-archive/

xcodebuild clean -project Zombies\ Interactive -configuration Release -alltargets
xcodebuild archive -project Zombies\ Interactive.xcodeproj -scheme Zombies\ Interactive -archivePath Zombies\ Interactive.xcarchive

xcodebuild -exportArchive -archivePath Zombies\ Interactive.xcarchive -exportOptionsPlist zombies_export.plist -exportPath zombies.ipa
