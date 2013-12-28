//
//  UIView+Transform.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Transform)

- (void) setTransformYTranslation:(CGFloat)yTranslation;

- (void) setTransformXTranslation:(CGFloat)xTranslation ;

- (void) setTransformRotation:(CGFloat)radians ;

- (void) setTransformScale:(CGFloat)scale ;

@end
