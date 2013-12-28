//
//  ChannelDescriptionViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/17/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelDescriptionViewController : UIViewController
@property (nonatomic,weak) IBOutlet UITextView *descriptionText;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIView *pictureBackground;
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,readonly) Channel *channel;

+(ChannelDescriptionViewController *)channelDescriptionViewController:(Channel *)channel;

-(void)configureWithChannel:(Channel *)channel;
@end
