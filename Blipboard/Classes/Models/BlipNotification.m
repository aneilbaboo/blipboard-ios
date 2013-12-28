//
//  BlipNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/7/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BlipNotification.h"
#import "CLLocation+distanceHelper.h"

@implementation BlipNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [BlipNotification class];
    [mapping mapKeyPath:@"blipId" toAttribute:@"blipId"];
    return mapping;
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    self.blip = [blips objectForKey:self.blipId];
    return (self.blip!=nil);
}

-(NSString *)title {
    return super.title ? super.title : self.blip.author.name;
}

-(NSString *)picture {
    return self.blip.author.picture;
}

-(NSString *)subtitle {
    if (super.subtitle) {
        return super.subtitle;
    }
    else if (self.blip.author.type==ChannelTypePlace) {
        return [NSString stringWithFormat:@"posted a blip %@",
                [self distanceAwayFromCurrentLocation]];
    }
    else if (self.blip.author.type==ChannelTypeUser) {
        return [NSString stringWithFormat:@"blipped @ %@ %@",self.blip.place.name,
                [self distanceAwayFromCurrentLocation]];
    }
    return @"";
}

// internal helper fn 
-(NSString *)distanceAwayFromCurrentLocation {
    CLLocation *bestEffort =BBAppDelegate.sharedDelegate.locationManager.bestEffortAtLocation;
    if (bestEffort) {
        DistanceQuantity *distance = [bestEffort niceImperialDistanceFrom:self.blip.place.location.coreLocation
                                                             showFeetUpTo:500];
        if ([distance.units isEqualToString:@"miles"] && distance.distance<=2) {
            return [NSString stringWithFormat:@"%@ away",distance.description];
        }
    }
    return @"";
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showBlip:self.blip];
}
@end
