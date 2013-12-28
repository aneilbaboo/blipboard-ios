//
//  UITextView+Height.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/18/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Height)
+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;
+ (CGFloat)heightWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width verticalMargins:(CGFloat)verticalMargins;
@end
