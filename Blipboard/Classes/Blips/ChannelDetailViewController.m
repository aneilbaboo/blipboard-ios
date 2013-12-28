//
//  ChannelDetailViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Heatmaps/Heatmaps.h>

#import "BBBackBarButtonItem.h"
#import "ChannelDetailViewController.h"
#import "BBTableProtocol.h"
#import "ProfileEditorViewController.h"
#import "ChannelDescriptionViewController.h"

const CGFloat kHeaderMinHeight=35+75; // !am! minHeader + tabButtonPanel heights
const CGFloat kDescriptionCollapsedHeight=70;

@implementation ChannelDetailViewController {
    Blip *_ensureBlip;
    CGFloat _headerMaxHeight; // used when scrolling
    BOOL _observerInstalled;
    BOOL _showMenuButton;
    ChannelDetailTab _initialTab;
}
@dynamic isUserAccount;

-(id)initWithChannel:(Channel *)channel showBlip:(Blip *)blip {
    BBTrace();
    self = [self initWithChannel:channel];
    _ensureBlip = blip;

    return self;
}

-(id)initWithChannel:(Channel *)channel {
    return [self initWithChannel:channel menuButton:NO];
}

-(id)initWithChannel:(Channel *)channel menuButton:(BOOL)menuButton {
    return [self initWithChannel:channel
                      initialTab:ChannelDetailTabBlips
                      menuButton:menuButton];
}

-(id)initWithChannel:(Channel *)channel initialTab:(ChannelDetailTab)tab menuButton:(BOOL)menuButton {
    BBLog(@"%@",channel);
    self = [super init];
    
    self.channel = channel;
    _showMenuButton = menuButton;
    _initialTab = tab;
    return self;
}

- (void)setChannel:(Channel *)channel {
    if (_channel) {
        [_channel removePropertiesObserver:self];
    }
    [self willChangeValueForKey:@"channel"];
    _channel = channel;
    [self didChangeValueForKey:@"channel"];
    if (channel) {
        [channel addPropertiesObserver:self];
    }
}

-(void)dealloc {
    self.channel = nil; // remove observers
}

