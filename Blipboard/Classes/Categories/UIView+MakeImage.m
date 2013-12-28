//
//  UIView+AsImage.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/11/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIView+MakeImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView(MakeImage)

- (UIImage *)makeImage {
    CGSize imageSize = self.bounds.size;
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    
    //CGContextTranslateCTM(imageContext, 0.0, imageSize.height);
    //CGContextScaleCTM(imageContext, 1.0, -1.0);
    
    //for (CALayer* layer in self.layer.sublayers) {
    //  [layer renderInContext: imageContext];
    //}
    
    [self.layer renderInContext: imageContext];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end