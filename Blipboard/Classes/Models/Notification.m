//
//  Notification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/12/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//
#import <objc/runtime.h>
#import "ServerModel.h"
#import "Notification.h"
#import "NSTimer+Blocks.h"
#import "BBAppDelegate.h"
#import "BlipNotification.h"
#import "ChannelNotification.h"
#import "LikeNotification.h"
#import "CommentNotification.h"
#import "TopUsersNotification.h"
#import "ProfileEditorNotification.h"
#import "TuneInNotification.h"
#import "WebNotification.h"
#import "CreateBlipNotification.h"
#import "NoActionNotification.h"
#import "Channel.h"
#import "Comment.h"
#import "Liker.h"
#import "ReturnedOperation.h"

@implementation Notification

@dynamic isNew;

+(RKDynamicObjectMapping *)dynamicMapping {
    RKDynamicObjectMapping *dynNotificationMap =[RKDynamicObjectMapping dynamicMapping];
    [dynNotificationMap setObjectMapping:BlipNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"blip"];
    
    [dynNotificationMap setObjectMapping:CommentNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"comment"];
    
    [dynNotificationMap setObjectMapping:LikeNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"like"];
    
    [dynNotificationMap setObjectMapping:TuneInNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"tunein"];
    
    [dynNotificationMap setObjectMapping:ChannelNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"channel"];

    [dynNotificationMap setObjectMapping:TopUsersNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"top-users"];
    
    [dynNotificationMap setObjectMapping:ProfileEditorNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"profile-editor"];
    
    [dynNotificationMap setObjectMapping:WebNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"web"];
    
    [dynNotificationMap setObjectMapping:CreateBlipNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"create-blip"];
    
    [dynNotificationMap setObjectMapping:NoActionNotification.mapping
                      whenValueOfKeyPath:@"type" isEqualTo:@"no-action"];
    
    return dynNotificationMap;
}


+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id",       @"id",
     @"type",     @"type",
     @"isNew",    @"_isNew",
     @"time",     @"time",
     @"status",   @"status",
     @"title",    @"title",
     @"subtitle", @"subtitle",
     @"picture",  @"picture",
     nil];

    return mapping;
}

NSString *isNotificationUnreadLocallyKey(NSString *notificationId);
NSString *isNotificationUnreadLocallyKey(NSString *notificationId) {
    return [NSString stringWithFormat:@"NotificationIsUnread.%@",notificationId];
}

-(void)takeAction:(id<NotificationActions>)responder {
    // subclasses should override this
}

-(BOOL)isUnreadLocally {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = isNotificationUnreadLocallyKey(self.id);
    if ([defaults valueForKey:key]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)setIsUnreadLocally:(BOOL)isUnread {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = isNotificationUnreadLocallyKey(self.id);
    if (isUnread) {
        [userDefaults setBool:isUnread forKey:key];
    }
    else {
        self.isNew = FALSE;
        [userDefaults removeObjectForKey:key];
    }
}

-(BOOL)isNew {
    if (self.isNewBlock) {
        return self.isNewBlock();
    }
    else {
        return self._isNew && self._isNew.boolValue;
    }
}

-(void)setIsNew:(BOOL)isNew {
    self._isNew = @(isNew);
}

-(void)set_isNew:(NSNumber *)isNew {
    __isNew = isNew;
    if (isNew.boolValue) {
        [self setIsUnreadLocally:YES]; // enter this notification into the local database as
    }
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    return FALSE;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[%s (%@) %@ %@ {%@,%@}]",
            class_getName([self class]),self.id,
            self.title,self.subtitle,
            self.isNew ? @"new" : @"old",
            self.isUnreadLocally ? @"unread" : @"read"];
}

@end

