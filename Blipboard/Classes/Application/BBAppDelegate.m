//
//  BBAppDelegate.m
//  Blipboard
//
//  Created by Jason Fischl on 1/26/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

// System
#import <objc/runtime.h>
#import <netdb.h>

#import <FacebookSDK/FacebookSDK.h>

// Application
#import "BBAppDelegate.h"
#import "BBEnvironment.h"

// UI
#import "ECSlidingViewController.h"
#import "BBBackBarButtonItem.h"

#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "UIView+MakeImage.h"
#import "BBMapView.h"
#import "ErrorViewController.h"
#import "BBNavigationController.h"
#import "GuruListViewController.h"
#import "SlideoutViewController.h"
#import "SlideoutMenuViewController.h"
#import "WebViewController.h"
#import "Flurry+Blipboard.h"
#import "BBShareKitConfigurator.h"

// TEST CONTROLLER
#if RUN_KIF_TESTS
#import "BBTestController.h"
#endif

@implementation BBAppDelegate {
    NSString *buildNumber;
    NSString *versionNumber;
    NSString *version;
    CLLocation *myLocation;
}

#pragma mark Properties

@dynamic haveSeenGuruList;

#pragma mark -
#pragma mark UIApplicationDelegate methods

static void uncaughtExceptionHandler(NSException *exception);
    
void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught Exception" message:@"Crash!" exception:exception];
}

-(void)setupRootViewController {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (!window) {
        return;
    }
    
    window.backgroundColor = [UIColor clearColor];
    
    SlideoutViewController *slideOutCtrlr = [SlideoutViewController sharedController];
    
    // black status bar
    [self _styleNavBar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    window.rootViewController = slideOutCtrlr;
    [window makeKeyAndVisible];
    [window layoutSubviews];
    self.window = window;
}

NSString* SHKLocalizedStringFormat(NSString* key);
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    buildNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    version = [NSString stringWithFormat:@"%@ (%@ | %@)",versionNumber,CONFIGURATION,buildNumber];
    BBLog(@"Client version %@", version);
    BBLog(@"System version %@", [[UIDevice currentDevice] systemVersion]);
    BBLog(@"LOGGER_TARGET=%@",LOGGER_TARGET);

    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSDictionary *appDefaults = @{  @"hideBadCategories":@"YES"  };
    //[defaults registerDefaults:appDefaults];
 
    [defaults setObject:version forKey:@"appVersionNumber"];
    [defaults synchronize];


    // ASIHTTPRequest initialization
    // !am! - temporary code to see whether stopping ASIHTTPRequest's activity indicator solves our problem
    //        I think there may be a race condition with RestKit's use of activity indicator, though
    //        from perusing the code, I would expect the opposite problem (Activity indicator off when
    //        there is actually network traffic).
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
    
    [BBAppDelegate setBaseURI:[[BBEnvironment sharedEnvironment] apiURL]];
    [BBAppDelegate configureRestKitModelMappings];
    
    self.lastActiveTimestamp = 0; // set timestamp to now

    self.myAccount = [Account restoreAccount];
    self.authenticated = NO;
    self.starting = NO; // wait for the didBecomeActive delegate

#if !defined (INTERCOM_API_KEY) || !defined (INTERCOM_APP_ID)
#error INTERCOM_API_KEY && INTERCOM_APP_ID must be defined!
#endif
    
    [Intercom setApiKey:INTERCOM_API_KEY forAppId:INTERCOM_APP_ID];
    BBLog(@"Intercom APP_ID:%@",INTERCOM_APP_ID);
    
    // Override point for customization after application launch.
    [ServerModel setGlobalStatusCodeHandler:HTTPStatusCodeUnauthorized block:^(ServerModelError *error) {
        BBLog(@"API auth problem: %@", error);
        self.authenticated = NO;
        [FBSession.activeSession closeAndClearTokenInformation];
        [FBSession renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
            BBLog(@"renewed Facebook system credentials. Now authenticate result=%d %@", result, error);
            if ([FBSession openActiveSessionWithAllowLoginUI:NO] == NO) {
                BBLog(@"Request facebook authentication");
                [self showAuthDialog];
            }
        }];
    }];
    
    // !am! no more messy logic here in the BBAppDelegate:
    [[BBRemoteNotificationManager sharedManager] didFinishingLaunchingWithOptions:launchOptions];
    
    // ShareKit configuration
    BBShareKitConfigurator *shareKitConfig = [BBShareKitConfigurator new];
    [SHKConfiguration sharedInstanceWithConfigurator:shareKitConfig];
    
    // Location manager
    self.locationManager = [[BBLocationManager alloc] init];

    if (launchOptions != nil) {
        
        NSDictionary* locationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
		if (locationInfo != nil) {
            BBLog(@"location: launched from location update: %@", locationInfo);
            //[self loadAccountForBackgroundMode];
            [self.locationManager startMonitoring];
        }
    }
    
    
    BBLog(@"done");
    return YES;
}

