//
//  WebNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/8/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface WebNotification : Notification
@property (nonatomic,strong) NSString *url;
@end
