//
//  UIView+ShrinkAnimation.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/8/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ShrinkHide)

-(void) shrinkHideWithDuration:(CGFloat)duration
                         delay:(CGFloat)delay 
                       toPoint:(CGPoint)point
                       toScale:(CGFloat)scale
                  withRotation:(CGFloat)rotation;

-(void) unshrinkHideWithDuration:(CGFloat)duration
                           delay:(CGFloat)delay;

@end
