#!/bin/sh

#  remove-key.sh
#  XcodeTravis
#
#  Created by V2Solutions on 16/03/15.
#  Copyright (c) 2014 ___v2Tech Ventures___. All rights reserved.

# Deleting key chain certificates 
security delete-keychain ios-build.keychain
rm -f ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_NAME.mobileprovision