//
//  Likes.m
//  Blipboard
//
//  Created by Jason Fischl on 6/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Likes.h"

@implementation Likes
@dynamic isLiker;
@dynamic likeCount;

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"isLiker",            @"_isLiker",
     @"likeCount",          @"_likeCount",
     nil];
    return mapping;
}


-(BOOL)isLiker {
    return self._isLiker.boolValue;
}

-(void)setIsLiker:(BOOL)isLiker {
    self._isLiker = @(isLiker);
}

-(NSInteger)likeCount {
    return self._likeCount.unsignedIntegerValue;
}

-(void)setLikeCount:(NSInteger)likeCount {
    self._likeCount = @(likeCount);
}

@end
