//
//  Result.h
//  Blipboard
//
//  Created by Jason Fischl on 3/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject
@property (nonatomic,strong) id result;

+(RKObjectMapping *)mapping;

@end
