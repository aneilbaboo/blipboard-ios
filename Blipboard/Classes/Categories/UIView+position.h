//
//  UIView+position.h
//
//  Apache license
//
//  Created by Tyler Neylon on 3/19/10 (http://bynomial.com/blog/?p=24)
//  Copyleft 2010 Bynomial.
// These free-to-use (Apache 2 license) files are available directly from the links below, or as part of the moriarty library.


#import <Foundation/Foundation.h>

@interface UIView (position)

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@property (nonatomic) CGFloat rx;
@property (nonatomic) CGFloat ry;

// Setting these modifies the origin but not the size.
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Methods for centering.
- (void)addCenteredSubview:(UIView *)subview;
- (void)moveToCenterOfSuperview;
- (void)centerVerticallyInSuperview;
- (void)centerHorizontallyInSuperview;

// !am! Jason's moveUp method from UIView+BlipboardExtensions
- (void) moveUp:(CGFloat)yOffset;
@end
