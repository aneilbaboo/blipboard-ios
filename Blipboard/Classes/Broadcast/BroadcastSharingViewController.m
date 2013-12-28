//
//  BroadcastSharingViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/28/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BroadcastSharingViewController.h"
#import <Twitter/Twitter.h>
#import "BBCheckButton.h"
#import "BBFacebookSharer.h"
#import "SHKTwitter.h"

#pragma mark -
#pragma mark Helper classes
@interface BroadcastSHKDelegate : NSObject <SHKSharerDelegate>
@property (nonatomic,strong) BBCheckButton *button;
+(instancetype)delegateWithButton:(BBCheckButton *)button;
@end

#pragma mark -
#pragma mark BroadcastSharingViewController
@implementation BroadcastSharingViewController {
    NSMutableDictionary *_sharers;
}

+(instancetype)viewControllerWithBlip:(Blip *)blip andDelegate:(id<BroadcastFlowDelegate>)delegate {
    BroadcastSharingViewController *vc = [[BroadcastSharingViewController alloc] initWithNibName:nil bundle:nil];
    vc.blip = blip;
    vc.delegate = delegate;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self _setupStyle];
    [self _setupNavBar];
    [self _setupSharers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Setup

-(void)_setupSharers {
    // sharing buttons
    [self _addSharingButton:@"Facebook"
             unselectedIcon:@"icn_facebook.png"
               selectedIcon:@"icn_facebook_selected.png"
                     sharer:[BBFacebookSharer class]
             noTopSeparator:YES];
    [self _addSharingButton:@"Twitter"
             unselectedIcon:@"icn_twitter.png"
               selectedIcon:@"icn_twitter_selected.png"
                     sharer:[SHKTwitter class]];}

-(void)_setupStyle {
    self.view.backgroundColor = UIColor.bbGridPattern;
    
    // sharing panel
    [self.sharingButtonsPanel setBackgroundColor:[UIColor bbWhite]];
    
    CALayer *sharingLayer = self.sharingButtonsPanel.layer;
    sharingLayer.cornerRadius = 5;
    sharingLayer.shadowColor = UIColor.blackColor.CGColor;
    sharingLayer.shadowOpacity = .7;
    sharingLayer.shadowRadius = 4;
    sharingLayer.shadowOffset = CGSizeMake(0, 2);
    
    [self.editFirstLabel setFont:[UIFont bbBoldFont:22]];
    [self.editFirstLabel setTextColor:[UIColor bbGray4]];
    
}

-(void)_setupNavBar {
    self.navigationItem.title = @"Share Blip";
    
    self.doneButton = [BBGenericBarButtonItem barButtonItem:@"Done" target:self action:@selector(donePressed:)];
    
    self.navigationItem.rightBarButtonItem = self.doneButton;
    [self.navigationItem setHidesBackButton:YES];
}

const char *kSHKSharerClassKey = "SHKSharerClass";
-(UIButton *)_addSharingButton:(NSString *)title unselectedIcon:(NSString *)unselectedIcon selectedIcon:(NSString *)selectedIcon sharer:(Class)sharerClass {
    return [self _addSharingButton:title unselectedIcon:unselectedIcon selectedIcon:selectedIcon sharer:sharerClass noTopSeparator:NO];
}

-(UIButton *)_addSharingButton:(NSString *)title unselectedIcon:(NSString *)unselectedIcon selectedIcon:(NSString *)selectedIcon sharer:(Class)sharerClass noTopSeparator:(BOOL)noTopSeparator {
    title = [NSString stringWithFormat:@" %@",title];
    BBCheckButton *button = [BBCheckButton button];
    CGFloat width = self.sharingButtonsPanel.width;
    CGFloat buttonTop = self.sharingButtonsPanel.height;
    button.rx = 0;
    button.ry = buttonTop;
    button.width = width;
    button.height = 50;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.checked = NO;
    [button setImage:[UIImage imageNamed:unselectedIcon] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedIcon] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:selectedIcon] forState:UIControlStateHighlighted];
    button.showsTouchWhenHighlighted = YES;
    button.reversesTitleShadowWhenHighlighted = NO;
    [button addTarget:self action:@selector(sharingOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];

    if (!noTopSeparator) {
        // add a separator bevel line:
        CALayer *topLine = [CALayer layerWithLineFrom:CGPointMake(0,0)
                                                   to:CGPointMake(width, 0)
                                                color:[UIColor bbGray0].CGColor
                                                width:1
                                                 join:nil
                                          dashPattern:nil];
        CALayer *bottomLine = [CALayer layerWithLineFrom:CGPointMake(0,1)
                                                      to:CGPointMake(width,1)
                                                   color:[UIColor whiteColor].CGColor
                                                   width:1
                                                    join:nil
                                             dashPattern:nil];
        
        [button.layer addSublayer:topLine];
        [button.layer addSublayer:bottomLine];
    }
    
    [self.sharingButtonsPanel addSubview:button];
    self.sharingButtonsPanel.height = button.bottom;
    
    objc_setAssociatedObject(button, kSHKSharerClassKey, sharerClass, OBJC_ASSOCIATION_ASSIGN);
    return button;
}

