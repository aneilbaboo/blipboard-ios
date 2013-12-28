//
//  BackBarButtonItem.m
//  Blipboard
//
//  Created by Vladimir on 8/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBBackBarButtonItem.h"

@implementation BBBackBarButtonItem


+ (id)backBarButtonItem:(NSString *)title target:(id)target action:(SEL)action {
    UIImage *backImage = [[UIImage imageNamed:@"btn_nav_white_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 15, 4, 4)];
    return [self barButtonItem:title
                        target:target action:action
                   normalImage:backImage
                 selectedImage:nil
              highlightedImage:nil
                 disabledImage:nil
            titleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];

}

+ (id)addBackBarButtonItem:(NSString *)title toController:(UIViewController *)controller {
    UIViewController *visible = controller.navigationController.visibleViewController;
    
    if ( visible != [visible.navigationController.viewControllers objectAtIndex:0] ) {
        BBBackBarButtonItem *item = [BBBackBarButtonItem backBarButtonItem:title
                                                                    target:controller.navigationController
                                                                    action:@selector(popViewControllerAnimated:)];
        controller.navigationController.visibleViewController.navigationItem.leftBarButtonItem = item;
        return item;
    }
    return nil;
}

+(void)applyStyleTo {
    NSDictionary *barButtonTextAttrs = @{   UITextAttributeFont:[UIFont bbBoldFont:17],
                                            UITextAttributeTextColor:[UIColor bbGray3],
                                            UITextAttributeTextShadowColor:[UIColor clearColor] };

    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTextAttrs forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTextAttrs forState:UIControlStateHighlighted];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn_nav_white.png"]
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn_nav_white.png"]
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, -2) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"btn_nav_white_back.png"]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"btn_nav_white_back.png"]
                                                      forState:UIControlStateNormal | UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];

}


@end
