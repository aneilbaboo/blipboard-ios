//
//  BlipDetailView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 10/15/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//


#import "BlipDetailView.h"
#import "BBCommentView.h"
#import "BlipPin.h"
#import "SlideoutViewController.h"
#import "SHK.h"
#import "SHKSharer.h"

static const NSInteger MessageWidth = 290;
static const NSInteger MessageHeightMax = 3000;
static const NSInteger PhotoHeight = 150;
static const NSInteger PhotoWidth = 320; 
static const NSInteger SmallPadding = 5;
static const NSInteger MediumPadding = 10;
static const NSInteger OutsidePadding = 15;
static const NSInteger CompressedElementYPos = 48;
static const NSInteger CompressedHeight = 118;
static const NSInteger CompressibleMinimumHeight = 250; // if < that this, show expanded only
static const NSInteger SnapToCloseThreshold = 35;
static const NSInteger BackdropBounceMargin = 1000;


@implementation BlipDetailView {
    BOOL _expanded;
    BlipDetailLayout _layout;
    __weak UIViewController *_viewController;
    Channel *_noteBarChannel; // channel the noteBar transitions to
    NSString *_noteBarReason;
    Channel *_navBarChannel;  // channel the navBar transitions to
    NSString *_navBarReason;
    CGFloat _keyboardHeight;
    BOOL _commentMode;
    CGFloat _actionPanelButtonsHeight;
    BOOL _keyboardObserved;
    SHKActionSheet *_sharePanel;
}

@dynamic hidden;

#pragma mark -
#pragma mark Initialization
+(id)blipDetailView {
    BlipDetailView *obj = [BlipDetailView new];
    [[NSBundle mainBundle] loadNibNamed:@"BlipDetailView" owner:obj options:nil];
    [obj _setupStyle];
    [obj setLayout:BlipDetailLayoutHidden animated:NO];

    return obj;
}

-(void)_setupStyle {
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.backdrop.backgroundColor = [UIColor bbPaperWhite];
    [self.backdrop bbSetShadow:BlipboardShadowOptionUp];
    self.authorName.textColor = [UIColor bbWarmGray];
    [self.authorName setFont:[UIFont bbBlipAuthorFont]];
    
    [self.message bbStyleAsBlip];
    [self.message setFont:[UIFont bbBlipMessageFont]];
    self.message.textAlignment = NSTextAlignmentLeft;
    self.message.contentInset = UIEdgeInsetsMake(0,0,0,0);
    self.message.contentOffset = CGPointMake(0,0);
 
    self.actionPanel.layer.cornerRadius = 6;
    self.actionPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.actionPanel.layer.shadowOffset = CGSizeMake(0, -3);
    self.actionPanel.layer.shadowOpacity = .4;
    self.actionPanel.layer.shadowRadius = 5;
    self.actionPanel.backgroundColor = [UIColor bbFadedWarmGray];
    self.actionButtonsBackdrop.backgroundColor = [UIColor bbWarmGray];
    [self.actionButtonsBackdrop roundCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                     xRadius:6 yRadius:6];

    self.noCommentsLabel.font = [UIFont bbFont:14];
    self.noCommentsLabel.textColor = [UIColor bbGray3];
    _actionPanelButtonsHeight = self.commentButton.bottom + SmallPadding;
    self.commentButton.countColor = [UIColor bbFadedWarmGray];
    self.likeButton.countColor = [UIColor bbFadedWarmGray];
    
    self.scrollViewDismissCommentButton.hidden = YES;
    self.actionPanelDismissCommentButton.hidden = YES;
    
    // navBar
    self.navBar.backgroundColor = [UIColor bbWarmGray];
    [self.navBar bbSetShadow:BlipboardShadowOptionDown];
    self.navBarLabel.textColor = [UIColor bbPaperWhite];
    [self.navBarLabel setFont:[UIFont bbCondensedBoldFont:19]];
    self.navBar.hidden = YES;
    
    // noteBar
    [self.noteBarLabel setFont:[UIFont bbBlipMessageFont]];
    
    // commentBar
    [self.commentBar bbStyleAsDarkBar];
    [self.commentAddButton.titleLabel setFont:[UIFont bbCondensedBoldFont:18]];
    [self.commentAddButton setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateNormal];
    [self.commentAddButton setTitleColor:[UIColor bbGray3] forState:UIControlStateSelected];
    
}

-(void)retractNavBar {
    [UIView animateWithDuration:.25
                     animations:^{
                         [self.navBar setTransformYTranslation:-self.navBar.height];
                     }
                     completion:^(BOOL finished) {
                         self.navBar.hidden = YES;
                     }];
}

