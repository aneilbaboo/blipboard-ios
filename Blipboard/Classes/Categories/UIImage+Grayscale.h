//
//  UIImage+Grayscale.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/16/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Grayscale)
// lightness controls how white the resulting grayscale image is:
//   1=default; >1 => white; <1 => black; <0 = undefiend
- (UIImage *) grayscaleImage:(CGFloat)lightness;
- (UIImage *) grayscaleImage;

// 0<factor<1 = desaturate
// factor>1 = saturate
- (UIImage *) saturatedImage:(CGFloat)factor brightness:(CGFloat)brightness;

// !am! doesn't work; don't know why.
//- (UIImage *) imageWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness contrast:(CGFloat)contrast;
@end
