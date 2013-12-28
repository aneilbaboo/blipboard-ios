//
//  UIView+SubView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+ExtendSubview.h"
#import "BBLog.h"
CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * M_PI/180;
}

CGFloat radiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
}

@implementation UIView (SubView)

#pragma mark extendBottomWithSubview
-(void)_updateFramesForSubviewAtBottom:(UIView *)subview {
    CGFloat subViewNewY = self.frame.size.height;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.frame.size.width, self.frame.size.height + subview.frame.size.height);
    subview.frame = CGRectMake(subview.frame.origin.x, subViewNewY,
                               subview.frame.size.width, subview.frame.size.height);

}

-(void)extendBottomWithSubview:(UIView *)subview {
    [self _updateFramesForSubviewAtBottom:subview];
    [self addSubview:subview];
}

-(void)extendBottomWithSubview:(UIView *)subview1 aboveSubview:(UIView *)subview2 {
    [self _updateFramesForSubviewAtBottom:subview1];
    [self insertSubview:subview1 aboveSubview:subview2];
}

-(void)extendBottomWithSubview:(UIView *)subview1 belowSubview:(UIView *)subview2 {
    [self _updateFramesForSubviewAtBottom:subview1];
    [self insertSubview:subview1 belowSubview:subview2];
}

-(void)extendBottomWithSubview:(UIView *)subview atIndex:(NSInteger)index {
    [self _updateFramesForSubviewAtBottom:subview];
    [self insertSubview:subview atIndex:index];
}

#pragma mark extendRightWithSubview
-(void)_updateFramesForSubviewAtRight:(UIView *)subview {
    subview.frame = CGRectMake(self.frame.size.width, subview.frame.origin.y,
                               subview.frame.size.width, subview.frame.size.height);
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.frame.size.width + subview.frame.size.width, self.frame.size.height);
}

-(void)extendRightWithSubview:(UIView *)subview {
    [self _updateFramesForSubviewAtRight:subview];
    [self addSubview:subview];
}

-(void)extendRightWithSubview:(UIView *)subview1 aboveSubview:(UIView *)subview2 {
    [self _updateFramesForSubviewAtRight:subview1];
    [self insertSubview:subview1 aboveSubview:subview2];
}

-(void)extendRightWithSubview:(UIView *)subview1 belowSubview:(UIView *)subview2 {
    [self _updateFramesForSubviewAtRight:subview1];
    [self insertSubview:subview1 belowSubview:subview2];
}

-(void)extendRightWithSubview:(UIView *)subview atIndex:(NSInteger)index {
    [self _updateFramesForSubviewAtRight:subview];
    [self insertSubview:subview atIndex:index];
}


@end
