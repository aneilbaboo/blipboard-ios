//
//  TuneInNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "TuneInNotification.h"

@implementation TuneInNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [TuneInNotification class];
    [mapping mapKeyPath:@"listenerId" toAttribute:@"listenerId"];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    self.listener = [channels objectForKey:self.listenerId];
    return (self.listener!=nil);
}

-(NSString *)title {
    return super.title ? super.title : self.listener.name;
}

-(NSString *)picture {
    return super.picture ? super.picture : self.listener.picture;
}

-(NSString *)subtitle {
    return super.subtitle ? super.subtitle : @"is following your blips";
}

-(void)takeAction:(id<NotificationActions>)responder {
    // show the following tab of the user who just tuned in (which should include the current user)
    [responder showChannel:self.listener andDisplay:ChannelNotificationDisplayBlips];
}
@end