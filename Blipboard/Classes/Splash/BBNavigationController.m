//
//  BBNavigationViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/13/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBNavigationController.h"
#import "BaseBlipsViewController.h"
#import "BBLog.h"
@implementation BBNavigationController

+(BBNavigationController *)sharedNavigationViewController:(UIViewController *)controller {
    static BBNavigationController *sharedCtrlr;
    if (!sharedCtrlr) {
        sharedCtrlr = [[BBNavigationController alloc] initWithRootViewController:controller];
    }
    return sharedCtrlr;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *imageName = [[UIScreen mainScreen] bounds].size.height == 568 ? @"splashTransparent-568h.png" : @"splashTransparent.png";
    self.splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    self.splash.hidden = YES;
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    self.splash.ry = appFrame.size.height-self.splash.height; // align splash with the iOS splash screen; offset accounts for status bar
    [self.view insertSubview:self.splash aboveSubview:self.navigationBar];
    self.delegate = self;
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotate
{
    if (self.topViewController.view.superview)
    {
        return [self.topViewController shouldAutorotate];
    }
    else {
        return NO;
    }
}

-(NSUInteger) supportedInterfaceOrientations
{
    if (self.topViewController.view.superview)
    {
        BBLogLevel(4,@"%d",[self.topViewController supportedInterfaceOrientations]);
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    return UIInterfaceOrientationPortrait;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    if (self.topViewController.view.superview)
//    {
//        return [self.topViewController preferredInterfaceOrientationForPresentation];
//    }
//    
//    return UIInterfaceOrientationPortrait;
//}


#pragma mark external methods
-(void) showSplash {
    self.splash.hidden = NO;
    [UIView animateWithDuration:.25 animations:^{
        self.splash.alpha = 1;
    }];
}
-(void) hideSplash {
    [UIView animateWithDuration:2
                     animations:^{
                         self.splash.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.splash.hidden = YES;
                     }];
}

#pragma mark -
#pragma mark BBNavigationControllerEvents implementation

-(void)_sendNavigationControllerWillCover:(UIViewController *)coveredController animated:(BOOL)animated {
    if (coveredController &&
        [coveredController conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [coveredController respondsToSelector:@selector(navigationController:willCoverViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)coveredController navigationController:self willCoverViewController:coveredController animated:animated];
    }
}

-(void)_sendNavigationControllerDidCover:(UIViewController *)coveredController animated:(BOOL)animated {
    if (coveredController &&
        [coveredController conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [coveredController respondsToSelector:@selector(navigationController:didCoverViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)coveredController navigationController:self didCoverViewController:coveredController animated:animated];
    }
}

-(void)_sendNavigationControllerWillUncover:(UIViewController *)uncoveredController animated:(BOOL)animated {
    if (uncoveredController &&
        [uncoveredController conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [uncoveredController respondsToSelector:@selector(navigationController:willUncoverViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)uncoveredController navigationController:self willUncoverViewController:uncoveredController animated:animated];
    }
}

-(void)_sendNavigationControllerDidUncover:(UIViewController *)uncoveredController animated:(BOOL)animated {
    if (uncoveredController &&
        [uncoveredController conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [uncoveredController respondsToSelector:@selector(navigationController:didUncoverViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)uncoveredController navigationController:self didUncoverViewController:uncoveredController animated:animated];
    }
}

-(void)_sendNavigationControllerWillPush:(UIViewController *)pushed animated:(BOOL)animated {
    if (pushed &&
        [pushed conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [pushed respondsToSelector:@selector(navigationController:willPushViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)pushed navigationController:self willPushViewController:pushed animated:animated];
    }
    
}

-(void)_sendNavigationControllerDidPush:(UIViewController *)pushed animated:(BOOL)animated {
    if (pushed &&
        [pushed conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [pushed respondsToSelector:@selector(navigationController:didPushViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)pushed navigationController:self didPushViewController:pushed animated:animated];
    }
    
}

-(void)_sendNavigationControllerWillPop:(UIViewController *)popped animated:(BOOL)animated {
    if (popped &&
        [popped conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [popped respondsToSelector:@selector(navigationController:willPopViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)popped navigationController:self willPopViewController:popped animated:animated];
    }
    
}

-(void)_sendNavigationControllerDidPop:(UIViewController *)popped animated:(BOOL)animated {
    if (popped &&
        [popped conformsToProtocol:@protocol(BBNavigationControllerEvents)] &&
        [popped respondsToSelector:@selector(navigationController:didPopViewController:animated:)]) {
        [(id<BBNavigationControllerEvents>)popped navigationController:self didPopViewController:popped animated:animated];
    }
    
}
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *coveredController = self.topViewController;
    UIViewController *pushedController = viewController;
    
    [self _sendNavigationControllerWillPush:pushedController animated:animated];
    [self _sendNavigationControllerWillCover:coveredController animated:animated];
    [super pushViewController:viewController animated:animated];
    
    [self _sendNavigationControllerDidPush:pushedController animated:animated];
    [self _sendNavigationControllerDidCover:coveredController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *uncoveredController = self.viewControllers.count > 1 ? [self.viewControllers objectAtIndex:self.viewControllers.count-2] : nil;
    UIViewController *poppedController = self.topViewController;
    
    [self _sendNavigationControllerWillPop:poppedController animated:animated];
    [self _sendNavigationControllerWillUncover:uncoveredController animated:animated];
    UIViewController *returnController = [super popViewControllerAnimated:animated];
   
    [self _sendNavigationControllerDidPop:poppedController animated:animated];
    [self _sendNavigationControllerDidUncover:uncoveredController animated:animated];
    
    assert(returnController==poppedController);
    return returnController;
}

-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    UIViewController *rootController =[self.viewControllers objectAtIndex:0];

    return [self popToViewController:rootController animated:animated];
}

-(NSArray *)popToViewController:(UIViewController *)uncoveredController animated:(BOOL)animated {
    for (UIViewController *viewController in self.viewControllers.reverseObjectEnumerator) {
        if (viewController==uncoveredController) {
            break;
        }
        else {
            [self _sendNavigationControllerWillPop:viewController animated:animated];
        }
    }
    [self _sendNavigationControllerWillUncover:uncoveredController animated:animated];
    
    NSArray *result = [super popToRootViewControllerAnimated:animated];
    
    for (UIViewController *viewController in self.viewControllers.reverseObjectEnumerator) {
        if (viewController==uncoveredController) {
            break;
        }
        else {
            [self _sendNavigationControllerDidPop:viewController animated:animated];
        }
    }
    [self _sendNavigationControllerDidUncover:uncoveredController animated:animated];
    
    return result;
}

@end
