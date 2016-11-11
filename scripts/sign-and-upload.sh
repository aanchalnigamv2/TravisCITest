#!/bin/sh
# sign-and-upload.sh
# XcodeTravis
#
# Created by V2Solutions on 16/03/15.
# Copyright (c) 2014 ___v2Tech Ventures___. All rights reserved.
# http://www.objc.io/issue-6/travis-ci.html


# APP_BUILD_ENV : To configure the build scheme environment for defining the app build path
APP_BUILD_ENV=""

# HOCKEY_APP_ID & HOCKEY_APP_TOKEN : To configure the Hockey App Id and Token for uploading the build
HOCKEY_APP_TOKEN=""
HOCKEY_APP_ID=""

# Condition which defines the Build Env used and based on that selection of the Hockey App Id and Hockey App token
if ([ "$TRAVIS_BRANCH"  = "develop" ]); then
    APP_BUILD_ENV=DEV;
    HOCKEY_APP_ID=$DEV_HOCKEY_APP_ID;
    HOCKEY_APP_TOKEN=$DEV_HOCKEY_APP_TOKEN;
    echo "DEV Scheme Selected.";
elif ([ "$TRAVIS_BRANCH" = "QA" ]); then
    APP_BUILD_ENV=QA;
    HOCKEY_APP_ID=$QA_HOCKEY_APP_ID;
    HOCKEY_APP_TOKEN=$QA_HOCKEY_APP_TOKEN;
    echo "QA Scheme Selected.";
elif ([ "$TRAVIS_BRANCH" = "master" ]); then
    APP_BUILD_ENV=UAT;
    HOCKEY_APP_ID=$UAT_HOCKEY_APP_ID;
    HOCKEY_APP_TOKEN=$UAT_HOCKEY_APP_TOKEN;
    echo "UAT Scheme Selected.";
else
    echo "No deployment will be done."
    exit 0
fi

# UBER_TESTES_RELEASE_TITLE : To configure the app build path for uber testers build
UBER_TESTES_RELEASE_TITLE="UberTesters-$APP_BUILD_ENV"

# PROVISIONING_PROFILE : Provition profile selction
PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"

# OUTPUTDIR: App build path
OUTPUTDIR="$PWD/build/$APP_BUILD_ENV-iphoneos"

echo "***************************"
echo "* Signing *"
echo "***************************"

# command to package the appliacation and create the .ipa file
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

#echo "Output Directory Path"
#echo "$OUTPUTDIR/$APP_NAME.app"

# Condition to check the application's .ipa file is avaialable in build path
# If the .ipa file is available then zip the app.dysm file
if ([ -f "$OUTPUTDIR/$APP_NAME.ipa" ]); then
    zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dsym.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"
else
    echo "Error : dSYM or IPA is not generated.."
    exit 0
fi

# RELEASE_DATE : To specify the relase date of the build
RELEASE_DATE='date '+%Y-%m-%d %H:%M:%S''

# RELEASE_NOTES : To specify the release notes, including the relase date and build number
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

# Condition to upload the build on the Hockey App
# If app build .ipa avaialble on the specified build path,then upload the .ipa and .dysm.zip on Hockey App
# else showing the appropriate message on Travis log
if ([ -f "$OUTPUTDIR/$APP_NAME.ipa" ]); then
    if [ ! -z "$HOCKEY_APP_ID" ] && [ ! -z "$HOCKEY_APP_TOKEN" ]; then
        echo ""
        echo "***************************"
        echo "* Uploading to Hockeyapp *"
        echo "***************************"
        curl \
        -F "status=2" \
        -F "notify=0" \
        -F "notes=$RELEASE_NOTES" \
        -F "notes_type=0" \
        -F "ipa=@$OUTPUTDIR/$APP_NAME.ipa" \
        -F "dsym=@$OUTPUTDIR/$APP_NAME.app.dsym.zip" \
        -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN" \
        https://rink.hockeyapp.net/api/2/apps/upload
        echo "Upload finish HockeyApp "
    fi
else
    echo "Failed to Upload Build on Hockeyapp"
fi

# Condition to upload the build on the UberTesters
# If app build .ipa avaialble on the specified build path,then upload the .ipa UberTestes
# else showing the appropriate message on Travis log
if ([ -f "$OUTPUTDIR/$APP_NAME.ipa" ]); then
    if [ ! -z "$UBER_TESTERS_PERSONAL_API_KEY" ]; then
        echo "***************************"
        echo "* Uploading to UberTesters  *"
        echo "***************************"
        curl  http://beta.ubertesters.com/api/client/upload_build.json \
        -F file="@$OUTPUTDIR/$APP_NAME.ipa" \
        -F title="$UBER_TESTES_RELEASE_TITLE" \
        -F notes="$RELEASE_NOTES" \
        -F status="in_progress" \
        -F stop_previous="true" \
        -H "X-UbertestersApiKey:$UBER_TESTERS_PERSONAL_API_KEY" \
        echo "*****  Upload finish UberTesters*****"
    fi
else
    echo "*****  Failed to Upload Build on UberTesters*****"
fi



