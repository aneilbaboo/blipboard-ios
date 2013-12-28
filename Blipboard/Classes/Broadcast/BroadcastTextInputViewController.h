//
//  BroadcastTextInputViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceChannel.h"
#import "BroadcastSelectPlaceViewController.h"
#import "BBTopicPicker.h"

typedef enum {
    BroadcastTextInputText=0,
    BroadcastTextInputMap,
    BroadcastTextInputTopicPicker
} BroadcastTextInputSelection;

@interface BroadcastTextInputViewController : UIViewController <UITextViewDelegate,BBTopicPickerDelegate>


@property (nonatomic,strong) PlaceChannel *placeChannel;
@property (nonatomic,weak) id<BroadcastFlowDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *topics;
@property (nonatomic) BroadcastTextInputSelection selection;

// controls
@property (nonatomic,weak) IBOutlet UITextView *messageTextView;
@property (nonatomic,weak) IBOutlet UIImageView *messageBackdrop;
@property (nonatomic,weak) IBOutlet UIView *messageBackgroundView;
@property (nonatomic,weak) IBOutlet UILabel *prompt;
@property (nonatomic,weak) IBOutlet UIView *placeHolder;
@property (nonatomic,weak) IBOutlet BBImageView *topicPinImage;
@property (nonatomic,weak) IBOutlet UIButton *topicPinButton;
@property (nonatomic,weak) IBOutlet UIButton *mapButton;

@property (nonatomic,strong) BBGenericBarButtonItem *broadcastButton;

@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet MKMapView *mapView;
@property (nonatomic,weak) IBOutlet BBTopicPicker *topicPicker;


+ (id)viewControllerWithPlaceChannel:(PlaceChannel *)placeChannel andDelegate:(id<BroadcastFlowDelegate>)delegate;

- (IBAction)placeHolderTapped:(id)sender;
- (IBAction)topicPinTapped:(id)sender;
@end
