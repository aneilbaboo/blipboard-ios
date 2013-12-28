//
//  BroadcastSharingViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BroadcastDelegate.h"
#import "SHKSharerDelegate.h"

@interface BroadcastSharingViewController : UIViewController 

@property (nonatomic,strong) Blip *blip;
@property (nonatomic,weak) id<BroadcastFlowDelegate> delegate;

@property (nonatomic,weak) IBOutlet UIView *sharingButtonsPanel;
@property (nonatomic,weak) IBOutlet UILabel *editFirstLabel;
@property (nonatomic,weak) IBOutlet UISwitch *editFirstSwitch;
@property (nonatomic,strong) UIBarButtonItem *doneButton;

+(instancetype)viewControllerWithBlip:(Blip *)blip andDelegate:(id<BroadcastFlowDelegate>)delegate;

@end
