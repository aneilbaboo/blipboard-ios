//
//  ChannelDetailViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BaseBlipsViewController.h"
#import "BBImageView.h"
#import "Channel.h"
#import "BBCountLabel.h"
#import "ChannelTableView.h"

@class ChannelDetailViewController;

typedef enum {
    ChannelDetailTabFirst =0,
    ChannelDetailTabBlips = 0,
    ChannelDetailTabFollowers=1,
    ChannelDetailTabFollowing=2,
    ChannelDetailTabLast=2
} ChannelDetailTab;

typedef enum {
    ChannelDetailHeaderLayoutCompressed,
    ChannelDetailHeaderLayoutExpanded
} ChannelDetailHeaderLayout;

@interface ChannelDetailViewController : BaseBlipsViewController <UIAlertViewDelegate,UIScrollViewDelegate,ChannelTableViewDelegate,BBNavigationControllerEvents>

@property (nonatomic,strong) Channel *channel;
@property (nonatomic,readonly) BOOL isUserAccount;
@property (nonatomic,strong) NSMutableArray *followers;
@property (nonatomic,strong) NSMutableArray *following;

// tabs
@property (nonatomic,strong) UIScrollView *tabScroll; // scrolls horizontally
@property (nonatomic,strong) ChannelTableView *followerTable;
@property (nonatomic,strong) ChannelTableView *followingTable;

// Header elements
@property (nonatomic,strong) IBOutlet UIView *header;

// minimal header
@property (nonatomic,weak) IBOutlet UIView *minimalHeader;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet BBCountLabel *guruScore;
@property (nonatomic,weak) IBOutlet BBTuneInButton *tuneInButton;
@property (nonatomic,weak) IBOutlet UIButton *editButton;
@property (nonatomic,weak) IBOutlet UIButton *blacklistButton;
@property (nonatomic,weak) IBOutlet UIView *headerBottomLine;

// expandible description
@property (nonatomic,weak) IBOutlet UITextView *descriptionText;
//@property (nonatomic,weak) IBOutlet UIButton *descriptionToggle;

// buttons panel
@property (nonatomic,weak) IBOutlet UIView *divider;

@property (nonatomic,weak) IBOutlet UIView *placeButtonsPanel;
@property (nonatomic,weak) IBOutlet UIButton *directionsButton;
@property (nonatomic,weak) IBOutlet UIButton *websiteButton;
@property (nonatomic,weak) IBOutlet UIButton *phoneButton;

@property (nonatomic,weak) IBOutlet UIView *tabsPanel;
@property (nonatomic,weak) IBOutlet UIButton *blipsTabButton;
@property (nonatomic,weak) IBOutlet UIButton *followingTabButton;
@property (nonatomic,weak) IBOutlet UIButton *followersTabButton;
@property (nonatomic,weak) IBOutlet UIImageView *tabIndicator;

// Methods
-(id)initWithChannel:(Channel *)channel initialTab:(ChannelDetailTab)tab menuButton:(BOOL)menuButton;
- (id)initWithChannel:(Channel *)channel menuButton:(BOOL)menuButton;
- (id)initWithChannel:(Channel *)channel;
-(id)initWithChannel:(Channel *)channel showBlip:(Blip *)blip;
- (void)configureWithChannel:(Channel *)channel;
-(void)setTab:(ChannelDetailTab)tab;
-(void)setHeaderLayout:(ChannelDetailHeaderLayout)layout animated:(BOOL)animated;
- (IBAction)descriptionTap:(id)sender;
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)swipe;
- (IBAction)tuneInAction:(id)sender;
- (IBAction)blacklistAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)directionsAction:(id)sender;
- (IBAction)showWebsite:(id)sender;
- (IBAction)editAction:(id)sender;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
