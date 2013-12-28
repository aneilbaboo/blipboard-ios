//
//  BlipNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface BlipNotification : Notification
@property (nonatomic,strong) NSString *blipId;
@property (nonatomic,strong) Blip *blip;
@end
