//
//  BBAppDelegate.h
//  Blipboard
//
//  Created by Jason Fischl on 1/26/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <RestKit/RestKit.h>
#import <Heatmaps/Heatmaps.h>
#import <Reachability.h>

#import "MainBlipsViewController.h"
#import "SlideoutViewController.h"
#import "Account.h"
#import "Region.h"
#import "UserChannel.h"
#import "BBImageView.h"
#import "NIWebController.h"
#import "BBLocationManager.h"
#import "LoginViewController.h"

@class ServerModelError;
@class BBViewController;
@class ErrorViewController;

/** Blipboard's AppDelegate */
@interface BBAppDelegate : UIResponder <UIApplicationDelegate, LoginViewControllerDelegate>

@property (strong, nonatomic) UIWindow* window;
@property (nonatomic,strong) Account* myAccount;
@property (nonatomic, strong) Cancellation* cancellation;
@property (nonatomic, strong) NSDate* lastActiveTimestamp;
@property (nonatomic, strong) BBLocationManager* locationManager;
@property (nonatomic) BOOL starting; // indicates that the app is becoming active. 

// easy access to singleton controllers:
@property (nonatomic, readonly) MainBlipsViewController *mainViewController;
@property (nonatomic, readonly) SlideoutViewController *slideoutViewController;
@property (nonatomic, readonly) BBNavigationController *mainNavController;
@property (nonatomic, weak) ErrorViewController *currentErrorViewController; // set by ErrorViewController constructor

// These properties are set from the metadata in the push notification
// blipId of the event if it refers to a blip (may be nil)
// userId of the event (may be nil)
@property (nonatomic, strong) NSDictionary* pushInfo;
@property (nonatomic) BOOL haveSeenGuruList;
@property CLLocationCoordinate2D pushCoordinate;

@property (nonatomic,strong) Reachability* reach;
@property BOOL authenticated;

+ (BBAppDelegate*) sharedDelegate;

// base URI
+ (void)setBaseURI:(NSString *)baseURL;
+ (NSString *)baseURI;

// setup and registration
- (void) showFirstTimeGuruList;

- (void) createAccountWithToken:(NSString*)token;
- (void) saveAccount;
- (void) saveAccount:(Account*)account;
- (void) reportFacebookToken; // report what is cached in self.facebook.accessToken
- (void) reportFacebookToken:(NSString*)token;
- (void) showAuthDialog;
- (void) setupAuthentication;
- (void) retry:(NSError*)error;
- (void) cancel;

- (void) hideNetworkDisconnectedError;
- (void) showNetworkDisconnectedError; // used during registration/authentication
- (void) reachabilityStatusChanged:(NSNotification*) notification;
- (BOOL) isNetworkReachable;
- (void) onMainViewControllerIsVisible:(MainBlipsViewController *)mainViewController;
- (void) hideSplashScreen;
- (void) showSplashScreen;
- (BOOL) isSplashVisible;

- (void) onAuthenticated;

// Flurry analytics
- (void) logFlurryEvent:(NSString*)name;

- (BOOL)openURL:(NSURL*)url;  // Handle web links via web controller
- (CLLocation *)myLocation;
- (void)setMyLocation:(CLLocation *)location;

@end