-(void)unretractNavBar {
    self.navBar.hidden = self.disableNavBar;
    [UIView animateWithDuration:.25
                     animations:^{  [self.navBar setTransformYTranslation:0]; }];
}

-(void)addToViewController:(UIViewController *)controller {
    if (_viewController!=controller) {
        _viewController = controller;
        
        UIView *parent = controller.view;
        
        self.scrollView.scrollsToTop = NO;
        
        // add the three views in BlipDetailView to the parentView
        [parent addSubview:self.scrollView];
        
        // noteBar
        [parent insertSubview:self.noteBar belowSubview:self.scrollView];
        self.noteBar.ry = self.scrollView.ry - self.noteBar.height;
        
        
        // actionPanel
        [self.parentView insertSubview:self.actionPanel aboveSubview:self.scrollView];
        
        // commentBar
        [parent insertSubview:self.commentBar aboveSubview:self.commentListView];
        self.commentBar.ry = self.parentView.height;
        
        [self _setLayout:BlipDetailLayoutHidden];
        
        [controller.navigationController.view insertSubview:self.navBar atIndex:NSIntegerMax];
    }
}

-(void)removeFromViewController {
    if (_viewController) {
        [self.navBar removeFromSuperview];
        _viewController = nil;
        [self unobserveKeyboard];
    }
}

#pragma mark -
#pragma mark Observerss
-(void)observeKeyboard {
    BBTraceLevel(4);
    // register for keyboard notifications
    @synchronized(self) {
        if (!_keyboardObserved) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_keyboardWillShow:)
                                                         name:UIKeyboardWillShowNotification
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(_keyboardWillHide:)
                                                         name:UIKeyboardWillHideNotification
                                                       object:nil];
            _keyboardObserved = YES;
        }
    }
}

-(void)unobserveKeyboard {
    BBTraceLevel(4);
    @synchronized(self) {
        if (_keyboardObserved) {
            
            // unregister for keyboard notifications
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardWillShowNotification
                                                          object:nil];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIKeyboardWillHideNotification
                                                          object:nil];
            _keyboardObserved = NO;
        }
    }
}

-(void)setBlip:(Blip *)blip {
    if (_blip) {
        [_blip removePropertiesObserver:self];
    }
    [self willChangeValueForKey:@"blip"];
    _blip = blip;
    [self didChangeValueForKey:@"blip"];
    if (blip) {
        [blip addPropertiesObserver:self];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object==self.blip) {
        [self configureWithBlip:object];
    } else if (object==self.blip.author) {
        [self _configureWithAuthor:object];
    }
    else if (object==self.blip.likes) {
        [self _configureActionPanel];
    }
    else if (object==self.blip.comments) {
        [self _configureActionPanel];
    }
}

-(void)dealloc {
    // !am! we should remove both of these if we fail to trigger the asserts
    //      in Alpha/Beta
#if defined CONFIGURATION_Release
    // !am! kludge: just in case removeFromViewController doesn't get called
    [self unobserveKeyboard];
#else
    // catch this bad case:
    // _keyboardObserved must be nil when dealloc is called on blip detail
    BBLogLevel(4,@"_keyboardObserved=%d",_keyboardObserved);
    assert(!_keyboardObserved);
#endif
    self.blip = nil; // remove observers
}

#pragma mark -
#pragma mark Flurry helpers
// collect & report standard info about the blip

- (NSMutableDictionary *)_flurryParams {
    return [self _flurryParams:nil];
}

- (NSMutableDictionary *)_flurryParams:(NSDictionary *)extraParams {
    return [self _flurryParams:extraParams withError:nil];
}

- (NSMutableDictionary *)_flurryParams:(NSDictionary *)extraParams withError:(ServerModelError *)error {
    NSInteger hours = -[self.blip.createdTime timeIntervalSinceNow]/(60.*60.);
    NSString *placeAuthorCategory = self.blip.author.type==ChannelTypePlace ?
    [(PlaceChannel *)self.blip.author category] : nil;
    NSString *hasPhoto = (self.blip.photo && self.blip.photo.length>0) ? @"YES" : @"NO";
    NSString *hasSourcePhoto = (self.blip.sourcePhoto && self.blip.sourcePhoto.length>0) ? @"YES" : @"NO";
    NSMutableDictionary *dict = [Flurry paramsWithError:error,
                                 @"author",                 self.blip.author.id,
                                 @"authorType",             self.blip.author._typeString,
                                 @"placeAuthorCategory",    placeAuthorCategory,
                                 @"place",                  self.blip.place.id,
                                 @"blip",                   self.blip.id,
                                 @"hasPhoto",               hasPhoto,
                                 @"hasSourcePhoto",         hasSourcePhoto,
                                 @"likes",                  self.blip.likes._likeCount.stringValue,
                                 @"followers",              self.blip.author.stats._followers.stringValue,
                                 @"blipAgeHours",           @(hours).stringValue,
                                 nil];
    
    if (extraParams) {
        [dict addEntriesFromDictionary:extraParams];
    }
    return dict;
}

