//
//  BroadcastTextInputViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BroadcastTextInputViewController.h"
#import "BBGenericBarButtonItem.h"
#import "BBBackBarButtonItem.h"
#import "ErrorViewController.h"
#import "BBTopicPickerItemView.h"
#import "BroadcastSharingViewController.h"
#import "BroadcastDelegate.h"

@implementation BroadcastTextInputViewController

+ (id)viewControllerWithPlaceChannel:(PlaceChannel *)placeChannel andDelegate:(id<BroadcastFlowDelegate>)delegate {
    BroadcastTextInputViewController *btivc = [[BroadcastTextInputViewController alloc] initWithNibName:nil bundle:nil];
    [btivc _configureWithChannel:placeChannel];
    btivc.delegate = delegate;
    
    return btivc;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)_configureWithChannel:(PlaceChannel *)placeChannel {
    _placeChannel = placeChannel;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark LifeCycle 
- (void)viewDidLoad
{
    BBTrace();
    [super viewDidLoad];
    
    [self _setupScrollView];
    [self _setupMapView];
    [self _setupTopicPicker];
    [self _setupMessageArea];
    [self _setupNavBar];
    
    self.view.backgroundColor = [UIColor bbGridPattern];
}

- (void)viewWillAppear:(BOOL)animated {
    BBTrace();
    [super viewWillAppear:animated];
    [self setSelection:BroadcastTextInputTopicPicker animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    BBTrace();
    [super viewDidAppear:animated];
    
    BBLog(@"Heatmaps track BroadcastTextInputViewController");
    [Heatmaps track:self.view withKey:@"92e49bf7098d3dd4-ca781396"]; //
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

#pragma mark -
#pragma mark Operations
-(void)shareBlip:(Blip *)blip {
    if (BBAppDelegate.sharedDelegate.myAccount.capabilities.disableSharing) {
        [self.delegate broadcastFlowDidFinish:blip];
    }
    else {
        BroadcastSharingViewController *share = [BroadcastSharingViewController viewControllerWithBlip:blip andDelegate:self.delegate];
        [self.navigationController pushViewController:share animated:YES];
    }

}

-(void)broadcastBlip {
    if (self.broadcastButton.selected) {
        self.broadcastButton.enabled = NO;
        [self.messageTextView resignFirstResponder];
        BBProgressHUD *hud = [BBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        NSDictionary* params = [Flurry paramsWithError:nil,
                                @"id",self.placeChannel.id,
                                @"category",self.placeChannel.category,
                                //                                @"prompt-message",self._promptMessage,
                                @"count",[@(self.messageTextView.text.length) stringValue],
                                nil];
        [Flurry logEvent:kFlurryBroadcastPost withParameters:params];
        [self.placeChannel broadcastHere:self.messageTextView.text topic:self.topicPicker.selectedTopic expiry:nil block:^(Blip *blip, ServerModelError *error) {
            self.broadcastButton.enabled = YES;
            [hud hide:YES];
            if (!error) {
                [self shareBlip:blip];
            }
            else {
                ErrorViewController *evc = [ErrorViewController errorViewControllerWithError:error];
                [self.navigationController pushViewController:evc animated:YES];
            }
        }];
    }
}

#pragma mark -
#pragma mark Properties
-(void)setSelection:(BroadcastTextInputSelection)selection {
    [self setSelection:selection animated:YES];
}

-(void)setSelection:(BroadcastTextInputSelection)selection animated:(BOOL)animated {
    BBLog(@"%d animated:%d",selection,animated);
    _selection = selection;
    self.mapButton.selected = (selection==BroadcastTextInputMap);
    self.topicPinButton.selected = (selection==BroadcastTextInputTopicPicker);

    if (selection==BroadcastTextInputText) {
        [self.messageTextView becomeFirstResponder];
    }
    else {
        [self.messageTextView resignFirstResponder];
        switch (selection) {
            case BroadcastTextInputMap:
                [self.scrollView setContentOffset:self.mapView.origin animated:animated];
                break;
                
            case BroadcastTextInputTopicPicker:
                [self.scrollView setContentOffset:self.topicPicker.origin animated:animated];
                break;
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Actions
-(IBAction)topicPinTapped:(id)sender {
    self.selection = BroadcastTextInputTopicPicker;
    [self.messageTextView resignFirstResponder];

    [Flurry logEventWithParams:kFlurryBroadcastTopicButton,
     @"topic",self.topicPicker.selectedTopic ? self.topicPicker.selectedTopic.name : @"",
     @"placeTopic",self.placeChannel.defaultTopic ? self.placeChannel.defaultTopic.name : @"",
     nil];
}

-(IBAction)mapButtonTapped:(id)sender {
    self.selection =BroadcastTextInputMap;
    [Flurry logEventWithParams:kFlurryBroadcastMapButton,
     @"place.id",self.placeChannel.id,
     @"place.name",self.placeChannel.name,
     nil];
}

- (void)broadcastPressed:(id)sender {
    [self broadcastBlip];
}

- (void)cancelPressed:(id)sender {
    BBTrace();
    [Flurry logEvent:kFlurryBroadcastCancel
               withParameters:[NSDictionary dictionaryWithObject:self.placeChannel.id forKey:@"id"]];

    //[self.delegate broadcastViewControllerDidCancel:self];
    UIViewController* vc = [self.navigationController popViewControllerAnimated:YES];
    if (vc == nil) {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)placeHolderTapped:(id)sender {
    self.selection = BroadcastTextInputText;
    if (self.placeHolder.hidden == NO) {
        NSDictionary* params = [Flurry paramsWithError:nil,
                                @"id",self.placeChannel.id,
                                @"category",self.placeChannel.category,
                                //@"prompt-message",self._promptMessage,
                                nil];
        [Flurry logEvent:kFlurryBroadcastTextEntry withParameters:params];
        
        self.placeHolder.hidden = YES;
        self.messageTextView.alpha = 1;
        [self.messageTextView becomeFirstResponder];
    }
}

#pragma mark -
#pragma mark BBTopicPickerDelegate
-(void)topicPicker:(BBTopicPicker *)topicPicker selectedTopic:(Topic *)topic {
    [self.topicPinImage setImageWithURLString:topic.picture2x placeholderImage:nil];

    // once user selects a topic, change text input prompt:
    self.prompt.text = [NSString stringWithFormat:@"Write a short note at %@...",self.placeChannel.name];
    
    [Flurry logEventWithParams:kFlurryBroadcastTopicSelected,
     @"topic",topic.name,nil];
}

#pragma mark -
#pragma mark Setup
-(void)_setupScrollView {
    [self.view addSubview:self.scrollView];
    self.scrollView.rx = 0;
    self.scrollView.ry = self.view.height - self.scrollView.height;
}

-(void)_setupNavBar {
    if (self.navigationController.childViewControllers.count==1) {
        UIBarButtonItem *cancelButton = [BBGenericBarButtonItem barButtonItem:@"Cancel"
                                                                       target:self
                                                                       action:@selector(cancelPressed:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    else {
        [BBBackBarButtonItem addBackBarButtonItem:@"Back" toController:self];
    }
    
    
    
    self.broadcastButton = [BBGenericBarButtonItem barButtonItem:@"   Blip   "
                                                          target:self action:@selector(broadcastPressed:)];
    
    self.broadcastButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = self.broadcastButton;
}

-(void)_setupTopicPicker {
    [BBAppDelegate.sharedDelegate.myAccount getTopics:^(NSMutableArray *topics, ServerModelError *error) {
        self.topicPicker.topics = topics;
        [self.topicPicker selectTopic:self.placeChannel.defaultTopic animated:YES];
        [self.topicPinImage
         setImageWithURLString:self.placeChannel.defaultTopic.picture2x
         placeholderImage:nil];
    }];
    
}

-(void)_setupMessageArea {
    _messageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    _messageBackgroundView.layer.shadowOpacity= .7;
    _messageBackgroundView.layer.shadowRadius = 3;
    _messageBackgroundView.layer.shadowOffset = CGSizeMake(0, 2);
    _messageBackgroundView.layer.borderColor = [UIColor bbGray3].CGColor;
    _messageBackgroundView.layer.borderWidth = 1;
//    !am! always hidden, but please leave for now
//    _messageBackdrop.image = [[UIImage imageNamed:@"textField.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    //[_messageTextView becomeFirstResponder];
    _messageTextView.font = [UIFont bbBlipMessageFont];
    _messageTextView.textColor = [UIColor bbWarmGray];
    
    _prompt.font = [UIFont bbBoldFont:18];
    _prompt.textColor = [UIColor bbGray1];
    _prompt.text = [NSString stringWithFormat:@"What's interesting at %@?",self.placeChannel.name];
    
    _messageTextView.delegate = self;
}

-(void)_setupMapView {
    [self.mapView addAnnotation:_placeChannel];
    [self.mapView selectAnnotation:_placeChannel animated:NO];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(_placeChannel.coordinate, 500, 500)];
}

#pragma mark - 
#pragma mark UITextViewDelegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.selection!=BroadcastTextInputText) {
        self.selection = BroadcastTextInputText;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    NSString *trimmedText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.broadcastButton.selected = self.broadcastButton.enabled = (trimmedText.length>0);

//    if (self.broadcastButton.enabled) {
//        [self.broadcastButton setTitleColor:[UIColor bbWhite] forState:UIControlStateNormal];
//        [self.broadcastButton setBackgroundImage:[UIImage imageNamed:@"btn_follow_follow.png"]
//                                        forState:UIControlStateNormal];
//    }
//    else {
//        [self.broadcastButton setBackgroundImage:[UIImage imageNamed:@"bnt_nav_white.png"]
//                                        forState:UIControlStateNormal];
//        [self.broadcastButton setTitleColor:[UIColor bbGray1] forState:UIControlStateNormal];
//    }
    if (!self.placeHolder.hidden) {
        [self placeHolderTapped:self.placeHolder];
    }
}
@end
