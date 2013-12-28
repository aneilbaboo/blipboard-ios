//
//  ErrorViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/16/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerModelError.h"

typedef void (^ErrorViewControllerRetryAction)();

@interface ErrorViewController : UIViewController {
    void (^_retryBlock)();
    void (^_viewDidLoadBlock)();
}

@property (nonatomic,weak) IBOutlet UIButton *retryButton;
@property (nonatomic,weak) IBOutlet UILabel *errorTitle;
@property (nonatomic,weak) IBOutlet UILabel *errorMessage;

@property (nonatomic) BOOL hideBackButton;

// shows the retry button
+(id)errorViewControllerWithTitle:(NSString *)title andRetry:(ErrorViewControllerRetryAction)action;

// no retry button - show a message instead
+(id)errorViewControllerWithTitle:(NSString *)title andMessage:(NSString *)message;

// sets up the error dialog using a ServerModelError:
+(id)errorViewControllerWithError:(ServerModelError *)error;
                       
-(void)dismiss;

-(IBAction)onRetryPressed:(id)sender;
@end
