//
//  FBLoginButton.m
//  Blipboard
//
//  Created by Vladimir Darmin on 7/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "FBLoginButton.h"

@implementation FBLoginButton

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setImage:[UIImage imageNamed:@"btn_facebook.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"btn_facebook.png"] forState:UIControlStateNormal|UIControlStateHighlighted];
    self.showsTouchWhenHighlighted = YES;
    self.backgroundColor = UIColor.clearColor;
    return self;
}

@end