#pragma mark -
#pragma mark Actions
-(IBAction)sharingOptionButtonPressed:(BBCheckButton *)button {
    BBLog(@"%@",button.titleLabel.text);
    // Create the item to share (in this example, a url)
    if (!button.checked) {
        Class sharerClass = objc_getAssociatedObject(button, kSHKSharerClassKey);
        NSURL *url = [NSURL URLWithString:self.blip.link];
        SHKItem *item = [SHKItem URL:url title:self.blip.message contentType:SHKURLContentTypeWebpage];
        item.facebookURLShareDescription = @"And other interesting things nearby";
        button.selected = YES;
        button.userInteractionEnabled = NO;
        
        // Share the item
        SHKSharer *sharer = [[sharerClass alloc] init];

        // autosharing for later...
        //sharer.shouldAutoShare = !self.editFirstSwitch.on;
        [sharer setShareDelegate:[BroadcastSHKDelegate delegateWithButton:button]];
        [sharer loadItem:item];
        [Flurry logEventWithParams:kFlurryBroadcastSharingStart,
         @"sharer",[sharer sharerTitle],
         nil];
        [sharer share];
    }

}

-(void)donePressed:(id)sender {
    BBTrace();
    [self.delegate broadcastFlowDidFinish:self.blip];
}
@end

#pragma mark -
#pragma mark BroadcastSHKDelegate
@implementation BroadcastSHKDelegate

+(instancetype)delegateWithButton:(BBCheckButton *)button {
    BroadcastSHKDelegate *bsd = [BroadcastSHKDelegate new];
    bsd.button = button;
    return bsd;
}

-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin {
    BBTrace();
    self.button.selected = NO;
    self.button.userInteractionEnabled = YES;
    [Flurry logEvent:kFlurryBroadcastSharingAbort withErrorAndParams:error,
     @"sharer",sharer.sharerTitle,
     @"reason",@"failed-with-error",
     nil];
}

-(void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success {
    BBTrace();
}

-(void)sharerCancelledSending:(SHKSharer *)sharer {
    BBTrace();
    self.button.selected = NO;
    self.button.userInteractionEnabled = YES;
    [Flurry logEventWithParams:kFlurryBroadcastSharingAbort,
     @"sharer",sharer.sharerTitle,
     @"reason",@"user-cancelled",
     nil];

}

-(void)sharerFinishedSending:(SHKSharer *)sharer {
    BBTrace();
    // success! check the button:
    [self.button setChecked:YES animated:YES];
    self.button.userInteractionEnabled = NO;
    [Flurry logEventWithParams:kFlurryBroadcastSharingComplete,
     @"sharer",sharer.sharerTitle,
     nil];
}

-(void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer {
    BBTrace();
    self.button.selected = NO;
    self.button.userInteractionEnabled = YES;
    [Flurry logEventWithParams:kFlurryBroadcastSharingAbort,
     @"sharer",sharer.sharerTitle,
     @"reason",@"bad-credentials",
     nil];
}

-(void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer {
    BBTrace();
    self.button.selected = NO;
    self.button.userInteractionEnabled = YES;
    [Flurry logEventWithParams:kFlurryBroadcastSharingAbort,
     @"sharer",sharer.sharerTitle,
     @"reason",@"auth-error",
     nil];
}

-(void)sharerStartedSending:(SHKSharer *)sharer {
    BBTrace();
    self.button.selected = NO;    
}


@end

