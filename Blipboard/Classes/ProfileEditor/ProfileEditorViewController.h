//
//  ProfileViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/24/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"
#import "BBGenericBarButtonItem.h"

@interface ProfileEditorViewController : UIViewController <UITextViewDelegate>
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UITextView *desc;
@property (nonatomic,weak) IBOutlet UILabel *placeholder;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIView *pictureBackground;
@property (nonatomic,weak) IBOutlet UIButton *pictureButton;
@property (nonatomic,weak) IBOutlet UIView *background;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) BBGenericBarButtonItem* saveButton;

+(id)viewController;

-(IBAction)picturePressed:(id)sender;
@end
