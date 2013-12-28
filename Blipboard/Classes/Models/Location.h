//
//  Location.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/19/12.
//  Copyright (c) 2012 Blipboard, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>
@interface Location : NSObject

@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSString *street;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *state;
@property (nonatomic,strong) NSString *country;

+(RKObjectMapping *)mapping;

-(CLLocation *)coreLocation;

@end
