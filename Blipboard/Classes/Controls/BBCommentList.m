//
//  BBCommentListView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

// displays comments and 
#import "BBCommentList.h"
#import "BBCommentView.h"
#import "Comment.h"

@implementation BBCommentList

- (id)init {
    self = [super init];
    [self _setupStyle];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self _setupStyle];    
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _setupStyle];
    return self;
}

-(void)_setupStyle {
    self.backgroundColor = [UIColor clearColor];
//    self.width = 290;
//    self.layer.cornerRadius = 4;
//    self.backgroundColor = [UIColor bbFadedWarmGray];
}

-(void)setComments:(NSMutableArray *)comments {
    _comments = comments;
    
    // reset the view:
    for (UIView *commentView in self.subviews) {
        if ([commentView isKindOfClass:[BBCommentView class]]) {
            [commentView removeFromSuperview];
        }
    }
    
    // add BBCommentViews, extending this view from the bottom:
    self.height = 0;
    for (Comment *comment in _comments) {
        BBCommentView *commentView = [BBCommentView commentViewWithComment:comment];
        [self addSubview:commentView];
        commentView.ry = self.height;
        self.height += commentView.height;
//        [commentView extendBottomWithSubview:commentView];
    }
}

@end
