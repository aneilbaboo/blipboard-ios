//
//  TuneInButton.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBTuneInButton.h"

@implementation BBTuneInButton


#pragma mark -
#pragma mark Initialization
- (id)initWithFrame:(CGRect)frame
{
    assert(false);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.titleLabel.font = [UIFont bbCondensedBoldFont:15];

    [self setBackgroundImage:[UIImage imageNamed:@"btn_follow_follow.png"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor bbWhite] forState:UIControlStateNormal];
    [self setTitle:@"Follow" forState:UIControlStateNormal];
    [self setTitle:@"Follow" forState:UIControlStateNormal|UIControlStateHighlighted];
    
    [self setBackgroundImage:[UIImage imageNamed:@"btn_follow_unfollow.png"] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor bbWarmGray] forState:UIControlStateSelected];
    [self setTitle:@"Following" forState:UIControlStateSelected];
    [self setTitle:@"Following" forState:UIControlStateSelected|UIControlStateHighlighted];

    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