#pragma mark -
#pragma mark Actions
-(IBAction)cancelButtonPressed:(id)sender {
    if (self.cancelAction) {
        self.cancelAction();
    }
    else {
        [self setLayout:BlipDetailLayoutHidden animated:YES];
    }
}

/** Initiate commenting
 */
-(IBAction)commentButtonPressed:(id)sender {
    BBTrace();    
    [self setCommentMode:!_commentMode animated:YES];
}

-(IBAction)commentAddButtonPressed:(id)sender {
    BBTrace();
    UIView *hudParentView = _viewController.navigationController.view;
    [BBProgressHUD showHUDAddedTo:hudParentView animated:YES];
    [self.blip addComment:self.commentField.text
                    block:^(Blip *blip, ServerModelError *error) {
                            [Flurry logEvent:kFlurryBlipDetailComment
                                       withParameters:[self _flurryParams:nil withError:error]];
                        [BBProgressHUD hideAllHUDsForView:hudParentView animated:YES];
                        if (error) {
                            RIButtonItem *ok = [RIButtonItem item];
                            ok.label = @"OK";
                            ok.action = ^{}; // no-op block
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to post your comment" cancelButtonItem:ok otherButtonItems:nil];
                            [alertView show];
                        }
                        else {
                            self.blip = blip;
                            [self configureWithBlip:blip];
                            [self setCommentMode:FALSE animated:YES];
                        }
                    }];
}

