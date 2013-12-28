//
//  ChannelNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ChannelNotification.h"

@implementation ChannelNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [ChannelNotification class];
    [mapping mapKeyPath:@"channelId" toAttribute:@"channelId"];
    [mapping mapKeyPath:@"display" toAttribute:@"display"];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    self.channel = [channels objectForKey:self.channelId];
    return (self.channel!=nil);
}

-(NSString *)title {
    return super.title ? super.title : self.channel.name;
}

-(NSString *)picture {
    return super.picture ? super.picture : self.channel.picture;
}

-(NSString *)subtitle {
    return super.subtitle ? super.subtitle : @"tap to view";
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showChannel:self.channel andDisplay:self.display];
}

-(ChannelNotificationDisplay)display {
    NSString *displayString = [self._displayString lowercaseString];
    
    if ([displayString isEqualToString:@"blips"]) {
        return ChannelNotificationDisplayBlips;
    }
    else if ([displayString isEqualToString:@"followers"]) {
        return ChannelNotificationDisplayFollowers;
    }
    else if ([displayString isEqualToString:@"following"]) {
        return ChannelNotificationDisplayFollowing;
    }
    else {
        return ChannelNotificationDisplayUnknown;
    }
}
@end