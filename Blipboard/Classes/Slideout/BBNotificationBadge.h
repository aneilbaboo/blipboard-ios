//
//  NotificationsBadge.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/24/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBBadgeView.h"

// Displays a badge representing the current new notification count
// Receives messages from BBRemoteNotificationManager and automatically updates &
// animates its state
@interface BBNotificationBadge : BBBadgeView
@property (nonatomic) NSInteger badgeCount;

@property (nonatomic) BOOL autoUpdate;  // If TRUE, handles BBRemoteNotificationManager stream updates
                                        // default: TRUE
+(BBNotificationBadge *)badge ;

// !am! TODO get rid of this
//+(void)updateAllBadges:(NSInteger)count;
@end
