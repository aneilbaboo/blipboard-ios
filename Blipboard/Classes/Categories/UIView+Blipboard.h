//
//  UIView+Blipboard.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/1/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+Blipboard.h"
#import "UIView+ExtendSubview.h"
#import "UIView+MakeImage.h"
#import "UIView+position.h"
#import "UIView+RoundedCorners.h"
#import "UIView+ShrinkHide.h"
#import "UIView+Transform.h"

typedef enum {
    BlipboardShadowOptionNone = 0b0,
    BlipboardShadowOptionLeft = 0b0001,
    BlipboardShadowOptionRight = 0b0010,
    BlipboardShadowOptionUp = 0b0100,
    BlipboardShadowOptionDown = 0b1000
} BlipboardShadowOption;

@interface UIView (Blipboard)
-(void)bbSetShadow:(BlipboardShadowOption)option;
-(void)bbSetShadow:(BlipboardShadowOption)option size:(CGFloat)size radius:(CGFloat)radius opacity:(CGFloat)opacity;
-(void)bbStyleAsLightBar;
-(void)bbStyleAsDarkBar;
-(void)bbStyleAsBlip;
@end
