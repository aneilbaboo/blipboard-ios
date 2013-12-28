//
//  NotificationStream.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/25/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "NotificationStream.h"
#import "Notification.h"
#import "Blip.h"
#import "Channel.h"
#import "ReturnedOperation.h"

@implementation NotificationStream {
    Paging *_paging;
    ReturnedOperation *_acknowledge;
}
@dynamic count;
@dynamic newNotificationsCount;

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [mapping mapKeyPath:@"blips" toRelationship:@"blips" withMapping:[Blip dictionaryMapping]];
    [mapping mapKeyPath:@"channels" toRelationship:@"channels" withMapping:[Channel dictionaryMapping]];
    [mapping mapKeyPath:@"data" toRelationship:@"data" withMapping:[Notification dynamicMapping]];
    [mapping mapKeyPath:@"paging" toRelationship:@"paging" withMapping:[Paging mapping]];
    [mapping mapKeyPath:@"operations" toRelationship:@"operations" withMapping:[ReturnedOperation dictionaryMapping]];
    return mapping;
}

+(NotificationStream *)notificationStream:(NSDictionary *)result {
    NSMutableDictionary *rootKey = [result objectForKey:@"notifications"];
    NSMutableArray *notifications = [rootKey objectForKey:@"data"];
    Paging *paging = [rootKey objectForKey:@"paging"];
    NSMutableDictionary *blips = [rootKey objectForKey:@"blips"];
    NSMutableDictionary *channels = [rootKey objectForKey:@"channels"];
    ReturnedOperation *acknowledgeOperation = [[rootKey objectForKey:@"operations"] objectForKey:@"acknowledge"];

    NotificationStream *ns = [[NotificationStream alloc] init];

    // only display non-corrupt notifications
    NSMutableArray *resolvedNotifications = [NSMutableArray arrayWithCapacity:notifications.count];

    for (Notification *notification in notifications) {
        BBLog(@"resolving... %@",notification);
        if ([notification resolveBlips:blips andChannels:channels]) {
            [resolvedNotifications addObject:notification];
        }
        else {
            BBLog(@"Unable to resolve notification: %@",notification);
            [notification resolveBlips:blips andChannels:channels];
        }
    }
    ns->_notifications = resolvedNotifications;

/**
//    !am! for debugging:
//    WebNotification *wn= [WebNotification new];
//    wn.id = [@(arc4random_uniform(1000000)) stringValue];
//    wn.title = @"Web notification";
//    wn.subtitle = @"view the blipboard site";
//    wn.url = @"http://blipboard.com";
//
//    [ns->_notifications insertObject:wn atIndex:0];
*/
    
    ns->_paging = paging;
    ns->_acknowledge = acknowledgeOperation;

    return ns;
}

-(Notification *)findById:(NSString *)notificationId {
    for (Notification *notification in _notifications) {
        if ([notification.id isEqualToString:notificationId]) {
            return notification;
        }
    }
    return nil;
}

-(NSInteger)count {
    return _notifications.count;
}

-(NSInteger)newNotificationsCount {
    NSInteger count = 0;
    for (Notification *notification in self.notifications) {
        if (notification.isNew) {
            count++;
        }
    }
    return count;
}

-(void)clearNewNotifications {
    for (Notification *notification in _notifications) {
        notification.isNew = NO;
    }
    [_acknowledge makeCallWithBlock:^(NSDictionary *result, ServerModelError *error) {}];
}

-(NSArray *)notifications {
    return _notifications;
}

-(Notification *)latestNotification {
    if (_notifications && _notifications.count>0) {
        return _notifications[0];
    }
    else {
        return nil;
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[NotificationStream #%X new:%d total:%d]",(int)self,self.newNotificationsCount,self.count];
}
@end
