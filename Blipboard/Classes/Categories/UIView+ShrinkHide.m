//
//  UIView+ShrinkAnimation.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/8/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+ShrinkHide.h"

@implementation UIView (ShrinkHide)

-(void) shrinkHideWithDuration:(CGFloat)duration
                         delay:(CGFloat)delay 
                       toPoint:(CGPoint)point
                       toScale:(CGFloat)scale
                  withRotation:(CGFloat)rotation
{
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationCurveEaseIn
                     animations:^(void) {
                         CGPoint origin = self.frame.origin;
                         CGSize  size   = self.frame.size;
                         CGPoint frameCenter = CGPointMake(origin.x + size.width/2,origin.y+size.height/2);
                         CGFloat tX = point.x - frameCenter.x;
                         CGFloat tY = point.y - frameCenter.y;
                         self.transform = CGAffineTransformRotate(CGAffineTransformScale(CGAffineTransformMakeTranslation(tX, tY),  
                                                                                         scale,scale),
                                                                  rotation);
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }]; 
}

-(void) unshrinkHideWithDuration:(CGFloat)duration
                           delay:(CGFloat)delay    
{
    self.hidden = FALSE;
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationCurveEaseOut
                     animations:^(void) {
                         self.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:^(BOOL finished) {
                         self.hidden = NO;
                     }]; 
}

@end
