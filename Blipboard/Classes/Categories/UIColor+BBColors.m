//
//  UIColor+BBColors.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "UIColor+BBColors.h"

@implementation UIColor (BBColors)

#pragma mark Basic Colors


+(UIColor *)bbWarmGray {
    return [UIColor colorWithRGBHex:0x574A45 alpha:1];
}

+(UIColor *)bbFadedWarmGray {
    return [UIColor colorWithRGBHex:0xDEDAD8 alpha:1];
}

+(UIColor *)bbLightWarmGray {
    return [UIColor colorWithRGBHex:0x83746F alpha:1];
}

+(UIColor *)bbPaperWhite {
    return [UIColor colorWithRGBHex:0xF3F3F3 alpha:1];
}

+(UIColor *)bbDarkBlue {
    return [UIColor colorWithRGBHex:0x212E49 alpha:1];
}

+(UIColor *) bbWhite {
    return [UIColor colorWithRGBHex:0xF9F9F9 alpha:1];
}

+(UIColor *) bbOrange {
    return [UIColor colorWithRGBHex:0xE35F1C alpha:1];  // !am! sampled from comp: TODO get the real color from Kumiko
}

+(UIColor *) bbGray0 {
    return [UIColor colorWithRGBHex:0xE3E3E3 alpha:1];
}
+(UIColor *) bbGray1 {
    return [UIColor colorWithRGBHex:0xDEDEDE alpha:1];
}

+(UIColor *) bbGray2 {
    return [UIColor colorWithRGBHex:0xC0C0C0 alpha:1];
}

+(UIColor *) bbGray3 {
    return [UIColor colorWithRGBHex:0xACACAC alpha:1];
}

+(UIColor *) bbGray4 {
    return [UIColor colorWithRGBHex:0x909090 alpha:1];
}


+(UIColor *) bbGray5 {
    return [UIColor colorWithRGBHex:0x636363 alpha:1];
}

+(UIColor *)bbDarkOrange {
    return [UIColor colorWithRGBHex:0xC36315 alpha:1];
}

+(UIColor *)bbHeaderPattern {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_chDetail_header.png"]];
}

+(UIColor *)bbGridPattern {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_gridPattern_1.png"]];
}

// new aliases

+(UIColor *) bbBlipFontColor {
    return [UIColor bbWarmGray];
}

+(UIColor *) bbBlipBackgroundColor {
    return [UIColor bbPaperWhite];
}


#pragma mark Aliases
+(UIColor *)bbNotificationBarColor {
    return [[UIColor bbDarkOrange] colorWithAlphaComponent:.8];
}

#pragma mark -
#pragma mark Slideout Colors
+(UIColor *)bbSlideoutMenuUnselectedColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_Menu.png"]];
}

+(UIColor *)bbSlideoutMenuSelectedColor {
    // !am! why @2x?  Dirty hack because the provided asset is too short for the SlideoutMenuUserCell
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_orange@2x.png"]];
}

+(UIColor *)bbSlideoutMenuUnselectedTextColor {
    return [UIColor colorWithRGBHex:0xDAD9D9 alpha:1];
}

+(UIColor *)bbSlideoutMenuSelectedTextColor {
    return [UIColor colorWithRGBHex:0xF6E1D8 alpha:1];
}

+(UIColor *)bbSlideoutNotificationsTableBackground {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_menu_notification.png"]];
}

+(UIColor *)bbSlideoutNotificationsHeaderText {
    return [UIColor colorWithRGBHex:0xB6ADAD alpha:1];
}

+(UIColor *)bbSlideoutNotificationTitleColor {
    return [UIColor colorWithRGBHex:0xFFFFFF alpha:1];
}

+(UIColor *)bbSlideoutNotificationSubtitleColor {
    return [UIColor colorWithRGBHex:0xBCBCBC alpha:1];
}

+(UIColor *)bbSlideoutNotificationBackground {
    return [UIColor colorWithRGBHex:0x403D3B alpha:1];
}

+(UIColor *)bbSlideoutNotificationSelectedBackground {
    return [UIColor colorWithRGBHex:0x67625F alpha:1];
}

+(UIColor *)bbSlideoutNotificationPictureBackground {
    return [UIColor colorWithRGBHex:0xD6D2CF alpha:1];
}




#pragma mark Hex Color constructor
+(UIColor *)colorWithRGBHex:(NSUInteger)rgbHex alpha:(CGFloat)alpha {
    CGFloat blue = rgbHex & 0xFF;
    CGFloat green = (rgbHex >> 8) & 0xFF;
    CGFloat red = (rgbHex >> 16) &0xFF;
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}
@end
