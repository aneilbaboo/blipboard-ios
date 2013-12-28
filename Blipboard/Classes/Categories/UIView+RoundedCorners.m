//
//  UIView+RoundedCorners.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/4/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+RoundedCorners.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RoundedCorners)

-(void)roundCorners:(UIRectCorner)corners xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds 
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(xRadius, yRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.layer.mask = maskLayer;
}

//- (UIViewController *)viewController;
//{
//    id nextResponder = [self nextResponder];
//    if ([nextResponder isKindOfClass:[UIViewController class]]) {
//        return nextResponder;
//    } else {
//        return nil;
//    }
//}
@end
