//
//  CreateBlipNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/10/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "CreateBlipNotification.h"

@implementation CreateBlipNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [CreateBlipNotification class];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    if (self.placeId) {
        self.place = channels[self.placeId];
        return (self.placeId!=nil);
    }
    return YES;
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showCreateBlip:self.place];
}

-(NSString *)title {
    return super.title ? super.title : @"Create a blip";
}

-(NSString *)subtitle {
    if (super.subtitle) {
        return super.subtitle;
    }
    else {
        if (self.place) {
            return [NSString stringWithFormat:@"at %@",self.place.name];
        }
        else {
            return @"";
        }
    }
}
@end
