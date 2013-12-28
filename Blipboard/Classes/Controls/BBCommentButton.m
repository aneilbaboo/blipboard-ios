//
//  BBCommentButton.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBCommentButton.h"
#import "Paging.h"

@implementation BBCommentButton
-(void)setupStyle {
    [super setupStyle];
    [self setImage:[UIImage imageNamed:@"icn_comment_off.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"icn_comment_off.png"] forState:UIControlStateNormal|UIControlStateHighlighted];
    [self setImage:[UIImage imageNamed:@"icn_comment_off.png"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"icn_comment_off.png"] forState:UIControlStateSelected|UIControlStateHighlighted];
}

@end
