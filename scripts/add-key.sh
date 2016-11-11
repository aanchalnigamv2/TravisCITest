#!/bin/sh

#  add-key.sh
#  XcodeTravis
#
#  Created by V2Solutions on 16/03/15.
#  Copyright (c) 2014 ___v2Tech Ventures___. All rights reserved.

# Create a custom keychain
security create-keychain -p travis ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain

# Set keychain timeout to 1 hour for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings ios-build.keychain



# Add certificates to keychain and allow codesign to access them
security import "$APP_SCRIPT_PATH$APP_APPLE_CERTIFICATE" -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import "$APP_SCRIPT_PATH$APP_TEAM_AGENT_DISTRIBUTION_CERTIFICATE" -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import "$APP_SCRIPT_PATH$APP_TEAM_DISTRIBUTION_PRIVATE_KEYS" -k ~/Library/Keychains/ios-build.keychain -P '' -T /usr/bin/codesign
#security import ./scripts/certs/Key.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign


# Put the provisioning profile in place
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "$APP_PROFILE_PATH$PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/