- (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized) {
        BBLog(@"foreground initialize");
        
        NSURL* url = [NSURL URLWithString:BBEnvironment.sharedEnvironment.apiURL];
        BBLog(@"Monitor reachability with %@", url.host);
        self.reach = [Reachability reachabilityWithHostname:url.host];

        // Flurry Analytics
        [Flurry startSession:FLURRY_API_KEY];
        
        [Flurry setSessionReportsOnPauseEnabled:YES];
        [Flurry setSecureTransportEnabled:YES];
        //NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
        [Flurry logAllPageViews:self.mainViewController.navigationController];
        [Flurry logEvent:kFlurryStart withParameters:@{  @"version": version, @"url": BBAppDelegate.baseURI }];
        
#if defined CONFIGURATION_Beta || CONFIGURATION_Release
        BBLog(@"Enable heatma.ps menu");
        // HeatMaps integration
        [Heatmaps instance].showDebug = NO;
        [Heatmaps instance].disableWWAN = NO;
        [[Heatmaps instance] start];
#endif
        
#if defined (TESTFLIGHT_TOKEN)
        // #pragma clang diagnostic push/pop suppresses deprecation warning
        // see http://blog.goosoftware.co.uk/2012/04/18/unique-identifier-no-warnings/
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)]];
#pragma clang diagnostic pop
 
        
        [TestFlight takeOff:TESTFLIGHT_TOKEN];
#endif
        
        // RestKit log everything
        //    RKLogSetAppLoggingLevel(RKLogLevelInfo);
        //    RKLogConfigureByName("RestKit/*", RKLogLevelDebug);
        //    RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
                
#if RUN_KIF_TESTS
        [[BBTestController sharedInstance] startTestingWithCompletionBlock:^{
            // Exit after the tests complete so that CI knows we're done
            exit([[BBTestController sharedInstance] failureCount]);
        }];
#endif
        [self setupRootViewController];
        [self showSplashScreen];
        
        initialized = YES;
    }
}


- (void)_styleNavBar {
    [[UINavigationBar appearance] setTintColor:[UIColor bbWhite]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                     UITextAttributeFont:[UIFont bbBoldFont:20],
                                UITextAttributeTextColor:[UIColor bbGray3],
                          UITextAttributeTextShadowColor:[UIColor clearColor] }];
    
    NSDictionary *barButtonTextAttrs = @{   UITextAttributeFont:[UIFont bbBoldFont:17],
                                            UITextAttributeTextColor:[UIColor bbGray3],
                                            UITextAttributeTextShadowColor:[UIColor clearColor] };

    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTextAttrs forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTextAttrs forState:UIControlStateHighlighted];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn_nav_white.png"]
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn_nav_white.png"]
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -2) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"btn_nav_white_back.png"]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"btn_nav_white_back.png"]
                                                      forState:UIControlStateNormal | UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];

}

- (void) clearBadge {
    BBTrace();
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
}

// !JF! when is this called?

