//
//  ChannelStats.m
//  Blipboard
//
//  Created by Jason Fischl on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ChannelStats.h"

@implementation ChannelStats

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ChannelStats class]];
    [mapping mapKeyPathsToAttributes:
     @"score",@"_score",
     @"blips",@"_blips",
     @"followers",@"_followers",
     @"following",@"_following",
     nil];
    return mapping;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[ChannelStats score:%d blips:%d followers:%d, following:%d]",
            self.score, self.blips, self.followers, self.following];
}

-(NSInteger)score {
    return self._score.intValue;
}

-(void)setScore:(NSInteger)score {
    self._score = @(score);
}

-(NSInteger)blips {
    return self._blips.intValue;
}

-(void)setBlips:(NSInteger)blips {
    self._blips = @(blips);
}

-(NSInteger)followers {
    return self._followers.intValue;
}

-(void)setFollowers:(NSInteger)followers {
    self._followers = @(followers);
}

-(NSInteger)following {
    return self._following.intValue;
}

-(void)setFollowing:(NSInteger)following {
    self._following = @(following);
}

@end
