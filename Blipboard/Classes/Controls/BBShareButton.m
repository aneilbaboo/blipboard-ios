//
//  BBShareButton.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBShareButton.h"

@implementation BBShareButton

-(id)init {
    self = [super init];
    [self setupStyle];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setupStyle];
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupStyle];
    return self;
}

-(void)setupStyle {
    [self.titleLabel setFont:[UIFont bbValueCountFont]];
    [self setImage:[UIImage imageNamed:@"icn_share.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"icn_share.png"] forState:UIControlStateNormal|UIControlStateHighlighted];
    [self setImage:[UIImage imageNamed:@"icn_share.png"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"icn_share.png"] forState:UIControlStateSelected|UIControlStateHighlighted];
}
@end
