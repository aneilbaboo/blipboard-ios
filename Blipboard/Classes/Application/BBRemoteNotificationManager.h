//
//  BBRemoteNotificationManager.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/18/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
//
// BBRemoteNotificationManager
//    * coordinates with the Apple, Urban Airship and Blipboard servers
//    * handles RemoteNotifications both in background and foreground
//    * maintains an up-to-date NotificationStream object
//    * emits NSNotifications which are used by other objects like BBNotificationBar
//      and BBNotificationBadge
//
// BBRemoteNotificationManager requires:
//    * access to the Account object
//    * wiring in to the appropriate UIApplicationDelegate methods
//      - note: although we could have used NSNotificationCenter to receive some of
//              these events, we opted
//


// The BBRemoteNotificationManagerStreamUpdate NSNotification:
//    * is posted on the default NSNotificationCenter whenever:
//                  - the stream is retrieved from the server
//                  - stream.newNotificationsCount changes (e.g., badge is cleared)
//    * userInfo dictionary has keys:
//         - BBRemoteNotificationManagerStream: NotificationStream always contains the latest notificationStream
//         - BBRemoteNotificationManagerNotification: (optional) Notification: new notification
//         - BBRemoteNotificationManagerLaunch: (optional) NSNumber: if present, indicates notification was a swipe
//         - BBRemoteNotificationManagerFresh: (optional) NSNumber: if present, indicates notificationStream
//                                                                  was just downloaded from server
// NSNotification name
NSString * const BBRemoteNotificationManagerDidUpdateStream;

// NSNotification userInfo values
NSString * const BBRemoteNotificationManagerStream;
NSString * const BBRemoteNotificationManagerFresh;        // NSNumber (YES) : if stream was freshly retrieved from
                                                          //                  server, otherwise not present
NSString * const BBRemoteNotificationManagerNotification; // Notification: a notification was received
                                                          //      UI should make an effort to show this to the user
NSString * const BBRemoteNotificationManagerLaunch;        // NSNumber (YES) : user started app by tapping/swiping
                                                          //        an iOS notification; otherwise not present.
                                                          //        BBRemoteNotiicationManagerNotification is the
                                                          //        start notification.


@interface BBRemoteNotificationManager : NSObject
@property (nonatomic,readonly) NotificationStream *notificationStream;
@property (nonatomic) NSTimeInterval recentNotificationSeconds; // how long until a notification is not considered recent? (default 1 days)
@property (nonatomic) NSTimeInterval refreshThrottleSeconds;  // wait time between asking for fresh notifications (default 5m)
@property (nonatomic,readonly) NSDate *lastRefreshTime;
// however, we always get notifications

+(BBRemoteNotificationManager *)sharedManager;

// Public methods
- (void) requestDeviceToken;
- (void) promptUserToEnablePushNotificationsIfNeeded; // called externally

/**
 * Request the manager to send a notification update
 * This method throttles requests to the server (and only calls again after refreshThrottle seconds)
 */
- (void) requestRefresh;
- (void) requestRefresh:(BOOL)force; // force BOOL = guarantees notifications will be refreshed.
/**
 * Acknowledge new notifications; a stream update will be posted
 */
- (void) clearNewNotifications;

// External integration points:

// UIApplicationDelegate
- (void) didBecomeActive;
- (void) didEnterBackground;
- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void) didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void) didFinishingLaunchingWithOptions:(NSDictionary *)options;

//// for catching the authentication event
- (void) didAuthenticate;
@end
