//
//  CommentNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface CommentNotification : Notification
@property (nonatomic,strong) NSString *blipId;
@property (nonatomic,readonly) Comment *comment;

@property (nonatomic,strong) NSString *commentId;
@property (nonatomic,strong) Blip *blip;
@end