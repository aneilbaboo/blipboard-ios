 //
//  InfoViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic,weak) IBOutlet BBGenericButton *feedbackButton;
@property (nonatomic,weak) IBOutlet BBGenericButton *termsButton;
@property (nonatomic,weak) IBOutlet BBGenericButton *privacyButton;
@property (nonatomic,weak) IBOutlet BBGenericButton *licensesButton;
@property (nonatomic,weak) IBOutlet UILabel *aboutText;

+ (id)infoViewController;
- (IBAction)showFeedback:(id)sender;
- (IBAction)showPrivacy:(id)sender;
- (IBAction)showTerms:(id)sender;
- (IBAction)showLicenses:(id)sender;
@end
