//
//  CALayer+Line.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/2/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Line)
+(instancetype)layerWithLineFrom:(CGPoint)start to:(CGPoint)end color:(CGColorRef)color width:(CGFloat)width join:(NSString *)join dashPattern:(NSArray *)dashPattern;

@end
