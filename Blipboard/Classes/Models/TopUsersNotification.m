//
//  TopUsersNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/8/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "TopUsersNotification.h"

@implementation TopUsersNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [TopUsersNotification class];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    return YES;
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showGuruList];
}
@end