- (void)configureWithChannel:(Channel *)channel {
    BBTraceLevel(4);
    self.channel = channel;
    
    self.descriptionText.scrollsToTop = NO;

    self.blipDetailView.disableNavBar = YES;
    
    BOOL isUser = channel.type==ChannelTypeUser;
    self.directionsButton.hidden = isUser;
    self.websiteButton.hidden = isUser;
    self.phoneButton.hidden = isUser;

    // hide tuneIn if I'm looking at my own channel
    BOOL isCurrentUser = [channel.id isEqualToString:BBAppDelegate.sharedDelegate.myAccount.id];
    self.tuneInButton.hidden =isCurrentUser;
    self.tuneInButton.selected = channel.isListening;
    
    self.editButton.hidden = !isCurrentUser;
    [self.editButton.titleLabel setFont:[UIFont bbBoldFont:18]];
    [self.editButton setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateHighlighted];
    
    self.guruScore.singular = @"guru point";
    self.guruScore.plural = @"guru points";
    self.guruScore.count = channel.stats.score;
    self.guruScore.hidden = (channel.type==ChannelTypePlace);
    
    if (channel.isBlacklistable) {
        self.blacklistButton.enabled = TRUE;
        self.blacklistButton.hidden = FALSE;
    }
    else {
        self.blacklistButton.enabled = FALSE;
        self.blacklistButton.hidden = TRUE;
    }
    self.header.height = self.minimalHeader.height;
    
    // setup the description
    [self _configureDescription:[channel.desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
 
    // setup tabs panel
    [self.header extendBottomWithSubview:self.tabsPanel aboveSubview:self.minimalHeader];
    
    // extra elements - dividers, etc.
    [self.header extendBottomWithSubview:self.headerBottomLine];
    [self.view addSubview:self.tabIndicator];
    self.tabIndicator.ry = self.header.bottom;
    [self scrollViewDidScroll:self.tabScroll];
    _headerMaxHeight = self.header.height;
    
    [self alignTablesWithHeader];
    [self layoutHeaderWithHeight:self.header.height];
}

-(void)_configureDescription:(NSString *)description {
    BBTraceLevel(4);
    //self.channel.desc = description;
    if (description.length > 120) {
        NSString *description120 = [description substringToIndex:120];
        NSRange range = [description120 rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]
                                                        options:NSBackwardsSearch];

        self.descriptionText.text = [NSString stringWithFormat:@"%@...", [description substringToIndex:range.location]];
    }
    else {
        self.descriptionText.text = description;
    }

    // nag user to fill in their bio:
    if (description.length==0 && self.isUserAccount) {
        self.descriptionText.text = @"(Your profile is incomplete)";
        self.descriptionText.textColor = [UIColor bbGray3];
    }
    else {
        self.descriptionText.textColor = [UIColor bbWarmGray];
    }
    
    if (self.descriptionText.text.length>0) {
        CGSize descSize = [self.descriptionText sizeThatFits:CGSizeMake(self.descriptionText.width, kDescriptionCollapsedHeight)];

        self.descriptionText.size = descSize;
        self.descriptionText.hidden = NO;
        [self.header extendBottomWithSubview:self.descriptionText belowSubview:self.minimalHeader];
        
    }
    else {
        self.descriptionText.height = 0;
//        self.descriptionToggle.hidden = YES;
    }

}

-(void)configurePlaceButtonsPanel {
    BBTraceLevel(4);
    [self.placeButtonsPanel bbSetShadow:BlipboardShadowOptionUp];
    if (self.channel.type==ChannelTypePlace) {
        PlaceChannel *place = (PlaceChannel *)self.channel;
        
        [self _configurePlaceButton:self.phoneButton enable:place.canCallPhone];
        [self _configurePlaceButton:self.directionsButton enable:place.hasDirections];
        [self _configurePlaceButton:self.websiteButton enable:place.hasWebsite];
        
        self.placeButtonsPanel.hidden = NO;
        
        [self.view insertSubview:self.placeButtonsPanel aboveSubview:self.header];
        self.placeButtonsPanel.ry = self.view.height - self.placeButtonsPanel.height;
    }
    else {
        self.placeButtonsPanel.hidden = YES;
    }

}

//
-(void)configureTabs {
    BBTraceLevel(4);
    // 3 lists on a scrollview
    self.tabScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.tabScroll.showsHorizontalScrollIndicator = NO;
    self.tabScroll.showsVerticalScrollIndicator = NO;
    self.tabScroll.alwaysBounceHorizontal = NO;
    self.tabScroll.alwaysBounceVertical = NO;
    self.tabScroll.autoresizesSubviews = YES;
    self.tabScroll.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tabScroll.bounces = NO;
    self.tabScroll.pagingEnabled = YES;
    self.tabScroll.directionalLockEnabled = YES;
    self.tabScroll.delegate = self;
    self.tabScroll.scrollsToTop = NO;
    
    [self.view addSubview:self.tabScroll];
    
    self.tabScroll.contentSize = CGSizeMake(self.view.width*3, self.view.height);
    
    // blip list: (already created in the BaseBlipViewcController)
    self.blipTable.topInset = 72;
    self.blipTable.blipCellDisplayMode = (self.channel.type == ChannelTypeUser) ? BlipCellDisplayModePlace : BlipCellDisplayModeAuthor;
    self.blipTable.scrollsToTop = YES; // only tabScroll will scrollToTop
    [self.listPanel addSubview:self.blipTable];
    
    [self.tabScroll addSubview:self.mapPanel];
    [self.mapView setRegion:MainBlipsViewController.sharedController.mapView.region animated:YES];
    
    [self.tabScroll addSubview:self.listPanel];
    
    // blip list count
    [self _configureHeaderTabButton:self.blipsTabButton withLabel:@"Blips" andCount:self.channel.stats.blips];

    // follower list:
    self.followerTable = [[ChannelTableView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height)];
    self.followerTable.cellStyle = ChannelCellStyleFollower;
    self.followerTable.topInset = 72;
    self.followerTable.delegate = self;
    self.followerTable.scrollsToTop = NO;
    self.followerTable.listName = @"Followers";
    self.followerTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self _configureHeaderTabButton:self.followersTabButton withLabel:@"Followers" andCount:self.channel.stats.followers];
    [self.tabScroll addSubview:self.followerTable];
    [self.channel getFollowers:^(NSMutableArray *channels, ServerModelError *error) {
        if (!error) {
            self.followerTable.channels = channels;
        }
    }];
    
    // following list:
    self.followingTable = [[ChannelTableView alloc] initWithFrame:CGRectMake(self.view.width*2.0,0, self.view.width, self.view.height)];
    self.followingTable.cellStyle = ChannelCellStyleFollower;
    self.followingTable.topInset = 72;
    self.followingTable.delegate = self;
    self.followingTable.scrollsToTop = NO;
    self.followingTable.listName = @"Following";
    self.followingTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self _configureHeaderTabButton:self.followingTabButton withLabel:@"Following" andCount:self.channel.stats.following];

    [self.tabScroll addSubview:self.followingTable];
    [self.channel getFollowing:^(NSMutableArray *channels, ServerModelError *error) {
        if (!error) {
            self.followingTable.channels = channels;
        }
    }];
    
}

