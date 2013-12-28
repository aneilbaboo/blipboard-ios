//
//  BBProgressHUD.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/31/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBProgressHUD.h"

@implementation BBProgressHUD {
    UITapGestureRecognizer *_tapGesture;
}

// !am! Copied this code from the latest master which addresses the problem
//      that we couldn't customize the view --- tag 0.6 uses:
//      [MBProgressHUD alloc] instead of [self alloc] as shown here:
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    BBProgressHUD *hud = [[self alloc] initWithView:view];
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.labelFont = [UIFont bbBoldFont:18];
        self.detailsLabelFont = [UIFont bbMessageFont:12];
        self.color = [UIColor bbWarmGray];
        self.dimBackground = YES;
        self.opaque = NO;
        self.opacity = .5;
        self.userInteractionEnabled = YES;
        // !am! - bug in .graceTime: DO NOT USE
        //        self.graceTime = .25;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

-(void)viewTapped:(id)gesture {
    if (self.hideOnTap) {
        [self hide:YES];
    }
    if (self.tapAction) {
        self.tapAction();
    }
}
@end
