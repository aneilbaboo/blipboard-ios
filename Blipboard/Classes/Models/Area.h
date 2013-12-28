//
//  Area.h
//  Blipboard
//
//  Created by Jason Fischl on 8/16/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

//
@class Location;

//
@interface Bounds : NSObject

@property (nonatomic,strong) Location* southwest;
@property (nonatomic,strong) Location* northeast;
+(RKObjectMapping *)mapping;

@end


@interface Area : NSObject
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) Bounds* bounds;
+(RKObjectMapping *)mapping;

@end


