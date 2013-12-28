//
//  UIImage+Combine.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/14/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIImage+Overlay.h"

@implementation UIImage (Overlay)


- (UIImage*)resize:(CGRect)selfRect andOverlayWith:(UIImage*)overlay at:(CGRect)overlayRect
{
    // output image will be in the resolution of the highest res image
    CGFloat outputScale = MAX(self.scale,overlay.scale);
    
    // output image expressed in terms of the current image coordinates:
    CGRect outputRect = CGRectUnion(selfRect, overlayRect);
    
    // input images expressed in terms of output coordinates (output origin => 0,0)
    CGRect selfOutputRect = CGRectOffset(selfRect, -outputRect.origin.x, -outputRect.origin.y);
    CGRect overlayOutputRect = CGRectOffset(overlayRect, -outputRect.origin.x, -outputRect.origin.y);
    
    UIGraphicsBeginImageContextWithOptions(outputRect.size, NO, outputScale);
    
    [self drawInRect:selfOutputRect];
    [overlay drawInRect:overlayOutputRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




- (UIImage*)overlayWith:(UIImage*)overlay at:(CGPoint)point
{
    return [self resize:CGRectMake(0, 0, self.size.width, self.size.height)
         andOverlayWith:overlay
                     at:CGRectMake(point.x, point.y, overlay.size.width, overlay.size.height)];
}


- (UIImage *)addText:(NSString *)text withFont:(UIFont *)font andColor:(UIColor *)color atPoint:(CGPoint)point {
    assert(false); // !am! don't use: this routine produces images with bad anti-aliasing.

    UIGraphicsBeginImageContextWithOptions(self.size,NO,self.scale);
    [self drawAtPoint:CGPointZero];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    [text drawAtPoint: point withFont:font];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
//- (UIImage*)addText:(NSString *)text withFont:(UIFont *)font andColor:(UIColor *)color withTransform:(CGAffineTransform)transform atPoint:(CGPoint)point {
//    NSInteger width = self.size.width;
//    NSInteger height = self.size.height;
//    size_t bitsPerComponent = 8;
//    size_t bytesPerRow = 4*width;
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent,bytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1);
//    
//    char* cString	= (char *)[text cStringUsingEncoding:NSASCIIStringEncoding];
//    
//    CGContextSelectFont(context,
//                        [font.familyName cStringUsingEncoding:NSASCIIStringEncoding],
//                        font.pointSize,
//                        kCGEncodingMacRoman);
//    CGContextSetTextDrawingMode(context, kCGTextFill);
//
//    const CGFloat *colors = CGColorGetComponents(color.CGColor);
//    CGContextSetRGBFillColor(context, colors[0], colors[1], colors[2], 1);
//    
//    CGContextSetTextMatrix(context, transform);
//    
//    CGContextShowTextAtPoint(context, point.x, point.y, cString, strlen(cString));
//    
//    
//    CGImageRef maskedImage = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    
//    return [UIImage imageWithCGImage:maskedImage];
//}
@end
