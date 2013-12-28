//
//  SlideoutViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SlideoutViewController.h"
#import "BBAppDelegate.h"
#import "BBNotificationBadge.h"
#import "SlideoutMenuViewController.h"
#import "Notification.h"
#import "BBLog.h"

@implementation SlideoutViewController {
    BOOL _observersInstalled;
}

+(SlideoutViewController *)sharedController {
    static SlideoutViewController *ctrlr;
    if (!ctrlr) {
        ctrlr = [[SlideoutViewController alloc] initWithNibName:nil bundle:nil];
    }
    return ctrlr;
}

- (SlideoutMenuViewController *)menuViewController {
    return [SlideoutMenuViewController sharedController];
}

- (void)addSlideoutMenu:(UIViewController *)viewController {
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    
    if (![viewController.slidingViewController.underLeftViewController isKindOfClass:[SlideoutMenuViewController class]]) {
        viewController.slidingViewController.underLeftViewController  = [SlideoutMenuViewController sharedController];
    }
}

- (void)addMenuButtonAndBadge:(UIViewController *)viewController {
    // menu button
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *menuImage = [UIImage imageNamed:@"btn_menu.png"];
    [menuButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    menuButton.size = menuImage.size;
    menuButton.showsTouchWhenHighlighted = YES;
    [menuButton addTarget:[SlideoutViewController sharedController]
                   action:@selector(menuButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    viewController.navigationItem.leftBarButtonItem = barButton;
    
    // badge
    BBNotificationBadge *badge = [BBNotificationBadge badge];
    badge.center = CGPointMake(menuButton.width,menuButton.height/4);
    badge.hidden = YES;
    [menuButton addSubview:badge];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    MainBlipsViewController *mainCtrlr = [MainBlipsViewController sharedController];
    BBNavigationController *navCtrlr = [BBNavigationController sharedNavigationViewController:mainCtrlr];
    navCtrlr.splash.hidden = NO;
    self.topViewController = navCtrlr;
    

}

- (void)viewDidAppear:(BOOL)animated {
    BBTrace();
    // in case we had an error while loading notifications initially
    if (!self.notificationStream) {
//        [self refreshNotifications];
    }
}

// !am! these shadow enabling & disabling methods are needed during animation & revealing the slideout,
//      but we need to get rid of the shadow once the view controller is shown, because it otherwise causes
//      ui lag
-(void)_enableTopViewControllerShadow {
    UIViewController *viewController = self.topViewController;
    viewController.view.layer.shadowOpacity = 0.75f;
    viewController.view.layer.shadowRadius = 10.0f;
    viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

-(void)_disableTopViewControllerShadow {
    UIViewController *viewController = self.topViewController;
    viewController.view.layer.shadowOpacity = 0.0f;
    viewController.view.layer.shadowRadius = 0.0f;
    viewController.view.layer.shadowColor = [UIColor clearColor].CGColor;
}

-(void)setTopViewController:(UIViewController *)topViewController {
    [self _disableTopViewControllerShadow];
    [super setTopViewController:topViewController];
    [self _enableTopViewControllerShadow];
}

-(void)resetTopView {
    [super resetTopView];
    [self _disableTopViewControllerShadow];
}

-(void)revealMenu {
    [Flurry logEventWithParams:kFlurrySlideoutOpen,
     @"badge-count",[@(self.notificationStream.newNotificationsCount) stringValue],nil];

    BBRemoteNotificationManager *notificationManager = [BBRemoteNotificationManager sharedManager];
    [notificationManager clearNewNotifications];
    [notificationManager requestRefresh];
    
    self.menuViewController.notificationStream = self.menuViewController.notificationStream; // force table refresh
    
    [self _enableTopViewControllerShadow];
    [self anchorTopViewTo:ECRight];
}

#pragma mark -
#pragma mark Actions

-(void)menuButtonPressed:(id)sender {
    [self revealMenu];
}


@end
