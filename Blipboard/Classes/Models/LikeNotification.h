//
//  LikeNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface LikeNotification : Notification
@property (nonatomic,strong) NSString *blipId;
@property (nonatomic,strong) NSString *likerId;

@property (nonatomic,strong) Blip *blip;
@property (nonatomic,strong) Channel *liker;
@end

