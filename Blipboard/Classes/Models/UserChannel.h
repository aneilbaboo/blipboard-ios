//
//  UserChannel.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//

#import "Channel.h"

@interface UserChannel : Channel

@property (nonatomic, strong) NSNumber* isDeveloper;
@property (nonatomic,strong) NSString *firstName;
@property (nonatomic,strong) NSString *lastName;

-(id<CancellableOperation>) getListensTo:(void (^)(NSMutableArray *channels,ServerModelError *error))block;
-(id<CancellableOperation>) getBroadcasts:(void (^)(NSMutableArray *blips,ServerModelError *error))block;

+(RKObjectMapping *)mapping;
+(NSString*)type;

@end