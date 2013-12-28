//
//  SlideoutViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "SlideoutMenuViewController.h"
#import "NotificationStream.h"

@interface SlideoutViewController : ECSlidingViewController
@property (nonatomic,strong) NotificationStream *notificationStream;

+(SlideoutViewController *)sharedController;

-(void)addSlideoutMenu:(UIViewController *)viewController;
-(void)addMenuButtonAndBadge:(UIViewController *)viewController;
-(SlideoutMenuViewController *)menuViewController;
-(void)revealMenu;
@end
