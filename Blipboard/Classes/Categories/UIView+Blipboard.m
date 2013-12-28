//
//  UIView+Blipboard.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/1/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+Blipboard.h"
#import "UIColor+BBColors.h"
#import "UIFont+BBFonts.h"

@implementation UIView (Blipboard)

-(void)bbSetShadow:(BlipboardShadowOption)option {
    [self bbSetShadow:option size:3 radius:2 opacity:.5];
}

-(void)bbSetShadow:(BlipboardShadowOption)option size:(CGFloat)size radius:(CGFloat)radius opacity:(CGFloat)opacity {
    self.layer.masksToBounds = NO;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;

    if (option == BlipboardShadowOptionNone) {
        self.layer.shadowColor = [UIColor clearColor].CGColor;
    }
    else {
        self.layer.shadowColor = UIColor.blackColor.CGColor;
    }
    
    CGSize offset;
    if (option & BlipboardShadowOptionDown) {
        offset.height = size;
    }
    else if (option & BlipboardShadowOptionUp) {
        offset.height = -3;
    }
    
    if (option & BlipboardShadowOptionRight) {
        offset.width = 3;
    }
    else if (option & BlipboardShadowOptionLeft) {
        offset.width = -3;
    }
    self.layer.shadowOffset = offset;
}

-(void)bbStyleAsLightBar {
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbWarmGray]];
    }
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbWarmGray]];
    }
    self.backgroundColor = [UIColor bbWhite];
}

-(void)bbStyleAsDarkBar {
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbPaperWhite]];
    }
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbPaperWhite]];
    }
    self.backgroundColor = [UIColor bbWarmGray];
    
}

-(void)bbStyleAsBlip {
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbWarmGray]];
    }
    if ([self respondsToSelector:@selector(setTextColor:)]) {
        [self performSelector:@selector(setTextColor:) withObject:[UIColor bbWarmGray]];
    }
    self.backgroundColor = [UIColor bbPaperWhite];
}
@end
