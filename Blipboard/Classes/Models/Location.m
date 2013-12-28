//
//  Location.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/19/12.
//  Copyright (c) 2012 Blipboard, Inc. All rights reserved.
//
//   Represents location data

#import "Location.h"

@implementation Location

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Location class]];
    [mapping mapKeyPathsToAttributes:
     @"latitude",@"latitude",
     @"longitude",@"longitude",
     @"street",@"street",
     @"city",@"city",
     @"state",@"state",
     @"country",@"country",
     nil];
    return mapping;
}

- (CLLocation *)coreLocation {
    if (!self.latitude || !self.longitude) {
        return nil;
    }
    else {
        return [[CLLocation alloc] initWithLatitude:self.latitude.floatValue longitude:self.longitude.floatValue];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[Location %@ %@ %@, %@ (%@,%@)]",
                self.street,self.city,self.state,self.country,
                self.latitude,self.longitude];
}
@end
