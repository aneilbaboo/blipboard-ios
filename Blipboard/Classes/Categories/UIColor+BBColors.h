//
//  UIColor+BBColors.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BBColors)

// New Palette:
+(UIColor *) bbWarmGray;
+(UIColor *) bbFadedWarmGray;
+(UIColor *) bbLightWarmGray;
+(UIColor *) bbWhite;
+(UIColor *) bbPaperWhite;
+(UIColor *) bbOrange;
+(UIColor *) bbDarkOrange;
+(UIColor *) bbHeaderPattern;
+(UIColor *) bbGridPattern;
+(UIColor *) bbGray0;
+(UIColor *) bbGray1;
+(UIColor *) bbGray2;
+(UIColor *) bbGray3;
+(UIColor *) bbGray4;
+(UIColor *) bbGray5;
+(UIColor *) bbDarkBlue;

// aliases
+(UIColor *) bbBlipFontColor;
+(UIColor *) bbBlipBackgroundColor;
+(UIColor *) bbNotificationBarColor;

// slideout colors
+(UIColor *)bbSlideoutMenuUnselectedTextColor;
+(UIColor *)bbSlideoutMenuSelectedTextColor;
+(UIColor *)bbSlideoutMenuSelectedColor;
+(UIColor *)bbSlideoutMenuUnselectedColor;

+(UIColor *)bbSlideoutNotificationsTableBackground;
+(UIColor *)bbSlideoutNotificationsHeaderText;
+(UIColor *)bbSlideoutNotificationTitleColor;
+(UIColor *)bbSlideoutNotificationSubtitleColor;
+(UIColor *)bbSlideoutNotificationBackground;
+(UIColor *)bbSlideoutNotificationSelectedBackground;
+(UIColor *)bbSlideoutNotificationPictureBackground;

+(UIColor *)colorWithRGBHex:(NSUInteger)rgbHex alpha:(CGFloat)alpha;
@end
