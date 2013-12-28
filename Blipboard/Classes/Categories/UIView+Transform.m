//
//  UIView+Transform.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+Transform.h"

@implementation UIView (Transform)

- (void) setTransformYTranslation:(CGFloat)yTranslation {
    CGAffineTransform zeroYTranslation = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(0, -self.transform.ty));
    self.transform = CGAffineTransformConcat(zeroYTranslation, CGAffineTransformMakeTranslation(0, yTranslation));
}

- (void) setTransformXTranslation:(CGFloat)xTranslation {
    CGAffineTransform zeroXTranslation = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(self.transform.ty, 0));
    
    self.transform = CGAffineTransformConcat(zeroXTranslation, CGAffineTransformMakeTranslation(xTranslation,0));
}

- (void) setTransformRotation:(CGFloat)radians {
    self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(radians));
}

- (void) setTransformScale:(CGFloat)scale {
    self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(scale, scale));
}

@end
