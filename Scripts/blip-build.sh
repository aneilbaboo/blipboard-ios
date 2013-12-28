#!/bin/sh

# build.sh
#
# Created by Vincent Daubry on 19/01/10.
# Copyright 2010 OCTO. All rights reserved.

WORKSPACE=~/blipboard-ios5
___XCODE_PROJECT_NAME___="Blipboard"
___PROJECT_NAME___="Blipboard.xcodeproj"
PROJDIR="${WORKSPACE}/${___PROJECT_NAME___}"
PROJECT_NAME="${___XCODE_PROJECT_NAME___}"
TARGET_SDK="iphoneos5.1"
PROJECT_BUILDDIR="${PROJDIR}/DerivedData/Script/AdHocBuild/"
TARGET_TEST_NAME="UnitTests"
BUILD_HISTORY_DIR="~/blipboard/Archives"
DEVELOPER_NAME="iPhone Distribution: Blipboard"
PROVISIONING_PROFILE="/Users/aneil/Library/MobileDevice/Provisioning Profiles/6AB822F0-F6F4-4460-B1E8-43D6EA3F6B3C.mobileprovision"
 
# compile project
echo Building Project
cd "${PROJDIR}"
xcodebuild -target "${PROJECT_NAME}" -sdk "${TARGET_SDK}" -configuration AdHoc_Distribution

#Check if build succeeded
if [ $? != 0 ]
then
  exit 1
fi

/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${PROJECT_BUILDDIR}/${APPLICATION_NAME}.app" -o "${BUILD_HISTORY_DIR}/${APPLICATION_NAME}.ipa" --sign "${DEVELOPER_NAME}" --embed "${PROVISIONING_PROFILE}"