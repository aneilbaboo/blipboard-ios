//
//  BBNavigationViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/13/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBNavigationController;

// UIViewControllers being popped, pushed, covered or uncovered during pushViewController or popViewController will receive these calls:
@protocol BBNavigationControllerEvents <NSObject>

@optional
- (void)navigationController:(UINavigationController *)navigationController willPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didPushViewController:(UIViewController *)viewController animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController willCoverViewController:(UIViewController *)controller animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController didCoverViewController:(UIViewController *)controller animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController willUncoverViewController:(UIViewController *)controller animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController didUncoverViewController:(UIViewController *)controller animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController willPopViewController:(UIViewController *)controller animated:(BOOL)animated;
-(void)navigationController:(UINavigationController *)navigationController didPopViewController:(UIViewController *)controller animated:(BOOL)animated;
@end

@interface BBNavigationController : UINavigationController <UINavigationControllerDelegate>
@property (nonatomic,strong) UIImageView *splash;

+(BBNavigationController *)sharedNavigationViewController:(UIViewController *)controller;

-(void) hideSplash;
-(void) showSplash;
@end
