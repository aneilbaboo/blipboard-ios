//
//  UserChannel.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//

#import "BBAppDelegate.h"
#import "UserChannel.h"
#import "BBLog.h"

@implementation UserChannel

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [Channel mapping];
    mapping.objectClass = [UserChannel class];
    
    [mapping mapKeyPathsToAttributes:
     @"isDeveloper", @"isDeveloper",
     @"firstName",@"firstName",
     @"lastName",@"lastName",
     // add user-specific mappings here
     // ...
     nil];
    
    return mapping;
}

+(NSString*)type
{
    return @"user";
}

-(id<CancellableOperation>) getListensTo:(void (^)(NSMutableArray *channels, ServerModelError *error))block 
{
    BBTrace();
    __block void (^_block)(NSMutableArray *channels,ServerModelError *error) = block;
    return[self loadObjectsAtResourcePath:[NSString stringWithFormat:@"/accounts/%@/listensTo", self.id] 
                              block:^(ServerModel *channel,NSDictionary *results,ServerModelError *error) {
                                  _block([results objectForKey:@"channels"],error);
                              }];
}

-(id<CancellableOperation>) getBroadcasts:(void (^)(NSMutableArray *blips, ServerModelError *error))block 
{
    BBTrace();
    __block void (^_block)(NSMutableArray *blips,ServerModelError *error) = block;
    return [self loadObjectsAtResourcePath:[NSString stringWithFormat:@"/accounts/%@/broadcasts", self.id] 
                              block:^(ServerModel *channel,NSDictionary *results,ServerModelError *error) {
                                  _block([results objectForKey:@"blips"],error);
                              }];

}

@end