// !am! 3/26/13 consider changing this to didAuthenticate
//              and moving this functionality to a BBAuthenticationManager
- (void)onAuthenticated
{
    [Flurry setUserID:self.myAccount.id];
    
    [Intercom beginSessionForUserWithUserId:self.myAccount.id andEmail:self.myAccount.email];
    [Intercom updateUserName:self.myAccount.name];
    if (self.myAccount.stats && self.myAccount.facebookId) {
        [Intercom updateAttributes:
         @{ @"facebook_id" : self.myAccount.facebookId,
            @"score" : self.myAccount.stats._score,
            @"blips": self.myAccount.stats._blips,
            @"followers": self.myAccount.stats._followers,
            @"following": self.myAccount.stats._following}];;
    }

    
    if (!self.authenticated) {
        self.authenticated = YES;
        
        [self showPopularAtCurrentLocation];
    }

    [[BBRemoteNotificationManager sharedManager] didAuthenticate];

    [self.mainViewController.filterList refreshTopics];
}

- (void) logFlurryEvent:(NSString*)name
{
    [Flurry logEvent:name];
}

-(void) updateMapAfterHiatus
{
    BBLog(@"interval since last active=%f", fabs(self.lastActiveTimestamp.timeIntervalSinceNow));
    
    const NSTimeInterval hiatusTimeInterval = 5.0*60.0; // 5 minutes
    if (self.lastActiveTimestamp == 0 || fabs(self.lastActiveTimestamp.timeIntervalSinceNow) >= hiatusTimeInterval) {
        [self showPopularAtCurrentLocation];
    }
}

// current location will be the last reported location from the LocationManager
-(void) showPopularAtCurrentLocation
{
    if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive) {
        BBLog(@"show popular blips");
        [self.mainViewController selectContentSegment:ContentSegmentDiscover];
        
        if ([Account isInSupportedAreaWithLocation:self.locationManager.lastReportedLocation]) {
            BBLog(@"in supported area - start user tracking");
            [self.mainViewController loadBlipsForVisibleMap]; // !am! must do this to ensure blips load because
            [self.mainViewController startUserTracking];      //   startUserTracking might not move the map
            //   If map moves, the first load request
            //   should be cancelled anyway.
        }
        else {
            BBLog(@"outside of supported area - reload popular at current map location (last=%@)", self.locationManager.lastReportedLocation);
            [self.mainViewController loadBlipsForVisibleMap];
        }
    }
}

// Add openURL method in delegate.  Pass to our web controller.
- (BOOL)openURL:(NSURL*)url
{
    BBLog(@"Got openURL request in BBAppDelegate (%@)", url);
    
    UIViewController *vc = [SlideoutViewController sharedController].topViewController;
    UINavigationController *navCtrl;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        navCtrl = (UINavigationController *)vc;
        vc = navCtrl.topViewController;
    }
    
    if ([vc isKindOfClass:[WebViewController class]]) {
        [(WebViewController *)vc openURL:url];
    }
    else {
        WebViewController *wc = [[WebViewController alloc] initWithURL:url];
        [wc openURL:url];
        [self hideSplashScreen];
        [navCtrl pushViewController:wc animated:YES];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of
     temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and
     it begins the transition to the background state.  Use this method to pause ongoing tasks, disable timers, and
     throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    BBTrace();
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state
     information to restore your application to its current state in case it is terminated later.  If your application
     supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    BBTrace();
    [self.locationManager startMonitoring];
    [self.mainViewController stopUserTracking]; // disable the GPS
    [self.mainViewController clearOffScreenPins];
    
    if (self.myAccount.stats && self.myAccount.facebookId) {
        [Intercom updateAttributes:
         @{ @"facebook_id" : self.myAccount.facebookId,
         @"score" : self.myAccount.stats._score,
         @"blips": self.myAccount.stats._blips,
         @"followers": self.myAccount.stats._followers,
         @"following": self.myAccount.stats._following}];;
    }

    // note, this will be called if the user hits the home button or answers a call
    // (but not if they receive a call and don't answer.
    // http://www.cocoanetics.com/2010/07/understanding-ios-4-backgrounding-and-delegate-messaging/
    
    self.lastActiveTimestamp = [NSDate date]; // set timestamp to now
    [[BBRemoteNotificationManager sharedManager] didEnterBackground];
    
    [self.reach stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    self.starting = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    BBTrace();


}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    BBTrace();
    [self initialize];
    self.locationManager.lastRetrieveTime = 0;
    [self.locationManager retrieveLocationWithTimeout:2.0];
    [self.locationManager stopMonitoring];

    [[BBRemoteNotificationManager sharedManager] didBecomeActive];
    
    self.starting = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification object:nil];
    [self.reach startNotifier];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    BBTrace();
    [FBSession.activeSession close];
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[BBRemoteNotificationManager sharedManager] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[BBRemoteNotificationManager sharedManager] didFailToRegisterForRemoteNotificationsWithError:error];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[BBRemoteNotificationManager sharedManager] didReceiveRemoteNotification:userInfo];
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}