-(IBAction)sharePressed:(id)sender {
    BBTrace();
    NSURL *url = [NSURL URLWithString:self.blip.link];
    SHKItem *item = [SHKItem URL:url title:self.blip.message contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
	_sharePanel = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[_sharePanel showInView:self.parentView];
    
    _sharePanel.shareDelegate = self;

}

-(IBAction)dismissCommentPressed:(id)sender {
    BBTrace();    
    _commentMode = NO;
    [self setLayout:_layout animated:YES];
}

- (IBAction)authorPressed:(id)sender {
    BBTrace();
    [Flurry logEvent:kFlurryBlipDetailAuthor];
    if ([self allowTransitionToAuthor]) {
        [self.delegate blipDetailView:self channelPressed:self.blip.author];
    }
}

- (IBAction)tuneInPressed:(UIButton *)button {
    BBTrace();
    
    [[BBRemoteNotificationManager sharedManager] promptUserToEnablePushNotificationsIfNeeded];
    
    if (self.tuneInButton.selected) {
        [Flurry logEvent:kFlurryBlipDetailUnfollow
                   withParameters:[self _flurryParams]];
        
        [self.blip.author tuneOut:^(Channel *channel, ServerModelError *error) {}];
        
    }
    else {
        [Flurry logEvent:kFlurryBlipDetailFollow
                   withParameters:[self _flurryParams]];
        
        [self.blip.author tuneIn:^(Channel *channel, ServerModelError *error) {}];
    }
}


- (IBAction)navBarPressed:(id)sender {
    if (_navBarChannel && _navBarReason) {
            BBTrace();
        [Flurry logEvent:kFlurryBlipDetailNavBar
                   withParameters:[self _flurryParams:
                                   @{
                                   @"channelId":_navBarChannel.id,
                                   @"cause":[NSString stringWithFormat:_navBarReason,_navBarChannel._typeString]}]];
     
     

        [self.delegate blipDetailView:self channelPressed:_navBarChannel];
    }
}

-(IBAction)noteBarPressed:(id)sender {
    if (_noteBarChannel && _noteBarReason) {
        BBTrace();
        [Flurry logEvent:kFlurryBlipDetailNoteBar
                   withParameters:[self _flurryParams:
                                   @{
                                   @"channelId":_noteBarChannel.id,
                                   @"cause":[NSString stringWithFormat:_noteBarReason,_noteBarChannel._typeString]}]];
        [self.delegate blipDetailView:self channelPressed:_noteBarChannel];
    }
}

-(IBAction)handleActionPanelTap:(UITapGestureRecognizer *)tap {
    BBTrace();    
    // ensure we scoll actionPanel into view:
    __unsafe_unretained BlipDetailView *Self = self;
    [self setLayout:BlipDetailLayoutExpanded animated:YES completion:^{
        CGFloat actionPanelBottom = Self.blipPhoto.bottom +
        Self->_actionPanelButtonsHeight;
        CGRect actionPanelEnd = CGRectMake(0, actionPanelBottom, 320, actionPanelBottom);
        [Self.scrollView scrollRectToVisible:actionPanelEnd animated:YES];
    }];
}

-(IBAction)handleBlipDetailTap:(UITapGestureRecognizer *)tap {
    [Flurry logEvent:kFlurryBlipDetailTap
               withParameters:[self _flurryParams:@{@"sender-class":[tap.view class]}]];
    BBLogLevel(4,@"setLayout:BlipDetailLayoutExpanded");

    [self setLayout:BlipDetailLayoutExpanded animated:YES];
}

-(IBAction)handleUpSwipe:(id)sender {
    [Flurry logEvent:kFlurryBlipDetailUpswipe
               withParameters:[self _flurryParams:@{@"sender-class":NSStringFromClass([sender class])}]];
    if (self.layout == BlipDetailLayoutExpanded &&
        ![self isCoveringParentView]) {
        // user is swiping up blip detail that isn't covering the parent view, but it's already fully expanded
        [self _bigFailToExpandAnimation];
        
    }
    else {
        [self setLayout:BlipDetailLayoutExpanded animated:YES];
    }

}

-(IBAction)handleDownSwipe:(id)sender {
    BBTrace();    
    [Flurry logEvent:kFlurryBlipDetailDownswipe
               withParameters:[self _flurryParams:@{@"sender-class":NSStringFromClass([sender class])}]];
    
    if (_layout == BlipDetailLayoutCompressed || ![self isCompressible]) {
        [self setLayout:BlipDetailLayoutHidden animated:YES];
    }
    else if (_layout == BlipDetailLayoutExpanded ) {
        [self setLayout:BlipDetailLayoutCompressed animated:YES];
    }
}


-(IBAction)likePressed:(id)sender {
    BBTrace();    
    BOOL isLiker = self.blip.likes.isLiker;
    __weak BlipDetailView *weakSelf = self;
    if (isLiker) {
        self.likeButton.selected = NO;
        [self.blip unlike:^(Blip *blip, ServerModelError *error) {
            weakSelf.blip = blip;
            [weakSelf.likeButton configureWithLikes:blip.likes];
            [Flurry logEvent:kFlurryBlipDetailUnlike
                       withParameters:[self _flurryParams:@{@"sender-class":NSStringFromClass([sender class])}
                                                withError:error]];
        }];
    }
    else {
        self.likeButton.selected = YES;
        [self.blip like:^(Blip *blip, ServerModelError *error) {
            weakSelf.blip = blip;
            [weakSelf.likeButton configureWithLikes:blip.likes];
            [Flurry logEvent:kFlurryBlipDetailLike
                       withParameters:[self _flurryParams:@{@"sender-class":NSStringFromClass([sender class])}
                                                withError:error]];
        }];
    }
}

#pragma mark -
#pragma mark Layout
- (BlipDetailLayout)layout {
    return _layout;
}

- (BOOL)isCompressible {
    return _scrollView.contentSize.height > CompressibleMinimumHeight;
}

- (BOOL)isCoveringParentView {
    return (self.scrollView.ry == 0);
}

- (void)setLayout:(BlipDetailLayout)layout animated:(BOOL)animated {
    [self setLayout:layout animated:animated completion:nil];
}

- (void)setLayout:(BlipDetailLayout)newLayout animated:(BOOL)animated completion:(void (^)())completion {

    self.hidden = NO;
    if (![self isCompressible] &&
        newLayout==BlipDetailLayoutCompressed) {
        newLayout = BlipDetailLayoutExpanded;
    }
    
    if (newLayout==BlipDetailLayoutHidden) {
        self.cancelAction = nil;
    }
    
    NSTimeInterval interval = animated ? .25 : 0;
    __block BlipDetailView *blockSelf = self;
    
    [UIView animateWithDuration:interval animations:^{
        [self _setLayout:newLayout];
    } completion:^(BOOL finished) {
        // after animating, hide the navBar
        self.navBar.hidden =    self.disableNavBar ||
                                newLayout==BlipDetailLayoutHidden ||
                                ![self allowTransitionToPlace];
        if (completion) {
            completion();
        }
        if (blockSelf.layout==BlipDetailLayoutHidden) {
            blockSelf.hidden =YES;
            [blockSelf.delegate blipDetailViewDidHide:self];
        }
    }];
}

- (BOOL)hidden {
    return (self.scrollView.hidden && self.actionPanel.hidden && self.navBar.hidden && self.noteBar.hidden);
}

- (void)setHidden:(BOOL)hidden {
    self.scrollView.hidden = hidden;
    self.actionPanel.hidden = hidden;
    self.navBar.hidden = self.disableNavBar | hidden;
    self.commentBar.hidden = hidden; 
    self.noteBar.hidden = hidden;
}

- (BOOL)commentMode {
    return _commentMode;
}

- (void)setCommentMode:(BOOL)commentMode animated:(BOOL)animated {
    _commentMode = commentMode;
    [self setLayout:BlipDetailLayoutExpanded animated:YES];
}

-(void)assignCancelActionToSlideoutMenu {
    [self setCancelAction:^{
        [[SlideoutViewController sharedController] revealMenu];
    }];
}

- (void)_setLayout:(BlipDetailLayout)layout {
    BBLog(@"layout:%d",layout);

    _layout = layout;
    // comment view horizontal controls layout

    // hide the navBar if layout is Hidden mode
    // or if we should not allow a transition to the place channel
    // (which is shown in the navBar)
    if (layout==BlipDetailLayoutHidden ||
        ![self allowTransitionToPlace]) {
        self.navBar.ry = -self.navBar.height;
        self.navBar.alpha = 0;
    }
    else {
        self.navBar.ry = _viewController.navigationController.navigationBar.ry;
        self.navBar.alpha = 1;
    }

    switch (layout) {
        case BlipDetailLayoutHidden:
            self.scrollView.contentOffset = CGPointZero;
            self.scrollView.ry = self.parentView.bottom;
            self.scrollView.scrollEnabled = NO;
            _commentMode = NO;
            break;

        case BlipDetailLayoutCompressed:
            self.scrollView.contentOffset = CGPointZero;
            if (_commentMode) {
                self.scrollView.height = self.parentView.height - _keyboardHeight - self.commentBar.height;
                self.scrollView.ry = self.parentView.height - _keyboardHeight - self.commentBar.height - CompressedHeight;
            }
            else {
                self.scrollView.ry = MAX(self.parentView.height - self.blipPhoto.bottom
                                        - MediumPadding - _actionPanelButtonsHeight,
                                         self.parentView.height - CompressedHeight - _actionPanelButtonsHeight);
                self.actionPanel.ry = self.parentView.height - _actionPanelButtonsHeight; // action bar buttons only visible
            }
            self.scrollView.scrollEnabled = NO;
            break;
            
        case BlipDetailLayoutExpanded:
        {
            CGFloat contentYOrigin = self.parentView.height - self.scrollView.contentSize.height;

            if (_commentMode) {
                // offset content above keyboard and commentBar
                contentYOrigin -= _keyboardHeight + self.commentBar.height;
            }
            
            // NB: contentYOrigin could be negative, indicating that content must be scrolled to see it all.
            self.scrollView.frame = CGRectMake(0, MAX(contentYOrigin,0),
                                               self.parentView.width,
                                               self.parentView.height);

            self.scrollView.scrollEnabled = (self.scrollView.ry==0);
        }
            break;
            
    }
    
    // layout associated views
    [self _layoutNoteBar];
    [self _layoutActionPanel];
    [self _layoutCommentBar];

    // !am! hack to work around UITextView in UIScrollView iOS problem
    // see http://stackoverflow.com/questions/133243/text-from-uitextview-does-not-display-in-uiscrollview
    self.message.contentOffset = CGPointMake(0, 1);
    self.message.contentOffset = CGPointMake(0, 0);
}

-(void)_layoutCommentBar {
    // layout for comment mode
    if (_commentMode) {
        self.scrollViewDismissCommentButton.hidden = NO;
        self.actionPanelDismissCommentButton.hidden = NO;
        
        self.scrollViewDismissCommentButton.ry = 0;
        self.scrollViewDismissCommentButton.height = self.scrollView.contentSize.height+_keyboardHeight+self.commentBar.height;
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, _keyboardHeight+self.commentBar.height, 0);
        self.commentBar.ry = self.parentView.height - _keyboardHeight - self.commentBar.height;
        [self.commentField becomeFirstResponder];
    }
    else {
        self.commentField.text = @"";
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, MediumPadding, 0);
        // hide comment bar out of view
        self.commentBar.ry = self.parentView.height;
        self.scrollViewDismissCommentButton.hidden = YES;
        self.actionPanelDismissCommentButton.hidden = YES;
        [self.commentField resignFirstResponder];

    }
}

