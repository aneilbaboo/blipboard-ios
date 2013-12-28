//
//  InfoViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//
#import <RestKit/RestKit.h>
#import "BBApplication.h"
#import "ASIHTTPRequest.h"
#import "InfoViewController.h"
#import "SlideoutViewController.h"


@implementation InfoViewController

+ (id)infoViewController {
    return [[InfoViewController alloc] initWithNibName:nil bundle:nil];
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

    [[SlideoutViewController sharedController] addSlideoutMenu:self];
    [[SlideoutViewController sharedController] addMenuButtonAndBadge:self];

    [self _setupStyle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark style
-(void)_setupStyle {
    self.navigationItem.title = @"About";
    self.view.backgroundColor = [UIColor bbGridPattern];
    [self _configureButton:self.feedbackButton];
    [self _configureButton:self.privacyButton];
    [self _configureButton:self.termsButton];
    [self _configureButton:self.licensesButton];
    
    self.aboutText.font = [UIFont bbMessageFont:16];
    self.aboutText.textColor = [UIColor bbWarmGray];
    
    self.feedbackButton.hidden = ![MFMailComposeViewController canSendMail];
}

-(void)_configureButton:(UIButton *)button {
    [button.titleLabel setFont:[UIFont bbBoldFont:18]];
    [button setTitleColor:[UIColor bbWarmGray] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateHighlighted];
    [button setShowsTouchWhenHighlighted:YES];
}

#pragma mark -
#pragma mark Operations
- (void)openURL:(NSString *)path {
    NSString *webURLString = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"blipboardWebUri"]
                          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *webURL = [NSURL URLWithString:webURLString];
    NSURL *absoluteURL = [[webURL URLByAppendingPathComponent:@"iphone"] URLByAppendingPathComponent:path];

    [[UIApplication sharedApplication] openURL:absoluteURL];
}

-(void)showEmailDialog {
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    [mailViewController setMailComposeDelegate:self];
    [mailViewController setSubject:@"Feedback"];
    [mailViewController setToRecipients:@[@"feedback@blipboard.com"]];
    [mailViewController setMessageBody:@"" isHTML:NO];
    [self presentViewController:mailViewController animated:YES completion:^{}];
}

#pragma mark -
#pragma mark Actions
- (void)showFeedback:(id)sender {
    [self showEmailDialog];
}

- (void)showPrivacy:(id)sender {
    [self openURL:@"privacy"];
}

- (void)showTerms:(id)sender {
    [self openURL:@"terms"];
}

- (void)showLicenses:(id)sender {
    [self openURL:@"licenses"];
}


#pragma mark -
#pragma mark MFMailViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