// respond to changes in the view controller's view's frame:
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object==self.view &&
        [keyPath isEqualToString:@"frame"]) {
        CGRect oldFrame,newFrame;
        [[change valueForKey:NSKeyValueChangeNewKey] getValue:&newFrame];
        [[change valueForKey:NSKeyValueChangeOldKey] getValue:&oldFrame];

        if (oldFrame.size.height != newFrame.size.height) {
            self.tabScroll.height = newFrame.size.height;
            self.tabScroll.contentSize = CGSizeMake(self.tabScroll.contentSize.width,newFrame.size.height);
            for (UIView *subview in self.tabScroll.subviews) {
                subview.height = newFrame.size.height;
            }
        }
        
    }
    else {
        if (object==self.channel) {
            [self configureWithChannel:object];
        }
    }
}

-(void)_configurePlaceButton:(UIButton *)button enable:(BOOL)enable {
    BBTraceLevel(4);
    button.enabled = enable;
    button.alpha = enable ? 1.0 : .4;
}

- (void)_configureHeaderTabButton:(UIButton *)button withLabel:(NSString *)label andCount:(NSInteger)count {
    BBLogLevel(4,@"configure channel header %@ %d", label, count);
    NSString *countText = count>=0 ? [NSString stringWithFormat:@"%d ",count] : @"";
    NSString *buttonText = [NSString stringWithFormat:@"%@%@",countText,label];

    button.titleLabel.font = [UIFont bbFont:17];
    [button setTitle:buttonText forState:UIControlStateNormal];
    [button setTitle:buttonText forState:UIControlStateHighlighted];
    [button setTitle:buttonText forState:UIControlStateSelected];
    [button setTitle:buttonText forState:UIControlStateSelected|UIControlStateHighlighted];
    
    [button setTitleColor:[UIColor bbGray3] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateHighlighted];
    
    [button setTitleColor:[UIColor bbDarkBlue] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor bbGray3] forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (void)_stylePlaceActionButton:(UIButton *)button {
    BBTraceLevel(4);
    button.titleLabel.font = [UIFont bbBoldFont:17];
    [button setTitleColor:[UIColor bbPaperWhite] forState:UIControlStateNormal];
    //[UIColor colorWithRGBHex:0x8F8F8F alpha:1]
    [button setTitleColor:[UIColor bbGray2] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor bbGray3] forState:UIControlStateDisabled];
    
}

- (void)_setupStyle {
    BBTraceLevel(4);
    self.header.backgroundColor = [UIColor bbHeaderPattern];
    self.tabIndicator.ry = self.header.bottom;
    self.name.font = [UIFont bbBlipAuthorFont];
    self.name.textColor = [UIColor bbWarmGray];
    self.minimalHeader.backgroundColor = [UIColor bbHeaderPattern];
    self.tabsPanel.backgroundColor = [UIColor bbHeaderPattern];
    self.placeButtonsPanel.backgroundColor = [UIColor bbWarmGray];
    self.descriptionText.font = [UIFont bbBlipMessageFont];
    self.descriptionText.textColor = [UIColor bbWarmGray];

    [self _stylePlaceActionButton:self.websiteButton];
    [self _stylePlaceActionButton:self.phoneButton];
    [self _stylePlaceActionButton:self.directionsButton];
    [self _configureHeaderTabButton:self.blipsTabButton withLabel:@"Blips" andCount:-1];
    [self _configureHeaderTabButton:self.followersTabButton withLabel:@"Followers" andCount:-1];
    [self _configureHeaderTabButton:self.followingTabButton withLabel:@"Following" andCount:-1];
    
    self.headerBottomLine.backgroundColor = [UIColor bbDarkBlue];
    
}


