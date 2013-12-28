//
//  CALayer+Line.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/2/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "CALayer+Line.h"

@implementation CALayer (Line)
+(instancetype)layerWithLineFrom:(CGPoint)start to:(CGPoint)end color:(CGColorRef)color width:(CGFloat)width join:(NSString *)join dashPattern:(NSArray *)dashPattern {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:CGRectMake(0, 0, MAX(start.x,end.x), MAX(start.y,end.y))];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color];
    [shapeLayer setLineWidth:width];
    [shapeLayer setLineJoin:join];
    [shapeLayer setLineDashPattern:dashPattern];
    [shapeLayer setAnchorPoint:CGPointMake(0,0)];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, start.x, start.y);
    CGPathAddLineToPoint(path, NULL, end.x,end.y);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    return shapeLayer;
}
@end
