Introduction
=========================
Blipboard-iPhone is an iPhone client for Blipboard, a service that lets people sign up for or receive location-based alerts.  It is a native iPhone application originally developed in the XCode 4.2 environment.  It is stored as a private repository on github.

Setup
------------------------
1. Install cocoapods - see http://cocoapods.org for setup instructions
2. Retrieve blipboard code from github:
	git clone --recursive git@github.com:aneilbaboo/blipboard-ios.git Blipboard
3. Install cocoapods:
    pod install 
4. Open the Blipboard.xcworkspace file in XCode (*do not* use the Blipboard.xcproject file)

Directory and Group Structure
-----------------------------
Wherever possible, Xcode Groups mirror the actual underlying folder structure.  There are some exceptions to this, but for the majority of the code (in Blipboard/Classes), it's a 1:1 mapping.

Directory Structure:
Blipboard/ - contains some miscellaneous top-level files, which are available in the Supporting Files Group.
   Classes/ = Blipboard/Classes group
   Configuration/ = Supporting Files/Configuration group - configuration files
   Resources/ - Blipboard/Resources group
     Images/
     Data/
     Sounds/
     etc.
   en.lproj/ - localized settings
BlipboardTests - tests
DerivedData - build intermediates and products
Frameworks - Frameworks group - Git submodules & included frameworks

External Libraries 
------------------
We avoid git submodules as much as possible, and try to use Cocoapods
whenever possible.  http://cocoapods.org

Servers
---------
Blipboard can connect to local, staging and production servers, hosted
on heroku.  The scheme used to build the target determines which
server is used (see below).

Bundle Identifiers
------------------
In order to allow both production and staging versions of Blipboard to
exist on a device at the same time, we use two different APPIDs
(specified in the iOS provisioning profile):

com.blipboard.blipboard - always points at the production server
com.blipboard.whistle   - always points at the staging server (or localhost)

Push Notifications / Urban Airship
----------------------------------
Adhoc and Release iOS apps interact with Apple's production APNS servers, 
whereas debug builds interact with Apple's development (aka sandbox) APNS 
servers.  We have set up two Urban Airship accounts (prod, dev) which connect 
to Apple's production and development APNS servers, respectively.

Schemes, Configurations and Configuration Files
-----------------------------------------------
Blipboard uses Xcode schemes to define different build
configurations.  Each build configuration has a separate scheme which
configures which Heroku server and which Urban Airship account is used.  You
should choose the appropriate action on the product menu

                  Server            Urban Airship  How to Build:
                  --------------    -------------  --------------
Localhost         localhost:3000    dev            Run
Debug (Staging)   staging           dev            Run
Debug (Prod)      prod              dev            Run
Alpha             staging           prod           Archive
Beta              prod              prod           Archive
        
Each scheme has a corresponding configuration and a corresponding configuration settings file:

    Scheme           Configuration       Configuration Settings File
    -------          --------------      ---------------------------
    Localhost        Localhost           Localhost.xcconfig
    Debug (Staging)  DebugStaging        DebugStaging.xcconfig
    Debug (Prod)     DebugProd           DebugProd.xcconfig
    Alpha            Alpha
    etc.

Configurations are used by Xcode to coordinate many different settings
in the project.  In Blipboard, the only settings that vary between
configurations are the Preprocessor Macros.  

This section (in Project > Target > Build Settings) maps values in the
.xcconfig files to preprocessor macros available within the Objective
C code. 


.xcconfig Files
---------------
Configuration settings files contain values such as:
   * API keys and tokens for external services such as TestFlight,
   Urban Airship and Flurry
   * The target name (SCHEME_TARGET_NAME)
   * AppId (Bundle identifier)

Look in Shared.xcconfig for a directory of the possible configuration variables.

Problems
--------
1. Quit Xcode
2. open Terminal in blipboard-ios5 dir
3. rm -frd Derived\ Data
[4. git submodule init && git submodule update --recursive]
[5. rm -frd Pods && pod install]
6. start Xcode

Step 4 is only rarely necessary (e.g., when submodules are updated)
Step 5 is sometimes necessary

Run against the local static server (may be out of date)
-----------------------------------
1. Get the node.js server from git@github.com:amallavarapu/blipboard.git
2. run the static server:
    node test/static_server.js
3. In XCode set Scheme to Blipboard > iPhone 5.0 Simulator
4. In BBAppDelegate.m uncomment //[BBAppDelegate setBaseURL:@"http://localhost:3000"]; and comment out [BBAppDelegate setBaseURL:@"http://blipboard-staging.herokuapp.com"];
5. Product > Run
