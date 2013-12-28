//
//  BBRemoteNotificationManager.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/18/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBRemoteNotificationManager.h"


NSString * const BBRemoteNotificationManagerDidUpdateStream = @"BBRemoteNotificationManagerDidUpdateStream";
NSString * const BBRemoteNotificationManagerStream = @"stream";
NSString * const BBRemoteNotificationManagerNotification = @"notification";
NSString * const BBRemoteNotificationManagerLaunch = @"start";
NSString * const BBRemoteNotificationManagerFresh = @"fresh";

//
// BBRemoteNotificationManager
//
@implementation BBRemoteNotificationManager {
    BOOL _allowPromptDialog; // controls whether promptUserToEnablePushNotDialog does anything
    NSString *_deviceToken;  // temporary store for the device token in case account is not yet known
    NSString *_startNotificationId;
    NSOperation *_getNotificationsOperation;
    BOOL _gotInitialNotifications;  // manager tries at various points to getNotifications on startup
                                    // this state var ensures it happens only once
    Account *_observedAccount;
    
}
//@dynamic autoRequestDeviceToken;

+(BBRemoteNotificationManager *)sharedManager {
    static BBRemoteNotificationManager *shared;
    if (!shared) {
        shared = [BBRemoteNotificationManager new];
        shared->_refreshThrottleSeconds = 60*5; // wait 5 min between hits on the server
        shared->_recentNotificationSeconds = 60*60*24*3; // 1 day until notification is not considered recent
    }
    
    return shared;
}

-(void)dealloc {
    [self unobserveAccount];
}

#pragma mark -
#pragma mark Blipboard integration
NSString * const kRecentNewNotification = @"***SHOW_RECENT_NEW_NOTIFICATION***";

-(void)requestRefresh {
    [self requestRefresh:NO];
}

-(void)requestRefresh:(BOOL)force {
    NSDate *now = [NSDate date];
    NSTimeInterval secondsSinceLastRefresh = [_lastRefreshTime timeIntervalSinceDate:now];
    if (force || !_lastRefreshTime || secondsSinceLastRefresh>self.refreshThrottleSeconds) {
        [self getNotificationsAndDisplay:nil];
    }
}

-(void)clearNewNotifications {
    [self.notificationStream clearNewNotifications];
    [self postStreamUpdate:self.notificationStream fresh:NO notification:nil didLaunch:NO];
}

/** !am! internal fn - might be moved to a separate manager, depending on how things go
 *       there's logic in here that extends beyond the responsibilities of the notification manager
 */
-(NSMutableArray *)onboardingNotifications {
    Account *account = BBAppDelegate.sharedDelegate.myAccount;
    NSMutableArray *onboardingNotifs = [NSMutableArray arrayWithCapacity:2];
    
    if (!account.capabilities.disableStartupNotifications) {
        const NSInteger kOnboardingBlipCount = 3;
        NSInteger remainingBlips = MAX(kOnboardingBlipCount - account.stats.blips,0);
        BOOL profileComplete = account.desc.length>0;
        
        UIImage *icon = [UIImage imageNamed:@"Icon.png"];
        
        // show all notifications if any are incomplete
        if (remainingBlips>0 || !profileComplete) {
            // step 1: start blipping!
            CreateBlipNotification *createBlip = [CreateBlipNotification new];
            createBlip.id = [@([[NSDate date] timeIntervalSince1970]) stringValue];
            createBlip.status = remainingBlips ? @"to do" : @"done";
            createBlip.isNew = remainingBlips;
            if (remainingBlips) {
                createBlip.title = @"Step 1: Get started";
                createBlip.subtitle = [NSString stringWithFormat:@"Add %d interesting things to your map.",remainingBlips];
                ;
            }
            else {
                createBlip.title = @"Step 1";
                createBlip.subtitle = @"Created 3 blips";
            }
            createBlip.pictureImage = icon;
            [createBlip setIsNewBlock:^BOOL{
                return BBAppDelegate.sharedDelegate.myAccount.stats.blips<kOnboardingBlipCount;
            }];
            [onboardingNotifs addObject:createBlip];
        
            // step 2: fill out profile
            ProfileEditorNotification *profileEdit = [ProfileEditorNotification new];
            profileEdit.id = [@([[NSDate date] timeIntervalSince1970]) stringValue];
            [profileEdit setIsNewBlock:^BOOL{
                return (BBAppDelegate.sharedDelegate.myAccount.desc.length==0);
            }];
            profileEdit.title = @"Step 2";
            profileEdit.subtitle = @"Complete your profile";
            profileEdit.status = profileComplete ? @"done" : @"to do";
            profileEdit.pictureImage = icon;
            [onboardingNotifs addObject:profileEdit];
        }
    }
    return onboardingNotifs;
}