#pragma mark -
#pragma mark BBAppDelegate class methods

+(BBAppDelegate*) sharedDelegate {
    return (BBAppDelegate*)UIApplication.sharedApplication.delegate;
    
}


#pragma mark FSM Actions
// !JF! this needs to be called from outside the FSM
- (void) showFirstTimeGuruList {
    BBTrace();
    if (!self.haveSeenGuruList) {
        self.haveSeenGuruList = YES;
        GuruListViewController *gurus = [GuruListViewController guruListViewControllerWithCoordinate:self.mainViewController.mapView.centerCoordinate context:@"first-time"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gurus];
        
        [self.mainViewController presentViewController:navController
                                              animated:YES
                                            completion:^{}];
    }
    
}

// !JF! Authentication
// must handle 401 and other failures differently. 
- (void) createAccountWithToken:(NSString*)token
{
    self.myAccount = [Account createAccountWithToken:token block:^(Account *account, ServerModelError *error) {
        if (error) {
            switch (error.statusCode) {
                case HTTPStatusCodeUnauthorized:
                case HTTPStatusCodeForbidden:
                    self.authenticated = NO;
                    BBLog(@"account creation failed due to authorization problem: %@", error);
                    [self showAuthDialog]; // !jf! is this right? 
                    break;
                default:
                    BBLog(@"retry account creation %@", error);
                    [self retry:error];
                    break;
            }
        }
        else {
            BBLog (@"create-account: %@", account.id);
            [self saveAccount:account];
            // !am! not doing this anymore - let's drive this from server-side notifications
            // [self showFirstTimeGuruList];
            [self hideSplashScreen];
            [self onAuthenticated];
        }
    }];
}

- (void)reportFacebookToken:(NSString*)token
{
    BBLog(@"report facebook token: %@", token);
    if (!self.myAccount) {
        [self createAccountWithToken:token];
    }
    else if (self.myAccount && self.myAccount.id == nil) {
        BBLog(@"Waiting for account creation to complete %@", self.myAccount);
    }
    else if (self.myAccount) {
        [self setupAuthentication];
        [self.myAccount updateFacebookToken:token
                                      block:^(Account *account, ServerModelError *error) {
                                          if (error) {
                                              switch (error.statusCode) {
                                                  case HTTPStatusCodeUnauthorized:
                                                      self.authenticated = NO;
                                                      [self clearAccount];
                                                      [self showAuthDialog];
                                                      BBLog(@"reported facebook access-token: authentication failure: %@", error);
                                                      break;
                                                  case HTTPStatusCodeForbidden:
                                                      self.authenticated = NO;
                                                      [self clearAccount];
                                                      [self showAuthDialog];
                                                      BBLog(@"reported facebook access-token: account doesn't match token: %@", error);
                                                      break;
                                                  default:
                                                      BBLog (@"reported facebook access-token: non-auth failure: retrying\n%@", error);
                                                      [self retry:error];
                                                      break;
                                              }
                                          }
                                          else {
                                              BBLog (@"reported facebook access-token: %@", account.id);
                                              
                                              // need to save this so that we update the account.id to ensure we
                                              // associate the device token with the right account id. It can change
                                              // because of the facebook association.
                                              [self saveAccount:account];
                                              [self hideSplashScreen];
                                              [self onAuthenticated];
                                              [self updateMapAfterHiatus];
                                          }
                                      }];
    }
}

- (void) clearAccount
{
    BBLog(@"clearAccount");
    [self.myAccount clearAccount];
    self.myAccount = nil;
    
    RKObjectManager* secureManager =[RKObjectManager sharedManager];
    secureManager.client.authenticationType = RKRequestAuthenticationTypeNone;
    secureManager.client.username = nil;
    secureManager.client.password = nil;
}

