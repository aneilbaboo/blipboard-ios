//
//  BlipDetailViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIHTTPImageView.h"
#import <MapKit/MapKit.h>

@class Blip;
@class BlipDetailViewController;
@class Channel;

@protocol BlipDetailViewDelegate <NSObject>
-(void)blipDetailView:(BlipDetailViewController*)blipDetail didSelectChannel:(Channel*)channel;
-(void)blipDetailView:(BlipDetailViewController*)blipDetail didLikeBlip:(Blip*)blip;
-(void)blipDetailView:(BlipDetailViewController*)blipDetail didUnlikeBlip:(Blip*)blip;
@end

@interface BlipDetailViewController : UIViewController

@property (nonatomic,weak) id<BlipDetailViewDelegate> delegate;
@property (nonatomic,weak) IBOutlet UIScrollView* scrollView;

@property (nonatomic,weak) IBOutlet UIHTTPImageView* authorPicture;
@property (nonatomic,weak) IBOutlet UILabel* authorName;
@property (nonatomic,weak) IBOutlet UIButton* authorDisclosure;

@property (nonatomic,weak) IBOutlet UIHTTPImageView* placePicture;
@property (nonatomic,weak) IBOutlet UILabel* placeName;
@property (nonatomic,weak) IBOutlet UIButton* placeDisclosure;

@property (nonatomic,weak) IBOutlet UIHTTPImageView* blipPicture;
@property (nonatomic,weak) IBOutlet UITextView* blipMessage;

@property (nonatomic,weak) IBOutlet UIView* belowBlipMessageView;
@property (nonatomic,weak) IBOutlet UILabel* blipTime;
@property (nonatomic,weak) IBOutlet UIButton *likeButton;
@property (nonatomic,weak) IBOutlet UIButton *commentButton;

@property (nonatomic,strong) Blip *blip;

- (id)initWithBlip:(Blip *)blip withDelegate:(id<BlipDetailViewDelegate>)delegate;
- (void) hidePlace;
- (void) hideBlipPicture;
- (void) resizeBlipMessage;

-(IBAction)authorDisclosurePressed:(id)sender;
-(IBAction)placeDisclosurePressed:(id)sender;
-(IBAction)likePressed:(id)sender;
-(IBAction)commentPressed:(id)sender;

@end
