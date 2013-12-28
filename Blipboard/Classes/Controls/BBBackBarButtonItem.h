//
//  BackBarButtonItem.h
//  Blipboard
//
//  Created by Vladimir on 8/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBGenericBarButtonItem.h"
@interface BBBackBarButtonItem : BBGenericBarButtonItem

@property (nonatomic, strong) UIButton* backButton;

+ (id)backBarButtonItem:(NSString *)title target:(id)target action:(SEL)action;

+ (id)addBackBarButtonItem:(NSString *)title toController:(UIViewController *)controller;

@end