-(void)_layoutNoteBar {
    BOOL showNoteBar =  !_commentMode &&
                        !_layout==BlipDetailLayoutHidden &&
                        (self.scrollView.ry>=self.noteBar.height);
    
    if (showNoteBar) {
        // if the detail is not fully expanded, position the noteBar above
        // the scrollView, so it just abuts the backdrop
        
        self.noteBar.ry = self.scrollView.ry - self.noteBar.height + self.backdrop.ry;
    }
    else {
        // position below the parentView,
        // so even if .hidden = NO, it will not be visible
        self.noteBar.ry = self.parentView.height;
    }
}

// positions & styles the action panel relative to the blip detail
-(void)_layoutActionPanel {
    CGFloat blipPhotoBottom = [self.parentView convertPoint:CGPointMake(0,self.blipPhoto.bottom) fromView:self.scrollView].y;
    CGFloat panelButtonsTop = self.parentView.height -_actionPanelButtonsHeight;
    if (_layout == BlipDetailLayoutHidden) {
        self.actionPanel.ry = self.parentView.height;
    }
    else {
        if (blipPhotoBottom < panelButtonsTop) {
            // simulate that actionpanel is embedded in the scrollView
            self.actionPanel.ry = blipPhotoBottom;
            // !am! shadow color is used to determine actionPanelIsFloating
            self.actionPanel.layer.shadowColor = [UIColor clearColor].CGColor;
        }
        else {
            // action panel floats above scrollview (show a shadow)
            self.actionPanel.ry = self.parentView.height - _actionPanelButtonsHeight;
            // !am! shadow color is used to determine actionPanelIsFloating
            self.actionPanel.layer.shadowColor = [UIColor blackColor].CGColor;
        }
    }
}

