//
//  CLLocation+distanceHelper.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "CLLocation+distanceHelper.h"

@implementation DistanceQuantity

-(id)init:(CGFloat)distance withUnits:(NSString *)units {
    self = [super init];
    self.distance = distance;
    self.units = units;
    return self;
}


-(NSString *)description {
    return [NSString stringWithFormat:@"%.1f %@",self.distance,self.units];
}
@end

@implementation CLLocation (distanceHelper)

// !am! a quite incomplete, very purpose-built helper for producing "nice" distances in miles or feet
-(DistanceQuantity *)niceImperialDistanceFrom:(CLLocation *)location showFeetUpTo:(CGFloat)feet {
    if (location) {
        CGFloat meters = [self distanceFromLocation:location];
        const CGFloat metersPerMile = 1609.344;
        const CGFloat metersPerFeet = .3048;
        // more than .5 miles?
        if (meters/metersPerFeet > feet) {
            CGFloat miles = meters/metersPerMile;
            return [[DistanceQuantity alloc] init:miles withUnits:@"miles"];
        }
        else {
            CGFloat feet = meters/metersPerFeet;
            return [[DistanceQuantity alloc] init:feet withUnits:@"feet"];
        }
    }
    else {
        return nil;
    }
}

@end