#pragma mark -
#pragma mark UI manipulation methods
/** Given the scrollview position, calculates a float which will 
 *  range fractionally between the ChannelDetailTab values
 */
-(CGFloat)tabFractionalPosition {
    CGFloat pageWidth = self.tabScroll.width;
    float fractionalPage = self.tabScroll.contentOffset.x / pageWidth;
    return fractionalPage;
}

- (void)alignTablesWithHeader {
    BBTraceLevel(4);
    self.blipTable.topInset = self.header.height;
    self.followerTable.topInset = self.header.height;
    self.followingTable.topInset = self.header.height;
}

/** high level interface that talks to layoutHeaderWithHeight
 */
-(void)setHeaderLayout:(ChannelDetailHeaderLayout)layout animated:(BOOL)animated {
    NSTimeInterval duration = animated ? .2 : 0;
    switch (layout) {
        case ChannelDetailHeaderLayoutCompressed:
        {
            [UIView animateWithDuration:duration animations:^{
                [self layoutHeaderWithHeight:self.tabsPanel.height + self.minimalHeader.height];
            }];
            break;
        }
            
        case ChannelDetailHeaderLayoutExpanded:
        {
            [UIView animateWithDuration:duration animations:^{
                [self layoutHeaderWithHeight:self.tabsPanel.height + self.minimalHeader.height + self.descriptionText.height];
            }];
            break;
        }
    }
}

/** positions the various elements as a result of table scrolling or map movement
 */
-(void)layoutHeaderWithHeight:(CGFloat)inputHeight {
    CGFloat minimalHeight = self.tabsPanel.height;
    CGFloat newHeight = MAX(inputHeight,minimalHeight);
    
    self.header.height = newHeight;
    self.headerBottomLine.ry = newHeight - self.headerBottomLine.height;
    self.tabsPanel.ry = newHeight-self.tabsPanel.height;
    self.tabIndicator.ry = self.header.bottom;

    ChannelDetailTab currentTab = [self tab];
    for (ChannelDetailTab tab =ChannelDetailTabFirst; tab<= ChannelDetailTabLast; tab++) {
        id<BBTableProtocol> table =[self tableForTab:tab];
        if (tab!=currentTab) {
            [table setTopInset:newHeight];
        }
        else if (newHeight>[table topInset]){
            // ensure header doesn't ever cover top of list
            // this can occur when switching between lists
          table.topInset=MIN(newHeight,_headerMaxHeight);
        }
    }
}

-(void)scrollTabsToPage:(NSUInteger)page {
    BBLog(@"%d",page);
    CGFloat xStart = self.tabScroll.width*(CGFloat)page;
    [self.tabScroll setContentOffset:CGPointMake(xStart, 0) animated:YES];
}

-(void)setTab:(ChannelDetailTab)tab {
    BBTrace();
    [self setSelectedTabButton:tab];
    [self scrollTabsToPage:tab];
    //[[self tableForTab:tab] scrollToRow:0 atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(ChannelDetailTab)tab {
    if (self.blipsTabButton.selected) {
        return ChannelDetailTabBlips;
    }
    else if (self.followersTabButton.selected) {
        return ChannelDetailTabFollowers;
    }
    else {
        return ChannelDetailTabFollowing;
    }
}

-(id<BBTableProtocol>)tableForTab:(ChannelDetailTab)tab {
    switch (tab) {
        case ChannelDetailTabBlips:
            return self.blipTable;
            break;
            
        case ChannelDetailTabFollowers:
            return self.followerTable;
            
        case ChannelDetailTabFollowing:
            return self.followingTable;
            
        default:
            break;
    }
}

-(UIButton *)buttonForTab:(ChannelDetailTab)tab {
    switch (tab) {
        case ChannelDetailTabBlips:
            return self.blipsTabButton;
            break;
            
        case ChannelDetailTabFollowers:
            return self.followersTabButton;
            break;

        case ChannelDetailTabFollowing:
            return self.followingTabButton;
            break;
            
        default:
            break;
    }
 
}

