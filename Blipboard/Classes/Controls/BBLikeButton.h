//
//  BBLikeButton.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBCountButton.h"
#import "Likes.h"

@interface BBLikeButton : BBCountButton
-(void)configureWithLikes:(Likes *)likes;
@end
