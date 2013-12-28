//
//  ChannelStats.h
//  Blipboard
//
//  Created by Jason Fischl on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelStats : NSObject

@property (strong,nonatomic) NSNumber* _score;
@property (nonatomic) NSInteger score;
@property (strong,nonatomic) NSNumber* _blips;
@property (nonatomic) NSInteger blips;
@property (strong,nonatomic) NSNumber* _followers;
@property (nonatomic) NSInteger followers;
@property (strong,nonatomic) NSNumber* _following;
@property (nonatomic) NSInteger following;

+(RKObjectMapping *)mapping;

@end
