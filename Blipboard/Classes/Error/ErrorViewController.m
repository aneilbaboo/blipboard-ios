//
//  ErrorViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/16/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBAppDelegate.h"
#import "ErrorViewController.h"
#import "Flurry+Blipboard.h"

@implementation ErrorViewController

+(id)errorViewControllerWithTitle:(NSString *)title andMessage:(NSString *)message {
    BBLog(@"title:%@, message:%@",title,message);
    ErrorViewController *evc = [[ErrorViewController alloc] initWithNibName:nil bundle:nil];
    BBAppDelegate.sharedDelegate.currentErrorViewController = evc;
    // !am! ugh ObjC is so gross.  the errorMessage and errorTitle don't exist until
    //      viewDidLoad is called by the system.  
    __block NSString *blockTitle = title;
    __block NSString *blockMessage = message;
    __unsafe_unretained ErrorViewController *weakEVC = evc;
    evc->_viewDidLoadBlock = ^{
        weakEVC.retryButton.hidden = YES;
        weakEVC.errorMessage.text = blockMessage;
        weakEVC.errorTitle.text = blockTitle;
    };
    return evc;
}

+(id)errorViewControllerWithTitle:(NSString *)title andRetry:(ErrorViewControllerRetryAction)action {
    ErrorViewController *evc = [[ErrorViewController alloc] initWithNibName:nil bundle:nil];
    evc->_retryBlock = action;
    __unsafe_unretained ErrorViewController *weakEVC = evc;
    __block NSString *blockTitle = title;
    evc->_viewDidLoadBlock = ^{
        weakEVC.errorTitle.text = blockTitle;
        weakEVC.errorMessage.hidden=YES;
    };
    return evc;
}

+(id)errorViewControllerWithError:(ServerModelError *)error {
    [Flurry logEvent:kFlurryError
               withParameters:[Flurry paramsWithError:error,
                               @"statusCode",[NSString stringWithFormat:@"%d",error.statusCode],
                               nil]];
    __block ServerModelError *blockError = error;
    void (^retryBlock)();
    
    if (error.statusCode>=500) {
        retryBlock = ^{
            [blockError retry];
        };
    }
    
    if ([BBAppDelegate.sharedDelegate isNetworkReachable]) {

        return [self errorViewControllerWithTitle:error.explanation andRetry:retryBlock];
    }
    else {
        ErrorViewController *evc = [self errorViewControllerWithTitle:@"Network Connection Lost"
                                                           andMessage:@"Waiting for WIFI or cell network..."];
        // for automatic retry (no retry button)
        evc->_retryBlock = retryBlock;
        return evc;
    }
}


-(void)dismiss {
    BBTrace();
    [Flurry logEvent:kFlurryErrorDismissed];
    if (self.navigationController.topViewController==self) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (_retryBlock) {
        _retryBlock();
        _retryBlock = nil;
    }
}

#pragma mark -
#pragma mark Lifecycle methods
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
    _viewDidLoadBlock();
    [self _setupStyle];
    
    if (self.navigationItem) {
        self.navigationItem.title = @"Uh oh...";
    }
    if (_hideBackButton) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    BBTrace();
}

-(void)viewDidDisappear:(BOOL)animated {
    BBTrace();
    if (BBAppDelegate.sharedDelegate.currentErrorViewController==self) {
        BBAppDelegate.sharedDelegate.currentErrorViewController=nil;
    }
    [self _attemptRetry];
}

- (void)viewDidUnload
{
    BBTrace();
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)_setupStyle {
    self.view.backgroundColor = [UIColor bbHeaderPattern];
    
    self.retryButton.titleLabel.font = [UIFont bbBoldFont:20];
    self.errorMessage.font = [UIFont bbMessageFont:18];
    self.errorTitle.font = [UIFont bbBoldFont:22];
}

#pragma mark Actions 
- (IBAction)onRetryPressed:(id)sender {
    BBTrace();
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_attemptRetry {
    BBTrace();
    if (_retryBlock) {
        _retryBlock();
        _retryBlock = nil;
    }
}

@end