-(void)setSelectedTabButton:(ChannelDetailTab)selectedTab {
    BBLog(@"%d",selectedTab);
    for (ChannelDetailTab tab=ChannelDetailTabFirst; tab<=ChannelDetailTabLast; tab++) {
        [[self buttonForTab:tab] setSelected:(tab==selectedTab)];
        [[self tableForTab:tab] setScrollsToTop:(tab==selectedTab)];
    }
}

-(CGFloat)_tabIndicatorPosition:(CGFloat)fractionalPage {
    CGFloat page0 = self.blipsTabButton.center.x;
    CGFloat page1 = self.followersTabButton.center.x;
    CGFloat page2 = self.followingTabButton.center.x;
    
    if (fractionalPage<0.0) {
        return page0;
    }
    else if (fractionalPage<=1.0) {
        return page0 + fractionalPage*(page1-page0);
    }
    else if (fractionalPage<=2.0) {
        return page1 + (fractionalPage-1.0)*(page2-page1);
    }
    else {
        return page2;
    }
}

-(void)centerTabIndicatorAt:(CGFloat)xPos {
    self.tabIndicator.rx = xPos - self.tabIndicator.width/2;
}


-(BOOL) isUserAccount {
    return [self.channel.id isEqualToString:BBAppDelegate.sharedDelegate.myAccount.id];
}

#pragma mark -
#pragma mark Actions
- (IBAction)descriptionTap:(id)sender {
    ChannelDescriptionViewController *cdvc = [ChannelDescriptionViewController channelDescriptionViewController:self.channel];
    [self.navigationController pushViewController:cdvc animated:YES];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    [Flurry logEvent:kFlurryChannelPullHeader];
    switch(swipe.direction) {
        case UISwipeGestureRecognizerDirectionDown:
            [self setHeaderLayout:ChannelDetailHeaderLayoutExpanded animated:YES];
            break;
            
        case UISwipeGestureRecognizerDirectionUp:
            [self setHeaderLayout:ChannelDetailHeaderLayoutCompressed animated:YES];
            break;
            
            default:
            break;
    }
}

- (IBAction)editAction:(id)sender {
    BBTrace();
    [Flurry logEvent:kFlurryProfile];
    ProfileEditorViewController *ctrl = [ProfileEditorViewController viewController];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)blipTabButtonPressed:(id)sender {
    BBTrace();
    [Flurry logEventWithParams:kFlurryChannelBlips,
     @"id",self.channel.id,nil];
    self.mapListButton.customView.hidden = NO;
    [self setTab:ChannelDetailTabBlips];
}

- (IBAction)followersButtonPressed:(id)sender {
    BBTrace();
    [Flurry logEventWithParams:kFlurryChannelFollowers,
     @"id",self.channel.id,nil];
    self.mapListButton.customView.hidden = YES;
    [self setTab:ChannelDetailTabFollowers];
}

- (IBAction)followingButtonPressed:(id)sender {
    BBTrace();
    [Flurry logEventWithParams:kFlurryChannelFollowing,
     @"id",self.channel.id,nil];
    self.mapListButton.customView.hidden = YES;
    [self setTab:ChannelDetailTabFollowing];
}

//- (IBAction)toggleHeaderLayout:(id)sender {
//    BBTrace();
//    _headerExpanded = !_headerExpanded;
//    [UIView animateWithDuration:.25 animations:^{
//        [self configureWithChannel:self.channel];
//    }];
//
//    [Flurry logEventWithParams:kFlurryChannelDescription,
//     @"id",self.channel.id,nil];
//}

- (IBAction)tuneInAction:(id)sender {
    BBTrace();
    
    [[BBRemoteNotificationManager sharedManager] promptUserToEnablePushNotificationsIfNeeded];
    
    UIButton* button = sender;
    button.selected = !button.selected;
    if (!button.selected) {
        [Flurry logEvent:kFlurryChannelUnfollow
                   withParameters:[NSDictionary dictionaryWithObject:self.channel.id forKey:@"id"]];

        [self.channel tuneOut:^(Channel *channel, ServerModelError *error) {}];
    }
    else {
        if (self.channel && self.channel.id) {
            [Flurry logEvent:kFlurryChannelFollow
                       withParameters:[NSDictionary dictionaryWithObject:self.channel.id forKey:@"id"]];
        }

        [self.channel tuneIn:^(Channel *channel, ServerModelError *error) {}];
    }

}