- (void) saveAccount
{
    [self.myAccount persistAccount];
    [self setupAuthentication];
}

- (void) saveAccount:(Account*)account
{
  NSString* password = self.myAccount.password; // save the previous password
  assert(self.myAccount);
  [self.myAccount copyFrom:account];
  self.myAccount.password = password; 
  
  // store the account info
  [self.myAccount persistAccount];
  [self setupAuthentication];
}

- (void)reportFacebookToken
{
    NSString* token = FBSession.activeSession.accessTokenData.accessToken;
    assert(token);
    [self reportFacebookToken:token];
}

// !JF! authentication
- (void) setupAuthentication
{
    assert(self.myAccount);
    assert(self.myAccount.id);
    NSString* token = FBSession.activeSession.accessTokenData.accessToken;
    RKObjectManager* secureManager =[RKObjectManager sharedManager];
    if (token) {
        secureManager.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
        secureManager.client.OAuth2AccessToken = token;
        BBLog(@"setting up oauth authentication: %@/%@", self.myAccount.id, token);
    }
    else {
        secureManager.client.authenticationType = RKRequestAuthenticationTypeHTTPBasic;
        secureManager.client.username = self.myAccount.id;
        secureManager.client.password = self.myAccount.password;
        BBLog(@"setting up basic authentication: %@/%@", self.myAccount.id, self.myAccount.password);
        assert(false);
    }
}

- (void)onMainViewControllerIsVisible:(MainBlipsViewController *)mainViewController {
    // not needed when app is in the background.
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground ) {
        [self reachabilityStatusChanged:nil]; // !jf! is this still needed?
    }
}

-(MainBlipsViewController *)mainViewController {
    return [MainBlipsViewController sharedController];
}

-(SlideoutViewController *)slideoutViewController {
    return [SlideoutViewController sharedController];
}

-(BBNavigationController *)mainNavController {
    return (BBNavigationController *)self.mainViewController.navigationController;
}

- (void)showSplashScreen {
    [self.mainNavController showSplash];
}

-(void)hideSplashScreen {
    BBTrace();
    // Now we can hide the splash
    [self.mainNavController hideSplash];
}

-(BOOL) isSplashVisible
{
    return self.mainNavController.splash.hidden == NO;
}


- (void) showAuthDialog
{
    BBTrace();
    LoginViewController* login = [LoginViewController loginViewController];
    login.delegate = self;
    
    [self.window.rootViewController presentViewController:login animated:YES completion:^{}];
}

-(BOOL)haveSeenGuruList {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"haveSeenGuruList"];
}

-(void)setHaveSeenGuruList:(BOOL)seen {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:seen forKey:@"haveSeenGuruList"];
    [defaults synchronize];
}

#pragma mark Facebook Methods

- (void)facebookLogin:(LoginViewController *)loginViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    BOOL result = [FBSession
                   openActiveSessionWithReadPermissions:@[@"email"]
                   allowLoginUI:YES
                   completionHandler:^(FBSession *session,
                                       FBSessionState state,
                                       NSError *error) {
                       [self sessionStateChanged:session
                                           state:state
                                           error:error];
                       if (!error) {
                           [loginViewController dismissViewControllerAnimated:YES completion:^{}];
                       }
                   }];
#pragma clang diagnostic pop
    BBLog(@"requested active Facebook session (with UI) %@", result ? @"active" : @"not-active(pending)");
}

// !JF! authentication
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    BBLog(@"Facebook session state changed %@ %@", session, error);
    switch (state) {
        case FBSessionStateOpen:
        {
            // Handle the logged in scenario
            NSString* token = FBSession.activeSession.accessTokenData.accessToken;
            BBLog(@"User %@ authenticated using facebook %@", self.myAccount, token);
            [self reportFacebookToken:token];
            break;
        }
//        case FBSessionStateClosed:
//        case FBSessionStateClosedLoginFailed: {
//            // Handle the logged out scenario
//            BBLog(@"User logged out");
//            //[_fsm OnfbSessionInvalidated];
//
//            // Close the active session
//            [FBSession.activeSession closeAndClearTokenInformation];
//            
//            // You may wish to show a logged out view
//            
//            break;
//        }
        default:
            break;
    }
    
    if (error) {
        // Handle authentication errors
        BBLog(@"User dismissed facebook login dialog. notify-user=%@ user-message=%@",
              error.fberrorShouldNotifyUser ? @"yes" : @"no",
              error.fberrorUserMessage);
        [FBSession.activeSession closeAndClearTokenInformation];

        RIButtonItem *okButton = [RIButtonItem itemWithLabel:@"Ok"];
        [okButton setAction:^{}];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Authentication Problem"
                                                        message:error.fberrorUserMessage cancelButtonItem:okButton otherButtonItems:nil];
        [alert show];
    }
}

