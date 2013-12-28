//
//  CountButton.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBCountButton.h"

@implementation BBCountButton {
    NSInteger _count;
}
@dynamic count;
@dynamic countColor;

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
// !am! subclasses that override the style should call [super _setupStyle]
- (void)setupStyle {
    [self.titleLabel setFont:[UIFont bbValueCountFont]];
    self.countColor = [UIColor bbPaperWhite];
}


-(UIColor *)countColor {
    return [self titleColorForState:UIControlStateNormal];
}

-(void)setCountColor:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateSelected];
    [self setTitleColor:color forState:UIControlStateSelected|UIControlStateHighlighted];
}


-(void) setCount:(NSInteger)count {
    _count = count;
    NSString *countStr = [NSString stringWithFormat:@"  %d",count];
    [self setTitle:countStr forState:UIControlStateNormal];
    [self setTitle:countStr forState:UIControlStateHighlighted];
    [self setTitle:countStr forState:UIControlStateSelected];
    [self setTitle:countStr forState:UIControlStateSelected|UIControlStateHighlighted];
}

-(NSInteger)count {
    return _count;
}

@end
