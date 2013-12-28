//
//  GenericButton.m
//  Blipboard
//
//  Created by Jason Fischl on 8/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBGenericButton.h"
#import "SystemVersion.h"

@implementation BBGenericButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupStyle];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _setupStyle];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _setupStyle];
    return self;
}

- (void)_setupStyle {
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleToFill;
    UIImage *up = [UIImage imageNamed:@"btn_nav_white.png"] ;
    UIImage *down = [UIImage imageNamed:@"btn_nav_white.png"] ;
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        up = [up stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        down = [down stretchableImageWithLeftCapWidth:3 topCapHeight:3];
    }
    else {
        up = [up resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
        down = [down resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
    }
    [self setBackgroundImage:up forState:UIControlStateNormal];
    [self setBackgroundImage:down forState:UIControlStateHighlighted];
    
    [self setTitleColor:[UIColor bbGray3] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor bbGray3] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor bbPaperWhite] forState:UIControlStateHighlighted];
    [self.titleLabel setFont:[UIFont bbFont:14]];
    [self setShowsTouchWhenHighlighted:YES];

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self _setupStyle];
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
