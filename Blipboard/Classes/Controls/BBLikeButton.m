//
//  BBLikeButton.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBLikeButton.h"

@implementation BBLikeButton

-(void)setupStyle {
    [super setupStyle];
    [self setImage:[UIImage imageNamed:@"icn_like_off.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"icn_like_on.png"] forState:UIControlStateNormal|UIControlStateHighlighted];
    [self setImage:[UIImage imageNamed:@"icn_like_on.png"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"icn_like_off.png"] forState:UIControlStateSelected|UIControlStateHighlighted];
}

-(void)configureWithLikes:(Likes *)likes {
    self.selected = likes.isLiker;
    self.count = likes.likeCount;
}

@end
