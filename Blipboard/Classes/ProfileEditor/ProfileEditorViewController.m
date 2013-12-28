//
//  ProfileViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/24/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ProfileEditorViewController.h"
#import "Account.h"
#import "BBAppDelegate.h"
#import "BBGenericBarButtonItem.h"
#import "SlideoutViewController.h"

@implementation ProfileEditorViewController

+(id)viewController     {
    ProfileEditorViewController *pvc = [[ProfileEditorViewController alloc] initWithNibName:nil bundle:nil];
    return pvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bbGridPattern];
    self.background.backgroundColor = [UIColor whiteColor];
    [self.background.layer setCornerRadius:5];
    [self.background bbSetShadow:BlipboardShadowOptionLeft|BlipboardShadowOptionDown];
    
    [self.navigationItem setTitle:@"Profile"];
    [self.name setBackgroundColor:[UIColor clearColor]];
    [self.name setTextColor:[UIColor bbWarmGray]];
    [self.name setFont:[UIFont bbBoldFont:24]];
    
    [self.desc setFont:[UIFont bbBlipMessageFont]];
    [self.desc setTextColor:[UIColor bbWarmGray]];
    [self.desc becomeFirstResponder];
    
    self.saveButton = [BBGenericBarButtonItem barButtonItem:@"Save"
                                                     target:self
                                                     action:@selector(savePressed:)];
    self.saveButton.enabled = FALSE;
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    Account *account = BBAppDelegate.sharedDelegate.myAccount;

    self.pictureBackground.backgroundColor = [UIColor bbWhite];
    [self.pictureBackground bbSetShadow:BlipboardShadowOptionDown|BlipboardShadowOptionLeft];
    [self.picture setImageWithURLString:account.picture placeholderImage:nil];
    self.name.text = account.name;
    self.desc.text = account.desc;
    self.placeholder.hidden = (self.desc.text.length>0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    [Heatmaps track:self.view withKey:@"92e49bf7098d3dd4-0817f084"];
}

#pragma mark -
#pragma mark Actions
-(IBAction)picturePressed:(id)sender {
    
    RIButtonItem *okItem = [RIButtonItem item];
    okItem.label = @"OK";
    okItem.action = ^{}; // no-op block
    NSString *message = @"We want to be able to set our profile picture too.\n\nWe're working on it!";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In development"
                                                    message:message
                                           cancelButtonItem:okItem otherButtonItems:nil];
    
    [Flurry logEvent:kFlurryProfilePictureTapped];
    [alert show];
}

-(void)savePressed:(id)sender {
    [self.desc resignFirstResponder];
    [self.activityIndicator startAnimating];
    [Flurry logEvent:kFlurryProfileSaved];

    BBAppDelegate.sharedDelegate.myAccount.desc = self.desc.text;
    [BBAppDelegate.sharedDelegate.myAccount putAccount:^(Account *account, ServerModelError *error) {
        [self.activityIndicator stopAnimating];
        if (error) {
            RIButtonItem *button = [[RIButtonItem alloc] init];
            [button setLabel:@"Ok"];
            [button setAction:^{}];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Apologies - Failed while saving account information" cancelButtonItem:button
                                                       otherButtonItems:nil];
            [alertView show];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];

    // broadcast changes to other copies of the account
    [BBAppDelegate.sharedDelegate.myAccount changeServerInstancesUsingKeyValues:@{@"desc":self.desc.text}];

}

#pragma mark -
#pragma mark UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView {
    self.saveButton.selected = YES;
    self.saveButton.enabled = YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    self.placeholder.hidden = YES;
}
@end