- (void) retry:(NSError *)error
{
    BBTrace();
    RKObjectLoader *request = [error.userInfo objectForKey: @"request"];
    ServerModelResultContext *resultContext = request.userData;

    __block ServerModelError *serverError = resultContext.error;
    ErrorViewController *evc = [ErrorViewController errorViewControllerWithTitle:@"Error while contacting server"
                                andRetry:^{
                                    [self showSplashScreen];
                                    [serverError retry];
                                }];
    evc.hideBackButton = YES;
    [self hideSplashScreen];
    [self.mainNavController pushViewController:evc animated:YES];
}

- (void) cancel
{
    [self.cancellation cancel];
}

#pragma mark -
#pragma mark errors


// !JF! reachability changes / LocationManager
- (void) reachabilityStatusChanged:(NSNotification*) notification
{
    // only care about the shared reachability observer. for some reason there are 2.
    if (self.reach.isReachable) {
        BBLog(@"Network reachability: connected: \n%@", notification);
        if (!self.authenticated) {
            [self hideNetworkDisconnectedError];
        }
        
        if (self.starting) {
            [self onBecameActive];
        }
    }
    else {
        BBLog(@"Network reachability: disconnected: \n%@", notification);
        if (!self.authenticated) {
            [self showNetworkDisconnectedError];
        }
    }
}

- (void) onBecameActive
{
    self.starting = NO;
    self.mainViewController.mapView.showsUserLocation = YES;
    
    // this will load a cached session without presenting UI to the user
    BBLog(@"Checking if there is an active Facebook session [%d]", FBSession.activeSession.state);
    switch (FBSession.activeSession.state) {
        case FBSessionStateCreatedTokenLoaded:
            BBLog(@"Using cached facebook token");
            if ([FBSession openActiveSessionWithAllowLoginUI:NO] == NO) {
                BBLog(@"Request facebook authentication");
                [self showAuthDialog];
            }
            else {
                // the token may not be valid but we need to try. if the server request fails this will be changed to NO
                // authenticate with blipboard server. will result in self.authenticated=YES if it succeeds
                [self reportFacebookToken];
            }
            break;
            
        case FBSessionStateCreatedOpening:
            BBLog(@"Waiting for a new facebook session");
            break;
            
        case FBSessionStateOpen:
        case FBSessionStateOpenTokenExtended:
            BBLog(@"Using existing facebook session");
            // the token may not be valid but we need to try. if the server request fails this will be changed to NO
            // authenticate with blipboard server. will result in self.authenticated=YES if it succeeds
            [self reportFacebookToken];
            break;
            
        default:
            if ([FBSession openActiveSessionWithAllowLoginUI:NO] == NO) {
                BBLog(@"No existing facebook session");
                [self showAuthDialog];
            }
            else {
                BBLog(@"Loaded cached facebook session");
            }
    }
    
    // !jf! this is going to get reported more frequently than necessary because of app-switching
    [self.locationManager recordLocationServicesAuthorization];
}


- (BOOL) isNetworkReachable
{
    return self.reach.isReachable;
}


// this is called only from the unauthenticated states (i.e., when splash screen is shown)
- (void)showNetworkDisconnectedError
{
    if (!self.currentErrorViewController) {
        BBTrace();
        ErrorViewController *evc = [ErrorViewController errorViewControllerWithTitle:@"Network Connection Lost"
                                                                          andMessage:@"Waiting for WIFI or Network connection"];
        evc.hideBackButton = YES;
        [self hideSplashScreen];
        [self.mainNavController pushViewController:evc animated:YES];
    }
}

