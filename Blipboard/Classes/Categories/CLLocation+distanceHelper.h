//
//  CLLocation+distanceHelper.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface DistanceQuantity : NSObject
@property (nonatomic) CGFloat distance;
@property (nonatomic,strong) NSString *units;
-(id)init:(CGFloat)distance withUnits:(NSString *)units;
@end

@interface CLLocation (distanceHelper)
-(DistanceQuantity *)niceImperialDistanceFrom:(CLLocation *)location showFeetUpTo:(CGFloat)feet;
@end
