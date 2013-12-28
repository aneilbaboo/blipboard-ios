//
//  UITextView+Height.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/18/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "UITextView+Height.h"

static const CGFloat defaultVerticalMargins = 16.0;

@implementation UITextView (Height)


+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    return [self heightWithText:text font:font width:width verticalMargins:defaultVerticalMargins];
}

+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width verticalMargins:(CGFloat)verticalMargins {
    
    CGSize bounds = CGSizeMake(width - verticalMargins, CGFLOAT_MAX);
    
    CGSize size = [text sizeWithFont:font
                   constrainedToSize:bounds
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + verticalMargins;
}

@end
