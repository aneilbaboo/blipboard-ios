//
//  BBCheckButton.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/2/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBCheckButton : UIButton
@property (nonatomic,weak) UIImageView *checkView;
@property (nonatomic) BOOL checked;

+(instancetype)button;
-(void)setChecked:(BOOL)checked animated:(BOOL)animated;
@end
