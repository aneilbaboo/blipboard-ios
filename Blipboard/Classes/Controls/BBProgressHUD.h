//
//  BBProgressHUD.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/31/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <MBProgressHUD.h>

@interface BBProgressHUD : MBProgressHUD
@property (nonatomic) BOOL hideOnTap;
@property (nonatomic,strong) void ((^tapAction)());
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;
@end