- (IBAction)showWebsite:(id)sender {
    BBTrace();
    NSDictionary *params = [Flurry
                            paramsWithError:nil,
                            @"channel",self.channel.id,
                            @"category",[(PlaceChannel *)self.channel category],
                            nil];
    [Flurry logEvent:kFlurryChannelWebsite
               withParameters:params];
     
    if (self.channel.type==ChannelTypePlace) {
        [(PlaceChannel *)self.channel showWebsite];
    }
}

- (IBAction)callAction:(id)sender
{
    BBTrace();
    NSDictionary *params = [Flurry
                            paramsWithError:nil,
                            @"channel",self.channel.id,
                            @"category",[(PlaceChannel *)self.channel category],
                            nil];
    [Flurry logEvent:kFlurryChannelCall
               withParameters:params];
    
    if (self.channel.type==ChannelTypePlace) {
        PlaceChannel *place = (PlaceChannel *)self.channel;
        [place callPhone];
    }
}

- (IBAction)directionsAction:(id)sender
{
    BBTrace();
    NSDictionary *params = [Flurry
                            paramsWithError:nil,
                            @"channel",self.channel.id,
                            @"category",[(PlaceChannel *)self.channel category],
                            nil];
    
    [Flurry logEvent:kFlurryChannelDirections
               withParameters:params];
    if (self.channel.type == ChannelTypePlace) {
        PlaceChannel* place = (PlaceChannel *)self.channel;
        [place showDirections];
    }
}


- (IBAction)blacklistAction:(id)sender
{
    BBTrace();
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BLACKLIST"
                                                    message:@"Are you sure you want to blacklist this channel?"
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}

- (BOOL)allowTransitionToChannelDetail:(Channel *)channel {
    BBTrace();
    return ![self.channel.id isEqualToString:channel.id];
}

- (void)showChannelDetailViewControllerFor:(Channel *)channel {
    BBTrace();
    if (![channel.id isEqualToString:self.channel.id]) {
        [super showChannelDetailViewControllerFor:channel];
    }
}

- (NSString*) contentDescription
{
    BBTraceLevel(4);
    return @"channel-detail";
}

#pragma mark -
#pragma mark BlipDetail events
-(void) didHideBlipDetail {
    BBTrace();
    [UIView animateWithDuration:.25 animations:^{
        self.header.transform = CGAffineTransformIdentity;
        self.tabIndicator.transform = CGAffineTransformIdentity;
        self.tabIndicator.ry = self.header.bottom;
    }];
}

-(void) didChangeBlipDetail:(Blip *)blip {
    BBTrace();
}

-(void) didShowBlipDetail:(Blip *)blip {
    BBTrace();
    [UIView animateWithDuration:.25 animations:^{
        self.header.transform = CGAffineTransformMakeTranslation(0, -self.header.height);
        self.tabIndicator.transform = CGAffineTransformMakeTranslation(0, -self.header.height - self.tabIndicator.height);
    }];

}
#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BBTrace();
    if (buttonIndex == 1) {
        [self.channel blacklist:^(ServerModelError *error) {
            if ( error ) {
                BBLog(@"Could not blacklist the channel: %@", error);
            }
            else {
                BBLog(@"Blacklisting is done");
            }
        }];
    }
}

#pragma mark -
#pragma mark MapViewController methods

-(void)ensureBlipInBlips:(NSMutableArray *)blips {
    BBTraceLevel(4);
    if (_ensureBlip) {
        for (NSUInteger i=0; i<blips.count; i++) {
            Blip *blip = [blips objectAtIndex:i];
            if ([blip.id isEqualToString:_ensureBlip.id]) {
                [blips replaceObjectAtIndex:i withObject:_ensureBlip];
                return;
            }
        }
        // if we get here, we couldn't find the _ensureBlip
        [blips insertObject:_ensureBlip atIndex:0];
    }
}