/**
 * Internal fn: gets the latest notifications from the server, and posts an NSNotification
 * about the received notification.
 * If notificationId is kRecentNewNotification, find the most recent new notification less than
 * recentNotificationSeconds old and post it in the stream update
 * returns TRUE if operation was attempted
 */
-(BOOL)getNotificationsAndDisplay:(NSString *)notificationId {
    
    // retrieve BB NotificationStream and post an NSNotification
    if (BBAppDelegate.sharedDelegate.authenticated) {
        NSArray *onboardingNotifications = [self onboardingNotifications];
        BOOL showRecentNew = (notificationId == kRecentNewNotification) || onboardingNotifications.count>0;
        // if we've been asked to show the recent new notification,
        // ignore the swipe (which should be nil anyway)
        BOOL didLaunch = !showRecentNew && [_startNotificationId isEqualToString:notificationId];
        
        BBLog(@"%@%@",notificationId, didLaunch ? @" (launched)" : @"");
        
        [_getNotificationsOperation cancel];
        _getNotificationsOperation = nil;

        
        _getNotificationsOperation = [BBAppDelegate.sharedDelegate.myAccount getNotifications:^(NotificationStream *notificationStream, ServerModelError *error) {
            if (!error) {
                
                _notificationStream = notificationStream;
                NSArray *allNotifications = [onboardingNotifications arrayByAddingObjectsFromArray:_notificationStream.notifications];

                _notificationStream.notifications = allNotifications;
                
                if (showRecentNew) {
                    Notification *recentNew = [self findRecentNewNotification];
                    [self postStreamUpdate:_notificationStream fresh:YES notification:recentNew.id didLaunch:NO];
                }
                else {
                    // show notificationId
                    [self postStreamUpdate:_notificationStream fresh:YES notification:notificationId didLaunch:didLaunch];
                }
                _startNotificationId = nil;
                
                // remember last time for requestNotificationRefresh
                _lastRefreshTime = [NSDate date];

            }
            else {
                _lastRefreshTime = nil;
            }
        }];
        
        return YES;
    }
    
    return NO;
}

-(Notification *)findRecentNewNotification {
    for (Notification *notification in _notificationStream.notifications) {
        if (notification.isNew) {
            NSDate *now = [NSDate date];
            NSTimeInterval secondsAgo = [notification.time timeIntervalSinceDate:now];
            if (secondsAgo < self.recentNotificationSeconds) {
                // it is recent!
                return notification;
            }
        }
    }
    return nil;
}

#pragma mark -
#pragma mark NSNotificationCenter methods
/** Internal fn posts an NSNotification to the default NSNotificationCenter
 *  Reporting that the NSNotificationStream has been reloaded, and optionally that
 *  a new notification was received.
 */
-(void)postStreamUpdate:(NotificationStream *)stream fresh:(BOOL)fresh notification:(NSString *)newNotificationId didLaunch:(BOOL)launch  {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    if (_notificationStream) {
        userInfo[BBRemoteNotificationManagerStream] = _notificationStream;
    }
    
    Notification *newNotif = [_notificationStream findById:newNotificationId];
    if (newNotif) {
        userInfo[BBRemoteNotificationManagerNotification] = newNotif;
    }
    
    if (launch) {
        userInfo[BBRemoteNotificationManagerLaunch] = @(YES);
        [Intercom updateAttributes:@{@"lastLaunchedFromAlert": @([[NSDate date] timeIntervalSince1970])}];
    }
    
    if (fresh) {
        userInfo[BBRemoteNotificationManagerFresh] = @(YES);
    }
        
    [[NSNotificationCenter defaultCenter]
     postNotificationName:BBRemoteNotificationManagerDidUpdateStream
     object:self
     userInfo:userInfo];
}

#pragma mark -
#pragma mark APNS stuff

/** Saves the push notification authorizations allowed by the user
 *  This method detects changes to push notification authorization over time,
 *  and reports these as events to Flurry.
 */
