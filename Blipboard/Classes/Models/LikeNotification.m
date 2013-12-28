//
//  LikeNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "LikeNotification.h"

@implementation LikeNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [LikeNotification class];
    [mapping mapKeyPath:@"likerId" toAttribute:@"likerId"];
    [mapping mapKeyPath:@"blipId" toAttribute:@"blipId"];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    self.liker = [channels objectForKey:self.likerId];
    self.blip = [blips objectForKey:self.blipId];
    
    return (self.blip!=nil) && (self.liker!=nil);
}

-(NSString *)title {
    return super.title ? super.title : self.liker.name;
}

-(NSString *)picture {
    return super.picture ? super.picture : self.liker.picture;
}

-(NSString *)subtitle {
    return super.subtitle ? super.subtitle : @"liked your blip";
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showBlip:self.blip withLiker:self.liker];
}
@end
