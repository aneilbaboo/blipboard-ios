//
//  UIImage+Overlay.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/14/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Overlay)
- (UIImage*)resize:(CGRect)selfRect andOverlayWith:(UIImage*)overlay at:(CGRect)overlayRect;
- (UIImage*)overlayWith:(UIImage*)overlayImage at:(CGPoint)point;
- (UIImage *)addText:(NSString *)text withFont:(UIFont *)font andColor:(UIColor *)color atPoint:(CGPoint)point;
@end