-(BOOL)actionPanelIsEmbedded {
    return self.actionPanel.layer.shadowColor == [UIColor clearColor].CGColor;
}

#pragma mark -
#pragma mark Configuration
- (BOOL)allowTransitionToAuthor {
    return ![self.noTransitionChannel.id isEqualToString:self.blip.author.id];
}

- (BOOL)allowTransitionToPlace {
    return ![self.noTransitionChannel.id isEqualToString:self.blip.place.id];
}

- (void)configureWithBlip:(Blip *)blip {
    BBLog(@"blip:%@",blip);
    self.blip = blip;

    if (blip.recentCommentId) {
        // someone commented on the blip
        Comment *comment;
        for (comment in blip.comments) {
            if ([comment.id isEqualToString:blip.recentCommentId]) {
                [self _configureNoteBar:@"%@ added a comment"
                                channel:blip.author
                                   font:[UIFont bbBlipMessageFont]
                                  color:[UIColor bbNotificationBarColor]];
                
                [self _configureNavBar:@"@ %@" channel:blip.place];
            }
        }
    }
    else if (blip.recentLiker) {
        // when there's a liker, use the notebar for the liker, and the navBar for the place
        [self _configureNoteBar:@"%@ likes your blip"
                        channel:blip.recentLiker
                           font:[UIFont bbBlipMessageFont]
                          color:[[UIColor bbDarkOrange] colorWithAlphaComponent:.8]];

        [self _configureNavBar:@"@ %@" channel:blip.place];
    }
    else {
        // if the author and place aren't the same, show the place in the notebar, author in the navBar
        if (![blip.author.id isEqualToString:blip.place.id]) {
            [self _configureNoteBar:@"@ %@"
                            channel:blip.place
                               font:[UIFont bbFont:16]
                              color:[[UIColor bbWarmGray] colorWithAlphaComponent:.8]];
            [self _configureNavBar:@"%@" channel:blip.author];
        }
        // otherwise, author is a place, so show the place transition in the navBar
        else {
            [self _configureNoteBar:nil channel:nil font:nil color:nil]; // no note bar
            [self _configureNavBar:@"%@" channel:blip.place];
        }
    }
    
    // configure comment view:
    self.commentField.text = @"";
    
    [self _configureWithAuthor:blip.author];
    
    [self.time configureWithTime:blip.createdTime];
    // if user = author of blip, do not allow TuneIn!
    self.tuneInButton.hidden = ([BBAppDelegate.sharedDelegate.myAccount.id isEqualToString:blip.author.id]);
    
    // setup scrollView content area
    self.scrollView.contentOffset = CGPointZero;
    self.scrollView.contentSize = CGSizeMake(self.parentView.width, self.message.bottom);
    
    // each of these configuration blocks increments the scrollView.contentSize:
    [self _configureMessage];
    [self _configurePhoto];
    [self _configureActionPanel];
    
    self.backdrop.height = self.scrollView.contentSize.height+BackdropBounceMargin;
    
//    _forceContentBounce = YES;
    
    [self _tuneInButtonAnimation:!blip.author.isListening];
}

- (void)_configureWithAuthor:(Channel *)author {
    BBTraceLevel(4);
    assert (author.picture != NULL);
    self.authorName.text = author.name;
    //self.authorDescription.text = blip.author.desc;
    [self.authorPicture setImageWithURLString:author.picture placeholderImage:NULL];
    self.tuneInButton.selected = author.isListening;
    self.authorDisclosure.hidden = ![self allowTransitionToAuthor];
}
- (void)_configureNavBar:(NSString *)format channel:(Channel *)channel {
    BBTraceLevel(4);
    _navBarReason = format;
    _navBarChannel = channel;
    if (_navBarReason && _navBarChannel) {
        _navBarLabel.text = [NSString stringWithFormat:format, channel.name];
        //CGFloat labelWidth = [_navBarLabel sizeThatFits:_navBarLabel.size].width;
        //_navBarDisclosure.rx = labelWidth + _navBarLabel.rx + 10;
        _navBar.hidden = self.disableNavBar;
    }
    else {
        _navBar.hidden = YES;
    }
    
}

