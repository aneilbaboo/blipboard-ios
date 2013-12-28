//
//  BBGenericBarButtonItem.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBGenericBarButtonItem.h"

@implementation BBGenericBarButtonItem

@dynamic font;
@dynamic selected;
+ (id)barButtonItem:(NSString *)title target:(id)target action:(SEL)selector {
    UIImage *image = [[UIImage imageNamed:@"btn_nav_white.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    UIImage *imageSel = [UIImage imageNamed:@"btn_follow_follow.png"];// resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    return [self barButtonItem:title target:target action:selector normalImage:image selectedImage:imageSel highlightedImage:image disabledImage:nil titleEdgeInsets:UIEdgeInsetsZero];
}

+ (id)barButtonItem:(NSString *)title target:(id)target action:(SEL)selector normalImage:(UIImage *)normal selectedImage:(UIImage *)selectedImage highlightedImage:(UIImage *)highlighted disabledImage:(UIImage *)disabled titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    UIButton *btn = [self _makeButtonWithNormalImage:normal selectedImage:selectedImage highlightedImage:highlighted];
    CGSize textSize = [title sizeWithFont:[self _buttonFont]];
    CGRect frame = CGRectMake(0,0,textSize.width+25,30);
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateDisabled];
    [btn setTitle:title forState:UIControlStateSelected];
    btn.titleEdgeInsets = titleEdgeInsets;
    
    btn.frame = frame;

    
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    BBGenericBarButtonItem *bi = [[self alloc] initWithCustomView:btn];
    
    return bi;
}

+(UIFont *)_buttonFont {
    return [UIFont bbBoldFont:17];
}

+(UIButton *)_makeButtonWithNormalImage:(UIImage *)normal selectedImage:(UIImage *)selectedImage highlightedImage:(UIImage *)highlighted {
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor clearColor];

    
    [btn setReversesTitleShadowWhenHighlighted:YES];
    [btn setAdjustsImageWhenHighlighted:YES];
    [btn setBackgroundImage:normal forState:UIControlStateNormal];
    [btn setBackgroundImage:highlighted forState:UIControlStateHighlighted];
    [btn setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [btn setBackgroundImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        [btn setBackgroundImage:selectedImage forState:UIControlStateSelected | UIControlStateDisabled];
    
    UIFont *font = [self _buttonFont];
    btn.titleLabel.font = font;
    [btn setTitleColor:[UIColor bbGray3] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor bbGray3] forState:UIControlStateNormal|UIControlStateHighlighted];
    [btn setTitleColor:[UIColor bbGray1] forState:UIControlStateDisabled];
    [btn setTitleColor:[UIColor bbWhite] forState:UIControlStateSelected];
    [btn setShowsTouchWhenHighlighted:YES];
    
    return btn;
}

-(UIButton *)button {
    return (UIButton *)self.customView;
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.button setEnabled:enabled];
}

-(void)setSelected:(BOOL)selected {
    [self.button setSelected:selected];
}

-(BOOL)selected {
    return self.button.selected;
}

-(void)setTitle:(NSString *)title {
    [(UIButton *)self.customView setTitle:title forState:UIControlStateNormal];
    [(UIButton *)self.customView setTitle:title forState:UIControlStateNormal | UIControlStateHighlighted];
}

-(UIImage *)backgroundImageForState:(UIControlState)state {
    return [self.button backgroundImageForState:state];
}

-(void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state {
    [self.button setBackgroundImage:backgroundImage forState:state];
}

-(NSString *)titleForState:(UIControlState)state {
    return [self.button titleForState:state];
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.button setTitle:title forState:state];
}

-(UIColor *)titleColorForState:(UIControlState)state {
    return [self.button titleColorForState:state];
}

-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self.button setTitleColor:color forState:state];
}

-(UIFont *)font {
    return self.button.titleLabel.font;
}

-(void)setFont:(UIFont *)font {
    [self.button.titleLabel setFont:font];
}


@end
