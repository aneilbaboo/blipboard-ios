#!/bin/sh

HOMEDIR="/Users/macbook"
BLIPSERVERDIR="$HOMEDIR/blipboard"
BLIPIOSDIR="$HOMEDIR/blipboard-ios5"

OUTDIR="/tmp"
BLIPSERVEROUTFILE="$OUTDIR/KIF-blipserver-$$.out"
BLIPIOSOUTFILE="$OUTDIR/KIF-blipios-$$.out"
BLIPMONGODOUTFILE="$OUTDIR/KIF-blipmongod-$$.out"

BINDIR="/usr/local/bin"


#kill simulator if running
echo "****** Kill simulator, blip server, mongod (if running locally) "
killall -s "iPhone Simulator" &> /dev/null
if [ $? -eq 0 ]; then
    killall -KILL -m "iPhone Simulator"
fi

killall -s "node"&> /dev/null
if [ $? -eq 0 ]; then
    killall -KILL -m "node"
fi

killall -s "mongod"&> /dev/null
if [ $? -eq 0 ]; then
    killall -KILL -m "mongod"
fi


echo "****** Update & build blip server from git"
cd $BLIPSERVERDIR
# git pull
make

echo "****** Run mongod"
$BINDIR/mongod > $BLIPMONGODOUTFILE & 

echo "****** Run Blip Server"
cd $BLIPSERVERDIR
$BINDIR/supervisor server.js > $BLIPSERVEROUTFILE &

#xcodebuild -scheme "GUITests" -workspace "xxx.xcworkspace" -configuration Debug -sdk "/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.0.sdk/" build CONFIGURATION_BUILD_DIR="/var/hudson/workspace/$JOB_NAME/build" 


echo "****** Run simulator"

# Copy over the accessibility conf file that enables the accessibility label.
cp $HOMEDIR/com.apple.Accessibility.plist.enabled $HOMEDIR/Library/Application\ Support/iPhone\ Simulator/6.0/Library/Preferences/com.apple.Accessibility.plist

#ios-sim launch /Users/Shared/Jenkins/DerivedData/Blipboard\ \(Integration\ Tests\).app > /tmp/KIF-$$.out 2>&1
#ios-sim launch /Users/Shared/Jenkins/DerivedData/Blipboard\ SF.app > /tmp/KIF-$$.out 2>&1
#ios-sim launch /Users/macbook/blipboard-ios5/DerivedData/Blipboard/Build/Products/Debug-iphonesimulator/Blipboard\ SF.app --verbose  > /tmp/KIF-$$.out 2>&1 
#ios-sim launch /Users/macbook/blipboard-ios5/DerivedData/Blipboard/Build/Products/Debug-iphonesimulator/Integration\ Tests.app --verbose > /tmp/KIF-$$.out 2>&1 

$BINDIR/ios-sim launch $BLIPIOSDIR/DerivedData/Blipboard/Build/Products/Debug-iphonesimulator/Integration\ Tests.app --verbose > $BLIPIOSOUTFILE 2>&1 


echo "****** Testing finished"
echo " Logfiles->"
echo `ls /tmp/*-$$.out`

echo "****** Kill local server & mongod"
killall -s "node"&> /dev/null
if [ $? -eq 0 ]; then
    killall -KILL -m "node"
fi

killall -s "mongod"&> /dev/null
if [ $? -eq 0 ]; then
    killall -KILL -m "mongod"
fi


# count the number of times "TESTING FINISHED: 0 failures" is found - 0 means that there was a failure
success=`exec grep -c "TESTING FINISHED: 0 failures" $BLIPIOSOUTFILE`

# if there was a failure, show the log file and return with a non-zero exit code
if [ "$success" = '0' ]
then 
    cat $BLIPIOSOUTFILE 
    echo "==========================================="
    echo "GUI Tests failed"
    echo "==========================================="
    exit 1
else
    echo "==========================================="
    echo "GUI Tests passed"
    echo "$(cat $BLIPIOSOUTFILE |grep PASS)"
    echo "==========================================="
fi
