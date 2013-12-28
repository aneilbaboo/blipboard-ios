//
//  Liker.h
//  Blipboard
//
//  Created by Jason Fischl on 6/2/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface Liker : Channel

@property (nonatomic,strong) NSDate* createdTime;

+(RKObjectMapping *)mapping;

@end