-(void)recordPushNotificationsAuthorization {
    NSString * const kPushNotificationsState = @"PushNotificationsState";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstTimeStateChange = ![defaults objectForKey:kPushNotificationsState];
    NSInteger previousState = [defaults integerForKey:kPushNotificationsState];
    UIRemoteNotificationType currentState = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (firstTimeStateChange || previousState!=currentState) {
        if (firstTimeStateChange) {
            BBLog(@"recording initial push notification state:%X",currentState);
        }
        else {
            BBLog(@"remote notifications changed from %X to %X", previousState,currentState);
        }
        [defaults setInteger:currentState forKey:kPushNotificationsState];
        [defaults synchronize];
        if (currentState == UIRemoteNotificationTypeNone) {
            [Flurry logEvent:kFlurryDisabledPushNotifications];
            [Intercom updateAttributes:@{@"allowAlerts": @(NO)}];
        }
        else {
            NSString *allowAlert = (currentState & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No";
            NSString *allowBadge = (currentState & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No";
            NSString *allowSound = (currentState & UIRemoteNotificationTypeSound) ? @"Yes" : @"No";
            
            [Flurry logEvent:kFlurryEnabledPushNotifications
                       withParameters:@{@"alerts":allowAlert,@"badges":allowBadge,@"sounds":allowSound}];
            [Intercom updateAttributes:@{@"allowAlerts": @(YES)}];
        }

    }
    
    if (currentState==UIRemoteNotificationTypeNone) {
        _allowPromptDialog = YES;
    }
    else {
        _allowPromptDialog = NO;
    }
    
}

- (void)promptUserToEnablePushNotificationsIfNeeded {
    [self promptUserToEnablePushNotifications:NO];
}

- (void)promptUserToEnablePushNotifications:(BOOL)force {
    if (force || _allowPromptDialog) {
        RIButtonItem *okItem = [RIButtonItem item];
        okItem.label = @"OK";
        okItem.action = ^{}; // no-op block
        NSString *message = @"Enable push notifications to get alerts.\n\nGo to Settings > Notifications > Blipboard";
        [Flurry logEvent:kFlurryPromptUserToEnablePushNotifications];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Push notifications disabled"
                                                        message:message
                                               cancelButtonItem:okItem otherButtonItems:nil];
        [alert show];
        
        _allowPromptDialog = NO;
    }
}

/** Request APNS token for push notifications
 */
- (void) requestDeviceToken {
    BBTrace();
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert ];
}
-(void) registerDeviceToken:(NSString*)deviceToken forAccountId:(NSString *)accountId {
    assert(deviceToken);

    NSString *body = [NSString stringWithFormat:@"{ \"alias\": \"%@%@\" }", URBANAIRSHIP_NAMESPACE, accountId];
    NSString *username = URBANAIRSHIP_USERNAME;
    NSString *password = URBANAIRSHIP_PASSWORD;
    
    NSData* json = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://go.urbanairship.com/api/device_tokens/%@", deviceToken]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    // !am! using the _weakRequest (below) looks nasty, but this is correct.
    //      Why?  [request startAsynchronous] stores a strong ref to request
    //      in the global sharedQueue.  The completionBlock is not used by
    //      anything other than the request; therefore, _weakRequest is valid
    //      whenever completionBlock is called.
#if BBLogging
    __unsafe_unretained ASIHTTPRequest *_weakRequest = request;
#endif
    [request addRequestHeader:@"Content-type" value:@"application/json"];
    [request appendPostData:json]; // JSON as NSData
    [request setRequestMethod:@"PUT"];
    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    [request setUsername:username];
    [request setPassword:password];
    [request setCompletionBlock:^{
        BBLog(@"UrbanAirship (%@) register: %@ response: %@", username, body, [_weakRequest responseString]);
    }];
    
    [request startAsynchronous];
}

//NSString * const kAutoRequestDeviceToken = @"BBRemoteNotificationManagerAutoRequestDeviceToken";
//-(BOOL)autoRequestDeviceToken {
//    return [[NSUserDefaults standardUserDefaults] boolForKey:kAutoRequestDeviceToken];
//}
//
//-(void)setAutoRequestDeviceToken:(BOOL)autoRequestDeviceToken {
//    [[NSUserDefaults standardUserDefaults] setBool:autoRequestDeviceToken forKey:kAutoRequestDeviceToken];
//}

