#!/bin/sh
#  Script.sh
#  XcodeTravis
#
#  Created by V2Solutions on 16/03/15.
#  Copyright (c) 2014 ___v2Tech Ventures___. All rights reserved.

# Condition to check the existance of INFO_PLIST
if [ ! -z "$INFO_PLIST" ]; then
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $TRAVIS_BUILD_NUMBER" "$INFO_PLIST"
echo "Set CFBundleVersion to $TRAVIS_BUILD_NUMBER"
fi

# Condition to check the existance of BUNDLE_IDENTIFIER
if [ ! -z "$BUNDLE_IDENTIFIER" ]; then
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_IDENTIFIER" "$INFO_PLIST"
echo "Set CFBundleIdentifier to $BUNDLE_IDENTIFIER"
fi

# Condition to check the existance of BUNDLE_DISPLAY_NAME
if [ ! -z "$BUNDLE_DISPLAY_NAME" ]; then
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $BUNDLE_DISPLAY_NAME" "$INFO_PLIST"
echo "Set CFBundleDisplayName to $BUNDLE_DISPLAY_NAME"
fi