-(MKCoordinateRegion)_boundsForAnnotations:(NSArray *)annotations {
    if (annotations.count>0) {
        CGFloat n=90,s=-90,w=180,e=-180;
        
        for (id<MKAnnotation>annotation in annotations) {
            CLLocationCoordinate2D coord = annotation.coordinate;
            if (coord.latitude<n) {
                n = coord.latitude;
            }
            if (coord.latitude>s) {
                s = coord.latitude;
            }
            if (coord.longitude<w) {
                w = coord.longitude;
            }
            if (coord.longitude>e) {
                e = coord.longitude;
            }
        }
        return MKCoordinateRegionMake(CLLocationCoordinate2DMake((n+s)/2., (e+w)/2.),
                                      MKCoordinateSpanMake(s-n, e-w));
    }
    else {
        return [MainBlipsViewController sharedController].mapView.region;
    }
}

// override default loadMapData behavior
-(id<CancellableOperation>)loadBlips:(MKCoordinateRegion)region {
    BBTrace();
    if (self.blipTable.blips && self.blipTable.blips.count) {
        // if we've already loaded blips, no need to load them again
        BBLog(@"Already loaded blips");
        //[self loadedBlips:self.blipTable.blips withError:nil];
        return nil;
    }
    else {
        return [self.channel getBlipStream:^(NSMutableArray *blips, ServerModelError *error) {
            //[self _configureHeaderTabButton:self.blipsTabButton withLabel:@"Blips" andCount:blips.count];
            [self ensureBlipInBlips:blips];
            [self.blipTable setBlips:blips]; // !am! dirty hack to show all the channel's blips
            [self loadedBlips:blips withError:error];
            if (_ensureBlip) {
                [self.blipTable showBlip:_ensureBlip];
                _ensureBlip = nil;
            }
            
            self.mapView.delegate = nil;
            [self.mapView setRegion:[self _boundsForAnnotations:blips] animated:NO];
            self.mapView.delegate = self;
            // !am! Removing this for now because it interferes with SF region restriction:
            // MKCoordinateRegion showRegion = [self boundingRegionForBlips:blips default:region];
            // [self.mapView setRegion:showRegion animated:YES];
        }];
    }
}


-(NSArray *)computeTableBlips {
    return self.blipTable.blips;
}