-(void)clearAppIconBadge {
    // clear the app icon badge
    NSInteger badgeCount = UIApplication.sharedApplication.applicationIconBadgeNumber;
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
    if (badgeCount) {
        [Flurry logEventWithParams:kFlurryNotificationStartedWithBadge,
         @"badge-count",[@(badgeCount) stringValue],
         nil];
    }
}

#pragma mark -
#pragma mark Account observation
-(void)observeAccount:(Account *)account {
    [self unobserveAccount];
    _observedAccount = account;
    [_observedAccount addPropertiesObserver:self];
}

-(void)unobserveAccount {
    [_observedAccount removePropertiesObserver:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object==_observedAccount &&
        ([keyPath isEqualToString:@"stats"] ||
         [keyPath isEqualToString:@"description"])) {
            [self requestRefresh:YES];
        }
}

#pragma mark -
#pragma mark External Integration

- (void)didAuthenticate {
    BBTrace();
    [self observeAccount:BBAppDelegate.sharedDelegate.myAccount];
    if (!_gotInitialNotifications) {
        [self getNotificationsAndDisplay:_startNotificationId];
    }
    [self requestDeviceToken];
}

#pragma mark UIApplicationDelegate integration
//
// !am! These methods are called by the BBAppDelegate: I chose not to use NSNotificationCenter events
//       because some are provided, some aren't.  Chose consisten
//

- (void)didBecomeActive {
    BBTrace();
    
    [self clearAppIconBadge];
    
    // !am! We get the startNotificationId earlier
    //      during didFinishLaunchingWithOptions
    if (!_gotInitialNotifications) {
        _gotInitialNotifications = [self getNotificationsAndDisplay:_startNotificationId];
    }
    
    if (BBAppDelegate.sharedDelegate.authenticated) {
        [self recordPushNotificationsAuthorization];
    }
}

-(void)didEnterBackground {
    BBTrace();
    // ensures we try to get notifications when we return to foreground
    _gotInitialNotifications = FALSE;
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *strDeviceToken = [[[[deviceToken description]
                                  stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                 stringByReplacingOccurrencesOfString: @">" withString: @""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    BBLog (@"deviceToken: %@", strDeviceToken);
    
    if (deviceToken) {
        Account *account = BBAppDelegate.sharedDelegate.myAccount;
        if (account && BBAppDelegate.sharedDelegate.authenticated) {
            [self registerDeviceToken:strDeviceToken forAccountId:account.id];
        }
    }
    
    [self recordPushNotificationsAuthorization];
    
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    BBLog (@"error %@", error);
    [Flurry logError:kFlurryError message:@"Failed to register for remote notifications" error:error];
    
    [self recordPushNotificationsAuthorization];
}

-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
     UIApplicationState state = UIApplication.sharedApplication.applicationState;
    switch (state) {
        case UIApplicationStateInactive:
        case UIApplicationStateBackground: // user started app with notification
        {
            BBLog(@"Brought into foreground with: %@",userInfo);
            _startNotificationId = userInfo[@"id"]; // we're in background, save for didBecomeActive
            [Flurry logEvent:kFlurryNotificationInBackground];
            break;
        }
            
        case UIApplicationStateActive:
        default:
        {
            // We are in application, and presumably logged in.
            // There is a corner case where the notification is received, but we are not yet logged in.
            // If so, getNotificationsAndDisplay will do nothing.
            // However, getNotificationsAndDisplay will be called after authentication, so we are guaranteed
            // to get the notifications even in this case.
            BBLog(@"Received in foreground: %@",userInfo);
            NSString *notificationId = userInfo[@"id"];
            [self getNotificationsAndDisplay:notificationId];
            
            [Flurry logEvent:kFlurryNotificationInForeground];
            break;
        }
    }
}

-(void)didFinishingLaunchingWithOptions:(NSDictionary *)options {
    BBLog(@"options: %@",options);
    NSDictionary* pushInfo = [options objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSInteger badgeCount = UIApplication.sharedApplication.applicationIconBadgeNumber;

    // pushInfo = @{@"id":@"51535998c02163d9b8960402"};
    
    if (pushInfo != nil)
    {
        BBLog(@"Launched by swipe: %@", pushInfo);
        _startNotificationId = pushInfo[@"id"]; // starting from killed, save for didBecomeActive
        [Flurry logEventWithParams:kFlurryNotificationInBackground,
         @"badge-count",@(badgeCount),
         nil];
    }
        
}

@end
