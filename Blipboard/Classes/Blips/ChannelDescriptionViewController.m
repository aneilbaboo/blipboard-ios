//
//  ChannelDescriptionViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/17/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ChannelDescriptionViewController.h"


@implementation ChannelDescriptionViewController

+(ChannelDescriptionViewController *)channelDescriptionViewController:(Channel *)channel {
    ChannelDescriptionViewController *cdvc = [[ChannelDescriptionViewController alloc] initWithNibName:nil bundle:nil];
    
    cdvc->_channel = channel;
    return cdvc;
}

- (void)_setupStyle {
    self.view.backgroundColor = [UIColor bbGridPattern];
    [self.pictureBackground bbSetShadow:BlipboardShadowOptionDown];
    self.scrollView.backgroundColor = [UIColor bbGridPattern];
    self.descriptionText.font = [UIFont bbBlipMessageFont];
    self.descriptionText.textColor = [UIColor bbWarmGray];
    self.descriptionText.layer.cornerRadius = 6;
    [self.descriptionText bbSetShadow:BlipboardShadowOptionDown];
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
    [self _setupStyle];
    [self configureWithChannel:self.channel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureWithChannel:(Channel *)channel {
    if (self.channel.desc.length>0) {
        self.descriptionText.text = self.channel.desc;
        self.descriptionText.size = [self.descriptionText sizeThatFits:CGSizeMake(self.descriptionText.width, 100000)];
        self.descriptionText.hidden = NO;
    }
    else {
        self.descriptionText.hidden = YES;
    }
    self.scrollView.contentSize = CGSizeMake(self.view.width, self.descriptionText.bottom + 20);
    [self.picture setImageWithURLString:self.channel.picture placeholderImage:nil];
    self.navigationItem.title = self.channel.name;
}

#pragma mark -
#pragma mark
@end