- (MKCoordinateRegion) boundingRegionForBlips:(NSArray *)blips default:(MKCoordinateRegion)defaultRegion {
    BBTraceLevel(4);
    CGFloat n=-90,s=90,w=180,e=-180;
    for (Blip *blip in blips) {
        CLLocationCoordinate2D coordinate = blip.coordinate;
        if (coordinate.latitude>n) {
            n = coordinate.latitude;
        }
        if (coordinate.latitude<s) {
            s = coordinate.latitude;
        }
        if (coordinate.longitude>e) {
            e= coordinate.longitude;
        }
        if (coordinate.longitude<w) {
            w = coordinate.longitude;
        }
    }
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((n+s)/2, (e+w)/2);
    MKCoordinateRegion region;
    if (n<=s || e<=w) {
        region = defaultRegion;
    }
    else {
        region = MKCoordinateRegionMake(center,MKCoordinateSpanMake(abs(n-s), abs(w-e)));
    }
    return region;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    // !am! override load blips behavior
    [self setHeaderLayout:ChannelDetailHeaderLayoutCompressed animated:YES];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    BBTrace();
    [super viewDidLoad];
    
    @synchronized(self) {
        if (!_observerInstalled) {
            [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            _observerInstalled = YES;
        }
    }

    
    // init has requested menu button to be shown
    if (_showMenuButton) {
        [[SlideoutViewController sharedController] addSlideoutMenu:self];
        [[SlideoutViewController sharedController] addMenuButtonAndBadge:self];
    }
    
    // setup channel header
    [[NSBundle mainBundle] loadNibNamed:@"ChannelDetailHeader" owner:self options:nil];

    self.title = self.channel.name;
    self.blipDetailView.noTransitionChannel = self.channel;
    
    // initialize map and lists:
    // self.mapView.region = BBAppDelegate.sharedDelegate.mainViewController.mapView.region;
    
    [self _setupStyle];
    [self configureTabs];
    
    // setup the bottom bar (for place channels)
    [self configurePlaceButtonsPanel];
    
    // add the header
    [self.view insertSubview:self.header aboveSubview:self.blipTable];
    [self.view setBackgroundColor:[UIColor bbGridPattern]];
    
    __block ChannelDetailViewController *blockSelf = self;
    [self loadBlipsForVisibleMap];
    [BBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [BBAppDelegate.sharedDelegate.myAccount getChannel:blockSelf.channel.id block:^(Channel *channel, ServerModelError *error) {
        [BBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        if (channel) {
            [blockSelf configureWithChannel:channel];
        }
        
    }];

    self.name.text = self.channel.name;
    [self.picture setImageWithURLString:self.channel.picture placeholderImage:nil];
    
    [self configureWithChannel:self.channel];
    
    if (self.channel.type==ChannelTypePlace) {
        [self showTableWithFlipDuration:0];
    }
    else {
        [self showMapWithFlipDuration:0];
    }

    [self setTab:_initialTab];
}

-(void)viewWillAppear:(BOOL)animated {
    BBTrace();
    [super viewWillAppear:animated];
    
    // !am! We watch changes to the view's frame because we need to resize blip/follower/following lists.  Because they reside inside a scrollview,
    //      we cannot use iOS's AutoResizing behavior, as this give strange behavior
}


- (void)viewDidUnload
{
    BBTrace();
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    BBTrace();
    [super viewDidAppear:animated];

    BBLog(@"Heatmaps track ChannelDetailViewController");
    [Heatmaps track:self.view withKey:@"92e49bf7098d3dd4-6c9943ce"]; //
}

- (void)viewWillDisappear:(BOOL)animated
{
    BBTrace();
    [super viewWillDisappear:animated];
    
    @synchronized(self) {
        if (_observerInstalled) {
            [self.view removeObserver:self forKeyPath:@"frame"];
            _observerInstalled = NO;
        }
    }
   
    [self.mapView stopLocationServices];
    self.mapView.delegate = nil;    // !am! mapview can continue firing regionDidChange methods after view disappears, which causes a crash
                                    //      the delegate is reconnected in the SplashNavigationController
                                    //      Thanks for all the wonderful hours we've spent together, iOS.

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark BlipTableViewDelegate (override methods)

-(void)blipTableViewDidScroll:(BlipTableView *)blipTable {
    // only update the header if the table is the visible one
    // only the visible table drives the movement of the header to avoid loops
    // where repositioning the header
    //    => repositioning the table (causing a scroll event)
    //       => repositioning of the header...
    if (blipTable == [self tableForTab:[self tab]]) {
        CGFloat newHeight = _headerMaxHeight-blipTable.topInset-blipTable.contentOffset;
        [self layoutHeaderWithHeight:newHeight];
    }
}


-(void)blipTableView:(BlipTableView *)blipTable didSelectBlip:(Blip *)blip {
    BBTrace();
    if (![blip.author.id isEqualToString:self.channel.id]) {
        [self showChannelDetailViewControllerFor:blip.author withBlip:blip];
    }
    else if (![blip.place.id isEqualToString:self.channel.id]) {
        [self showChannelDetailViewControllerFor:blip.place withBlip:blip];
    }
}

#pragma mark -
#pragma mark ChannelTableViewDelegate 
-(void)channelTableViewDidScroll:(ChannelTableView *)channelTable {
    // only update the header if the table is the visible one
    // only the visible table drives the movement of the header to avoid loops
    // where repositioning the header
    //    => repositioning the table (causing a scroll event)
    //       => repositioning of the header...
    if (channelTable==[self tableForTab:[self tab]]) {
        CGFloat newHeight = _headerMaxHeight-channelTable.topInset-channelTable.contentOffset;
        [self layoutHeaderWithHeight:newHeight];
    }
}

-(void)channelTableView:(ChannelTableView *)channelTable didSelectChannel:(Channel *)channel {
    [self showChannelDetailViewControllerFor:channel]; // BaseBlipViewController method
}

#pragma mark -
#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {

    static NSInteger previousPage = 0;
    CGFloat fractionalPage = [self tabFractionalPosition];
    [self centerTabIndicatorAt:[self _tabIndicatorPosition:fractionalPage]];
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed
        // Do your thing!
        previousPage = page;
        [self setSelectedTabButton:page];
    }
    
}

#pragma mark -
#pragma mark BBNavigationControllerEvents
-(void)navigationController:(UINavigationController *)navigationController didUncoverViewController:(UIViewController *)controller animated:(BOOL)animated {
    // if user has edited the profile, make sure we update the current view controller
//    if (self.isUserAccount) {
//        [self configureWithChannel:BBAppDelegate.sharedDelegate.myAccount];
//    }
}
@end
