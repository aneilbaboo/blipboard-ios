//
//  UIFont+BBFonts.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/31/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIFont+BBFonts.h"
#import "UIColor+BBColors.h"

@implementation UIFont (BBFonts)

+(UIFont *)bbFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"GoodMobiPro-Book" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbBoldFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"GoodMobiPro-Bold" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbCondensedFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"GoodMobiPro-CondBook" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbCondensedBoldFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"GoodMobiPro-CondBold" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbMessageFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbBoldMessageFont:(CGFloat)size {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    assert(font);
    return font;
}

+(UIFont *)bbBlipMessageFont {
    return [UIFont bbMessageFont:14];
}

+(UIFont *)bbBlipBoldMessageFont {
    return [UIFont bbBoldMessageFont:14];
}

+(UIFont *)bbBlipAuthorFont {
    return [UIFont bbBoldFont:17];
}

+(UIFont *)bbValueCountFont {
    return [UIFont bbBoldFont:14];
}

#pragma mark -
#pragma mark Font shadows
+(UIOffset) bbShadowUIOffset {
    return UIOffsetMake(0, 1);
}

+(CGSize) bbShadowCGSizeOffset {
    return CGSizeMake(0, 1);
}


@end
