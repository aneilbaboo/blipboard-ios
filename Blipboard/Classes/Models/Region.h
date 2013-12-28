//
//  Region.h
//  Blipboard
//
//  Created by Jason Fischl on 5/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Region : NSObject

@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSNumber *radius;

+(RKObjectMapping *)mapping;

@end
