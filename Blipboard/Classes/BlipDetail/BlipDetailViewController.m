//
//  BlipDetailViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BlipDetailViewController.h"
#import "Blip.h"
#import "BBLog.h"
#import "ChannelDetailViewController.h"
#import "UIView+RoundedCorners.h"

@implementation BlipDetailViewController

- (id)initWithBlip:(Blip *)blip withDelegate:(id<BlipDetailViewDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    self.blip = blip;
    self.delegate = delegate;
    return self;
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
    Blip *blip= self.blip;
    
    BBLog(@"author = %@", blip.author.picture);
    [self.authorPicture setImageWithURLString:blip.author.picture placeholderImage:nil];
    self.authorName.text = blip.author.name;

    if (blip.author.id == blip.place.id) {
        [self hidePlace];
    }
    else {
        [self.placePicture setImageWithURLString:blip.place.picture placeholderImage:nil];
        self.placeName.text = blip.place.name;
    }

    if (blip.sourcePhoto) {
        BBLog(@"Showing hires blip picture: %@", blip.sourcePhoto);
        
        if (blip.sourceHeight && blip.sourceWidth) {
            self.blipPicture.contentMode = UIViewContentModeScaleAspectFit;
            CGFloat adjustedWidth = self.blipPicture.frame.size.width * [blip.sourceHeight floatValue] / [blip.sourceWidth floatValue];
            self.blipPicture.frame = CGRectMake(self.blipPicture.frame.origin.x,
                                                self.blipPicture.frame.origin.y,
                                                self.blipPicture.frame.size.width,
                                                adjustedWidth);
        }
        else {
            self.blipPicture.contentMode = UIViewContentModeScaleAspectFill;
            self.blipPicture.clipsToBounds = YES;
        }

        [self.blipPicture setImageWithURLString:blip.sourcePhoto placeholderImage:nil];
    }
    else if (blip.photo)
    {
        BBLog(@"Showing lowres blip picture: %@", blip.photo);
        self.blipPicture.contentMode = UIViewContentModeScaleAspectFill;
        self.blipPicture.clipsToBounds = YES;
        [self.blipPicture setImageWithURLString:blip.photo placeholderImage:nil];
    }
    else {
        [self hideBlipPicture];
    }
    
    self.blipMessage.text = blip.message;
    [self resizeBlipMessage];

    if ([self.blip.likes.isLiker boolValue]) {
        [self.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    }

    //CGRect frame = self.blipMessage.frame;
    //frame.size.height = self.blipMessage.contentSize.height;
    //self.blipMessage.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in self.scrollView.subviews)
    {
        if (!view.hidden)
        {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            if (y + h > scrollViewHeight)
            {
                scrollViewHeight = h + y;
            }
        }
    }
    //self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    [self.scrollView setContentSize:(CGSizeMake(self.scrollView.frame.size.width, scrollViewHeight))];
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


- (void) moveUIView:(UIView*)view yOffset:(CGFloat)y
{
    CGPoint position = view.center;
    position.y -= y;
    view.center = position;
}

- (void) hidePlace
{
    CGFloat yoffset = self.placePicture.frame.size.height;
    self.placePicture.hidden = TRUE;
    self.placeName.hidden = TRUE;
    self.placeDisclosure.hidden = TRUE;
    [self.blipPicture moveUp:yoffset];
    [self.blipMessage moveUp:yoffset];
    [self.belowBlipMessageView moveUp:yoffset];
}

- (void) hideBlipPicture
{
    CGFloat yoffset = self.blipPicture.frame.size.height;
    self.blipPicture.hidden = TRUE;
    [self.blipMessage moveUp:yoffset];
    [self.belowBlipMessageView moveUp:yoffset];
}

- (void) resizeBlipMessage
{
    CGRect frame = self.blipMessage.frame;
    CGFloat oldHeight = frame.size.height;
    frame.size.height = self.blipMessage.contentSize.height;
    self.blipMessage.frame = frame;
    [self.belowBlipMessageView moveUp:(oldHeight - frame.size.height)];
}

-(IBAction)likePressed:(id)sender
{
    if (![self.blip.likes.isLiker boolValue]) {
        [self.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
        [self.blip like:^(Blip *blip, ServerModelError *error) {
            if (!error) {
                [self.delegate blipDetailView:self didLikeBlip:blip];
                BBLog(@"likeButton = %@", self.likeButton.titleLabel.text);
            }
        }];
    }
    else {
        [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        [self.blip unlike:^(Blip *blip, ServerModelError *error) {
            if (!error) {
                [self.delegate blipDetailView:self didUnlikeBlip:blip];
            }
        }];
    }
}

-(IBAction)commentPressed:(id)sender
{
}

-(IBAction)authorDisclosurePressed:(id)sender
{
    ChannelDetailViewController *detail = [[ChannelDetailViewController alloc] initWithChannel:self.blip.author];
    [self.navigationController pushViewController:detail animated:YES];
    [self.delegate blipDetailView:self didSelectChannel:self.blip.author];
}

-(IBAction)placeDisclosurePressed:(id)sender
{
    ChannelDetailViewController *detail = [[ChannelDetailViewController alloc] initWithChannel:self.blip.place];
    [self.navigationController pushViewController:detail animated:YES];
    [self.delegate blipDetailView:self didSelectChannel:self.blip.place];
}

@end
