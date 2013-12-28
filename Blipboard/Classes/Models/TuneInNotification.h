//
//  TuneInNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/10/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface TuneInNotification : Notification
@property (nonatomic,strong) NSString *listenerId;
@property (nonatomic,strong) Channel *listener;
@end