- (void)_configureNoteBar:(NSString *)format channel:(Channel *)channel font:(UIFont *)font color:(UIColor *)color {
    BBTraceLevel(4);
    _noteBarReason = format;
    _noteBarChannel= channel;
    _noteBar.backgroundColor = color;
    _noteBarLabel.font = font;
    if (channel && format) {
        _noteBarLabel.text = [NSString stringWithFormat:format, channel.name];
        _noteBar.hidden = NO;
        _noteBarLabel.hidden = NO;
    }
    else {
        _noteBar.hidden = YES;
        _noteBarLabel.hidden = YES;
    }
}

- (void)_configureMessage {
    BBTraceLevel(4);
    // ADD message
    self.message.text = self.blip.message;
    self.message.height = [self heightOfText];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                             self.message.bottom);
    
}


- (void)_configurePhoto {
    BBTraceLevel(4);
    Blip *blip = self.blip;
    
    if (blip.sourcePhoto) {
        [self.blipPhoto setImageWithURLString:blip.sourcePhoto placeholderImage:NULL];
    }
    else if (blip.photo) {
        [self.blipPhoto setImageWithURLString:blip.photo placeholderImage:NULL];
    }
    
    CGFloat adjustedPhotoHeight = 0;
    CGFloat photoStart = self.scrollView.contentSize.height + SmallPadding;
    
    self.blipPhoto.ry = photoStart;
    
    if (blip.sourcePhoto) {
        // photo with known dimensions:
        self.blipPhoto.hidden = FALSE;
        
        if (blip.sourceHeight && blip.sourceWidth) {
            self.blipPhoto.contentMode = UIViewContentModeScaleAspectFit;
            adjustedPhotoHeight = PhotoWidth * blip.sourceHeight / blip.sourceWidth;
            self.blipPhoto.height = adjustedPhotoHeight;
        }
        else {
            self.blipPhoto.contentMode = UIViewContentModeScaleAspectFill;
            self.blipPhoto.clipsToBounds = YES;
        }
        
        
    }
    else if (blip.photo) {
        // photo unknown dimensions:
        self.blipPhoto.hidden = FALSE;
        adjustedPhotoHeight = PhotoHeight;
        self.blipPhoto.height = adjustedPhotoHeight;
        
        self.blipPhoto.contentMode = UIViewContentModeScaleAspectFill;
        self.blipPhoto.clipsToBounds = YES;
    }
    else {
        // no photo:
        self.blipPhoto.hidden = YES;
        self.blipPhoto.height = 0;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,self.blipPhoto.bottom);
}

- (void)_configureActionPanel {
    BBTraceLevel(4);
    self.actionPanel.rx = 15;

    [self.likeButton configureWithLikes:self.blip.likes];
    
    self.commentButton.count = self.blip.comments.count;
    if (self.blip.comments.count) {
        self.noCommentsLabel.hidden = YES;
        self.commentListView.hidden = NO;
        self.commentListView.comments = self.blip.comments;
        self.actionPanel.height = self.commentListView.bottom +MediumPadding;
    }
    else {
        self.commentListView.hidden = YES;
        self.noCommentsLabel.hidden = NO;
        self.actionPanel.height = self.noCommentsLabel.bottom + MediumPadding;
    }
    self.actionPanelDismissCommentButton.height = self.actionPanel.height;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                             self.scrollView.contentSize.height
                                             + self.actionPanel.height
                                             + MediumPadding);
    
    self.shareButton.hidden = BBAppDelegate.sharedDelegate.myAccount.capabilities.disableSharing;
}


-(CGFloat)heightOfText
{
    NSString *text = self.message.text;
    NSString* message = text.length ? text : @" ";
    UIFont* font = [UIFont bbBlipMessageFont];
    CGSize constrainedSize = CGSizeMake(MessageWidth, MessageHeightMax);
    CGSize messageSize = [message sizeWithFont:font
                             constrainedToSize:constrainedSize
                                 lineBreakMode:UILineBreakModeWordWrap];
    return messageSize.height + 10;
}

-(UIView *)parentView {
    return _viewController.view;
}

#pragma mark -
#pragma mark Animations
/** When user tries to expand a fully expanded blip detail
 */
- (void)_bigFailToExpandAnimation {
    [self _detailBounceAnimationWithDuration:2 height:100 bounces:4];
}

