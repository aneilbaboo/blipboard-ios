//
//  LoginViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/26/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

// Delegate
@protocol LoginViewControllerDelegate <NSObject>
-(void)facebookLogin:(LoginViewController *)loginViewController;
@end


// ViewController
@interface LoginViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic,weak) id<LoginViewControllerDelegate> delegate;

@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIPageControl *pageControl;

// pages on the gallery view
@property (nonatomic,strong) IBOutlet UIView *loginView;
@property (nonatomic,strong) IBOutlet UIImageView *gallery_page1;
@property (nonatomic,strong) IBOutlet UIImageView *gallery_page2;

@property (nonatomic) BOOL haveSeenGallery;

+(instancetype)loginViewController;
+(instancetype)loginViewController:(NSString *)loginPageText;
@end
