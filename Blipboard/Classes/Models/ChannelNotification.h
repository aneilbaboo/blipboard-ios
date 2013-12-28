//
//  ChannelNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface ChannelNotification : Notification

@property (nonatomic,strong) NSString *channelId;
@property (nonatomic,strong) Channel *channel;
@property (nonatomic,strong) NSString *_displayString;

@property (nonatomic,readonly) ChannelNotificationDisplay display;
@end