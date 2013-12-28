//
//  BBBadgeView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/27/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBBadgeView.h"

@implementation BBBadgeView
-(id)init {
    self = [super init];
    [self _setDefaults];
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self _setDefaults];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _setDefaults];
    return self;
}

-(void)_setDefaults {
    self.borderWidth = 2.0f;
    self.borderColor = [UIColor whiteColor];
}

// !am! override NIBadgeView so we can customize the border
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // The following constant offsets are chosen to make the badge match the system badge dimensions
    // pixel-for-pixel.
    CGFloat minX = CGRectGetMinX(rect) + 4.f;
    CGFloat maxX = CGRectGetMaxX(rect) - 5.f;
    CGFloat minY = CGRectGetMinY(rect) + 3.5f;
    CGFloat maxY = CGRectGetMaxY(rect) - 6.5f;
    
    CGSize textSize = [self.text sizeWithFont:self.font];
    // Used to suppress warning: Implicit conversion shortens 64-bit value into 32-bit value
    const CGFloat pi = (CGFloat)M_PI;
    const CGFloat kRadius = textSize.height / 2.f;
    
    // Draw the main rounded rectangle
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
    CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
    CGContextAddArc(context, maxX-kRadius, maxY-kRadius, kRadius, 0, pi/2, 0);
    CGContextAddArc(context, minX+kRadius, maxY-kRadius, kRadius, pi/2, pi, 0);
    CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
    CGContextSetShadowWithColor(context, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
    
    // Add the gloss effect
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
    CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
    CGContextAddRect(context, CGRectMake(minX, minY + kRadius,
                                         rect.size.width - kRadius + 1, CGRectGetMidY(rect) - kRadius));
    CGContextClip(context);
    
    size_t num_locations = 2;
    CGFloat locations[] = { 0.0f, 1.f };
    CGFloat components[] = {
        1.f, 1.f, 1.f, 0.8f,
        1.f, 1.f, 1.f, 0.0f };
    
    CGColorSpaceRef cspace;
    CGGradientRef gradient;
    cspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
    
    CGPoint sPoint, ePoint;
    sPoint.x = 0;
    sPoint.y = 4;
    ePoint.x = 0;
    ePoint.y = CGRectGetMidY(rect) - 2;
    CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
    
    CGColorSpaceRelease(cspace);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    
    // Draw the border
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, self.borderWidth);
    // Should this be customizable?
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
    CGContextAddArc(context, maxX-kRadius, maxY-kRadius, kRadius, 0, pi/2, 0);
    CGContextAddArc(context, minX+kRadius, maxY-kRadius, kRadius, pi/2, pi, 0);
    CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    // Draw text
    [self.textColor set];
    
    [self.text drawAtPoint:CGPointMake(floorf((rect.size.width - textSize.width) / 2.f) - 0.f,
                                       floorf((rect.size.height - textSize.height) / 2.f) - 2.f)
                  withFont:self.font];
}

@end
