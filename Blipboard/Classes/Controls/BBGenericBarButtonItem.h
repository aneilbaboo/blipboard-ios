//
//  BBGenericBarButtonItem.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBGenericBarButtonItem : UIBarButtonItem
@property (nonatomic,strong) UIFont *font;
@property (nonatomic) BOOL selected;

+ (id)barButtonItem:(NSString *)title target:(id)target action:(SEL)selector;

// for further customizing the generic button
+ (id)barButtonItem:(NSString *)title target:(id)target action:(SEL)selector normalImage:(UIImage *)normal selectedImage:(UIImage *)selectedImage highlightedImage:(UIImage *)highlighted disabledImage:(UIImage *)disabled titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

-(UIImage *)backgroundImageForState:(UIControlState)state;
-(void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;

-(NSString *)titleForState:(UIControlState)state;
-(void)setTitle:(NSString *)title forState:(UIControlState)state;

-(UIColor *)titleColorForState:(UIControlState)state;
-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

-(void)setSelected:(BOOL)selected;
-(BOOL)selected;
@end
