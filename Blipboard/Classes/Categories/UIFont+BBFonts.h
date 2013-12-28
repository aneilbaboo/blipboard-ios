//
//  UIFont+BBFonts.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/31/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (BBFonts)
+(UIFont *)bbFont:(CGFloat)size;
+(UIFont *)bbBoldFont:(CGFloat)size;
+(UIFont *)bbCondensedFont:(CGFloat)size;
+(UIFont *)bbCondensedBoldFont:(CGFloat)size;
+(UIFont *)bbMessageFont:(CGFloat)size;
+(UIFont *)bbBoldMessageFont:(CGFloat)size;

// named fonts
+(UIFont *)bbBlipMessageFont;
+(UIFont *)bbBlipBoldMessageFont;
+(UIFont *)bbBlipAuthorFont;
+(UIFont *)bbValueCountFont;

// Shadow offsets
+(UIOffset) bbShadowUIOffset;
+(CGSize) bbShadowCGSizeOffset;

@end