- (void)_smallFailToExpandAnimation {
    [self _detailBounceAnimationWithDuration:.75 height:20 bounces:3];
}

- (void)_detailBounceAnimationWithDuration:(NSTimeInterval)duration height:(CGFloat)displacement bounces:(NSInteger)bounces  {
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    displacement = -abs(displacement);
    NSMutableArray *bounceValues = [NSMutableArray arrayWithCapacity:bounces+1];
    NSNumber *zeroDisplacement = [NSNumber numberWithFloat:0];
    [bounceValues setObject:zeroDisplacement atIndexedSubscript:0];
    for (NSInteger i=0;i<bounces; i++) {
        [bounceValues setObject:[NSNumber numberWithFloat:displacement/pow(i+1,3)]
             atIndexedSubscript:1+i*2];
        [bounceValues setObject:zeroDisplacement
             atIndexedSubscript:2+i*2];
    }
    bounceAnimation.values = bounceValues;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    bounceAnimation.duration = duration;
    bounceAnimation.removedOnCompletion = NO;
    [_scrollView.layer addAnimation:bounceAnimation forKey:@"bounce"];
    [_noteBar.layer addAnimation:bounceAnimation forKey:@"bounce"];
    if ([self actionPanelIsEmbedded]) {
        [self.actionPanel.layer addAnimation:bounceAnimation forKey:@"bounce"];
    }
}

-(void)_tuneInButtonAnimation:(BOOL)enable {
    if (enable) {
        self.tuneInButton.transform = CGAffineTransformMakeScale(.7, .7);
        self.tuneInButton.alpha = 0;
        [UIView animateWithDuration:.1
                              delay:.5
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             _tuneInButton.transform = CGAffineTransformIdentity;
                             _tuneInButton.alpha = 1;
                         }
                         completion:nil];
    }
}

- (void)_keyboardWillShow:(NSNotification *)notification {
    BBTrace();
    if ([self.commentField isFirstResponder]) {
        [Flurry logEvent:kFlurryBlipDetailCommentStart
                   withParameters:[self _flurryParams]];
        
        
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        _keyboardHeight = kbSize.height;
        [self setLayout:_layout animated:YES];
    }
}

- (void)_keyboardWillHide:(NSNotification *)notification {
    BBTrace();
    if (_commentMode) {
        [self setLayout:_layout animated:YES];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y<-SnapToCloseThreshold &&
        _layout == BlipDetailLayoutExpanded) {
        [self setLayout:BlipDetailLayoutCompressed animated:YES];
    }
    [self _layoutActionPanel];
}

#pragma mark -
#pragma mark SHKShareItemDelegate
-(BOOL)aboutToShareItem:(SHKItem *)item withSharer:(SHKSharer *)sharer {
    [Flurry logEvent:kFlurryBlipDetailSharingStart
      withParameters:[self _flurryParams:@{@"sharer":sharer.sharerTitle}]];
    sharer.shareDelegate = self;
    return YES;
}

#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField==self.commentField) {
        self.commentAddButton.enabled = (range.length<textField.text.length ||
                                         string.length>0);
    }
    return YES;
}

#pragma mark -
#pragma mark SHKSharerDelegate
-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin {
    [Flurry logEvent:kFlurryBlipDetailSharingAbort
      withParameters:[Flurry paramsWithError:error
                                 extraParams:[self _flurryParams:@{
                                              @"sharer":sharer.sharerTitle,
                                              @"reason":@"failed-with-error"
                                              }]]];
    sharer.delegate = nil;
}

-(void)sharerStartedSending:(SHKSharer *)sharer {
    
}

-(void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success {
    
}

-(void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer {
    [Flurry logEvent:kFlurryBlipDetailSharingAbort
      withParameters:[self _flurryParams:@{
                      @"sharer":sharer.sharerTitle,
                      @"reason":@"bad-credentials"}]];
}

-(void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer {
    [Flurry logEvent:kFlurryBlipDetailSharingAbort
      withParameters:[self _flurryParams:@{
                      @"sharer":sharer.sharerTitle,
                      @"reason":@"auth-error"}]];
    sharer.delegate = nil;
}

-(void)sharerCancelledSending:(SHKSharer *)sharer {
    [Flurry logEvent:kFlurryBlipDetailSharingAbort
      withParameters:[self _flurryParams:@{
                      @"sharer":sharer.sharerTitle,
                      @"reason":@"user-cancelled"}]];
    sharer.delegate = nil;
}

-(void)sharerFinishedSending:(SHKSharer *)sharer {
    [Flurry logEvent:kFlurryBlipDetailSharingComplete
      withParameters:[self _flurryParams]];
    sharer.delegate = nil;
}

@end
