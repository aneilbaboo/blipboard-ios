//
//  BlipDetailView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 10/15/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Blip.h"
#import "PlaceChannel.h"
#import "BBImageView.h"
#import "BBLikeButton.h"
#import "BBTuneInButton.h"
#import "NIAttributedLabel.h"
#import "BBCountLabel.h"
#import "BBInfoText.h"
#import "BBCommentList.h"
#import "BBCommentButton.h"
#import "BBGenericButton.h"
#import "BBShareButton.h"
#import "SHKShareItemDelegate.h"
#import "SHKSharerDelegate.h"

typedef enum {
    BlipDetailLayoutHidden = 0,
    BlipDetailLayoutCompressed = 1,
    BlipDetailLayoutExpanded = 2
} BlipDetailLayout;

@class BlipDetailView;

@protocol BlipDetailViewDelegate <NSObject>
-(void)blipDetailView:(BlipDetailView *)blipDetailView channelPressed:(Channel *)channel;
-(void)blipDetailViewDidHide:(BlipDetailView *)blipDetailView;
@end

/** Contains information about selected blip
 *   - layout animates between hidden, compressed or expanded forms
 *   - several different UIViews, which unless otherwise noted are
 *       subviews of some external parent view
 *         * scrollView - contains most of the content
 *         * noteBar - displays notifications or place info
 *                     associated with the blip
 *         * actionPanel - comments & comment / like buttons
 *         * navBar - subView of navigationController's view
 */
@interface BlipDetailView : NSObject <UIScrollViewDelegate,UIActionSheetDelegate,SHKShareItemDelegate,SHKSharerDelegate, UITextFieldDelegate>

@property (nonatomic,weak)   Blip *blip;
@property (nonatomic,weak)   id<BlipDetailViewDelegate> delegate;
@property (nonatomic,strong) Channel *noTransitionChannel; // prevents the blipDetail from opening a channelDetailView controller for this channel
@property (nonatomic)        BOOL hidden;
@property (nonatomic,readonly) BOOL commentMode;
@property (nonatomic,strong) void (^cancelAction)();

// scrollable area:
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIImageView *backdrop;
@property (nonatomic,weak) IBOutlet UILabel *authorName;
@property (nonatomic,weak) IBOutlet BBImageView *authorPicture;
@property (nonatomic,weak) IBOutlet UIImageView *authorDisclosure;
@property (nonatomic,weak) IBOutlet UIButton *authorButton;
@property (nonatomic,weak) IBOutlet BBInfoText *time;

@property (nonatomic,weak) IBOutlet BBTuneInButton *tuneInButton;
@property (nonatomic,weak) IBOutlet UITextView *message;
@property (nonatomic,weak) IBOutlet BBImageView *blipPhoto;
@property (nonatomic,weak) IBOutlet UIButton *scrollViewDismissCommentButton;

// action panel (displays comments & likes)
@property (nonatomic,strong) IBOutlet UIView *actionPanel;
@property (nonatomic,weak) IBOutlet BBCommentList *commentListView;
@property (nonatomic,weak) IBOutlet BBLikeButton *likeButton;
@property (nonatomic,weak) IBOutlet BBCommentButton *commentButton;
@property (nonatomic,weak) IBOutlet UILabel *noCommentsLabel;
@property (nonatomic,weak) IBOutlet UIButton *actionPanelDismissCommentButton;
@property (nonatomic,weak) IBOutlet BBShareButton *shareButton;
@property (nonatomic,weak) IBOutlet UIView *actionButtonsBackdrop;

// comment bar (attaches above keyboard)
@property (nonatomic,strong) IBOutlet UIView *commentBar;
@property (nonatomic,weak) IBOutlet UITextField *commentField;
@property (nonatomic,weak) IBOutlet BBGenericButton *commentAddButton;

// navbar
@property (nonatomic,strong) IBOutlet UIView *navBar;
@property (nonatomic,weak) IBOutlet UILabel *navBarLabel;
@property (nonatomic) BOOL disableNavBar;

// noteBar
@property (nonatomic,strong) IBOutlet UIView *noteBar; // secondary info appears here
@property (nonatomic,weak) IBOutlet UILabel *noteBarLabel;

// IB actions
-(IBAction)tuneInPressed:(id)sender;
-(IBAction)likePressed:(id)sender;
-(IBAction)authorPressed:(id)sender;
-(IBAction)handleUpSwipe:(id)sender;
-(IBAction)handleDownSwipe:(id)sender;
-(IBAction)handleActionPanelTap:(UITapGestureRecognizer *)sender;
-(IBAction)handleBlipDetailTap:(UITapGestureRecognizer *)sender;
-(IBAction)noteBarPressed:(id)sender;
-(IBAction)navBarPressed:(id)sender;
-(IBAction)dismissCommentPressed:(id)sender;
-(IBAction)commentButtonPressed:(id)sender;
-(IBAction)commentAddButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)sharePressed:(id)sender;

// initialization:
+(id)blipDetailView;
-(void)addToViewController:(UIViewController *)controller;
-(void)removeFromViewController;
-(void)observeKeyboard;
-(void)unobserveKeyboard;
-(void)configureWithBlip:(Blip *)blip;
-(void)assignCancelActionToSlideoutMenu;
// layout
- (void)setLayout:(BlipDetailLayout)layout animated:(BOOL)animated;
- (void)setLayout:(BlipDetailLayout)layout animated:(BOOL)animated completion:(void (^)())completion;
- (BlipDetailLayout)layout;
- (BOOL)isCoveringParentView;


// methods and information
-(void)retractNavBar;
-(void)unretractNavBar;
-(UIView *)parentView;
@end
