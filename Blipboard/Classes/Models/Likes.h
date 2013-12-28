//
//  Likes.h
//  Blipboard
//
//  Created by Jason Fischl on 6/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Likes : NSObject

@property (nonatomic,strong) NSArray* likers;
@property (nonatomic,strong) NSNumber* _isLiker;
@property (nonatomic)        BOOL isLiker;
@property (nonatomic,strong) NSNumber* _likeCount;
@property (nonatomic)        NSInteger likeCount;

+(RKObjectMapping *)mapping;

@end
