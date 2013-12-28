//
//  UIView+SubView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

CGFloat degreesToRadians(CGFloat degrees);
CGFloat radiansToDegrees(CGFloat radians);

@interface UIView (SubView)

- (void)extendBottomWithSubview:(UIView *)subview atIndex:(NSInteger)index;
- (void)extendBottomWithSubview:(UIView *)subview aboveSubview:(UIView *)subview;
- (void)extendBottomWithSubview:(UIView *)subview belowSubview:(UIView *)subview;
- (void)extendBottomWithSubview:(UIView *)subview;

- (void)extendRightWithSubview:(UIView *)subview atIndex:(NSInteger)index;
- (void)extendRightWithSubview:(UIView *)subview aboveSubview:(UIView *)subview;
- (void)extendRightWithSubview:(UIView *)subview belowSubview:(UIView *)subview;
- (void)extendRightWithSubview:(UIView *)subview;

// !am! these are tougher to implement because we need to shift existing subviews over
//- (void)extendLeftWithSubview:(UIView *)subview atIndex:(NSInteger)index;
//- (void)extendLeftWithSubview:(UIView *)subview aboveSubview:(UIView *)subview;
//- (void)extendLeftWithSubview:(UIView *)subview belowSubview:(UIView *)subview;
//- (void)extendLeftWithSubview:(UIView *)subview;
//
//- (void)extendTopWithSubview:(UIView *)subview atIndex:(NSInteger)index;
//- (void)extendTopWithSubview:(UIView *)subview aboveSubview:(UIView *)subview;
//- (void)extendTopWithSubview:(UIView *)subview belowSubview:(UIView *)subview;
//- (void)extendTopWithSubview:(UIView *)subview;
//

@end
