//
//  CountButton.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBCountButton : UIButton
@property (nonatomic)        NSInteger count;
@property (nonatomic,strong) UIColor *countColor;
-(void)setupStyle;
@end
