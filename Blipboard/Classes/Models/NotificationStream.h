//
//  Notifications.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/25/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ServerModel.h"
#import "Notification.h"
#import "Paging.h"

@interface NotificationStream : NSObject
@property (nonatomic,strong) NSArray *notifications;
@property (nonatomic,readonly) NSInteger count;
@property (nonatomic,readonly) NSInteger newNotificationsCount;
+(NotificationStream *)notificationStream:(NSDictionary *)resultDictionary;
+(RKObjectMapping *)mapping;
-(void)clearNewNotifications;
-(Notification *)findById:(NSString *)notificationId;
-(Notification *)latestNotification;
@end