// called from both authenticated and unauthenticated states
// the dialog may have been shown by showNetworkDisconnectedError - or by an error handler for a request initiated by the user.
- (void)hideNetworkDisconnectedError
{
    if (self.currentErrorViewController) {
        BBLog(@"hiding ErrorViewController");
        [self.currentErrorViewController performSelector:@selector(dismiss) withObject:nil afterDelay:.5];
    }
    else {
        BBLog(@"no visible ErrorViewController - doing nothing");
    }
}

#pragma mark -
#pragma mark RestKit Setup

// RestKit URL Setup
+ (NSString *)baseURI
{
    return [[[RKClient sharedClient] baseURL] absoluteString];
}

+ (void)setBaseURI:(NSString *)baseURL
{
    [BBAppDelegate _setRestKitBaseURI:baseURL];
}

+ (void)_setRestKitBaseURI:(NSString *)baseURL
{
    BBLog(@"setting baseURL:%@",baseURL);
    NSURL* base = [NSURL URLWithString:baseURL];
    RKClient *client = [RKClient clientWithBaseURL:base];
    [RKClient setSharedClient:client];
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:base]; // need to set the manager url independently.  (YU make me violate DRY, RestKit?)
    [[manager client] setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
            forHTTPHeaderField:@"BlipboardClientVersion"];
    [[manager client] setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
            forHTTPHeaderField:@"BlipboardClientBuild"];
    [RKObjectManager setSharedManager:manager];
}

// RestKit mapping setup
+ (void)configureRestKitModelMappings
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSAssert(manager!=nil,@"Must call setBaseURL: before setupModelMappings ");
    
    [manager.mappingProvider setErrorMapping:BBError.mapping];
    [manager.mappingProvider setMapping:Area.mapping forKeyPath:@"areas"];
    [manager.mappingProvider setMapping:Channel.dynamicMapping forKeyPath:@"channels.data"];
    [manager.mappingProvider setMapping:Channel.dynamicMapping forKeyPath:@"channel"];
    [manager.mappingProvider setMapping:Paging.mapping forKeyPath:@"channels.paging"];
    [manager.mappingProvider setMapping:Liker.mapping forKeyPath:@"likers"];
    [manager.mappingProvider setMapping:Likes.mapping forKeyPath:@"likes"];
    [manager.mappingProvider setMapping:UserChannel.mapping forKeyPath:@"user"];   
    [manager.mappingProvider setMapping:Account.mapping forKeyPath:@"account"];
    [manager.mappingProvider setMapping:Blip.mapping forKeyPath:@"blips"];
    [manager.mappingProvider setMapping:Blip.mapping forKeyPath:@"blip"];
    [manager.mappingProvider setMapping:Result.mapping forKeyPath:@"result"];
    [manager.mappingProvider setMapping:Region.mapping forKeyPath:@"region"];
    [manager.mappingProvider setMapping:Comment.mapping forKeyPath:@"comment"];
    [manager.mappingProvider setMapping:Comment.mapping forKeyPath:@"comments"];
    [manager.mappingProvider setMapping:NotificationStream.mapping forKeyPath:@"notifications"];
    [manager.mappingProvider setMapping:Topic.sequenceMapping forKeyPath:@"topics"];
    [RKObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-dd'T'HH:mm:ssZ" inTimeZone:nil];
    [RKObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" inTimeZone:nil];
}

- (CLLocation *)myLocation
{
    if (myLocation==nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults synchronize];
        
        CGFloat latitude = [defaults floatForKey:@"lastReportedLatitude"];
        CGFloat longitude = [defaults floatForKey:@"lastReportedLongitude"];
        
        myLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    return myLocation;
}

- (void)setMyLocation:(CLLocation *)location
{
    myLocation = location;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:[NSNumber numberWithFloat:myLocation.coordinate.latitude]
                forKey:@"lastReportedLatitude"];
    [defaults setValue:[NSNumber numberWithFloat:myLocation.coordinate.longitude]
                forKey:@"lastReportedLongitude"];
    [defaults synchronize];
    
    self.locationManager.bestEffortAtLocation = location;
}


@end
