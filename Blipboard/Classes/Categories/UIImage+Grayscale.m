//
//  UIImage+Grayscale.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/16/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "UIImage+Grayscale.h"

@implementation UIImage (Grayscale)
typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

#define rescaleColor(channel,average,saturation,brightness) \
    (uint8_t)MIN(((float)average + ((float)channel - (float)average) * (float)saturation)*brightness,255)


// don't know why this doesn't work:
- (UIImage *)imageWithSaturation:(CGFloat)saturation brightness:(CGFloat)brightness contrast:(CGFloat)contrast {
    CIImage *ciimage = [[CIImage alloc] initWithCGImage:self.CGImage];
    CIFilter *colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];
    [colorControlsFilter setDefaults];
    [colorControlsFilter setValue:ciimage forKey:@"inputImage"];
    [colorControlsFilter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
    [colorControlsFilter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
    [colorControlsFilter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
    
    CIImage *outputImage = [colorControlsFilter valueForKey:@"outputImage"];
    return [UIImage imageWithCIImage:outputImage];
}

- (UIImage *)saturatedImage:(CGFloat)saturation brightness:(CGFloat)brightness {
    CGSize size = [self size];
    int width = size.width * self.scale;
    int height = size.height * self.scale;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = (rgbaPixel[RED] + rgbaPixel[GREEN] + rgbaPixel[BLUE])/3;
            
//            BBLog(@"%d,%d,%d => %d,%d,%d",
//                  rgbaPixel[RED],
//                  rgbaPixel[GREEN],
//                  rgbaPixel[BLUE],
//                  rescaleColor(rgbaPixel[RED], gray, factor),
//                  rescaleColor(rgbaPixel[GREEN], gray, factor),
//                  rescaleColor(rgbaPixel[BLUE], gray, factor));
            // set the pixels to gray
            rgbaPixel[RED]   = rescaleColor(rgbaPixel[RED], gray, saturation, brightness);
            rgbaPixel[GREEN] = rescaleColor(rgbaPixel[GREEN], gray, saturation, brightness);
            rgbaPixel[BLUE]  = rescaleColor(rgbaPixel[BLUE], gray, saturation, brightness);
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:self.imageOrientation];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}
- (UIImage *)grayscaleImage {
    return [self grayscaleImage:1.0];
}

- (UIImage *)grayscaleImage:(CGFloat)lightness {
    CGSize size = [self size];
    int width = size.width * self.scale;
    int height = size.height * self.scale;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3*lightness * rgbaPixel[RED] + 0.59*lightness * rgbaPixel[GREEN] + 0.11*lightness * rgbaPixel[BLUE];
            gray = MIN(MAX(gray,0),255);
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:self.imageOrientation];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
