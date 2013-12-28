//
//  SlideoutMenuViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SlideoutMenuViewController.h"
#import "ECSlidingViewController.h"
#import "SlideoutMenuCell.h"
#import "SlideoutMenuUserCell.h"
#import "SlideoutMenuNotificationCell.h"
#import "Blip.h"
#import "Notification.h"
#import "InfoViewController.h"
#import "GuruListViewController.h"
#import "ChannelDetailViewController.h"
#import "BBNotificationBadge.h"
#import "UIColor+BBSlideout.h"
#import "WebViewController.h"

@implementation SlideoutMenuViewController {
    SlideoutMenuItem _selectedMenuItem;
    UIViewController *_temporaryController;
    NSString *_temporaryMenuTitle;
    BOOL _installedObserver;
}

+ (instancetype)sharedController {
    static SlideoutMenuViewController * sharedController;
    if (!sharedController) {
        sharedController = [[self alloc] initWithNibName:nil bundle:nil];
    }
    return sharedController;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    _selectedMenuItem = SlideoutMenuItemUnknown;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateNotificationStream:)
                                                 name:BBRemoteNotificationManagerDidUpdateStream
                                               object:nil];
    _installedObserver = YES;
    return self;
}

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slidingViewController setAnchorRightRevealAmount:260.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    self.tableView.backgroundColor = [UIColor bbSlideoutNotificationsTableBackground];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 20, 0)];
    self.notificationsHeader.backgroundColor = [UIColor bbSlideoutNotificationsTableBackground];
    [self.notificationsHeaderLabel setFont:[UIFont bbCondensedBoldFont:15]];
    [self.notificationsHeaderLabel setTextColor:[UIColor bbSlideoutNotificationsHeaderText]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateSelected];
    [Heatmaps track:self.tableView withKey:@"92e49bf7098d3dd4-2a12dc88"];
}

- (void)viewWillUnload {
    if (_installedObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:BBRemoteNotificationManagerDidUpdateStream object:nil];
    }
}

#pragma mark -
#pragma mark functionality
- (SlideoutMenuItem)calculateSelectedMenuItem {
    SlideoutMenuItem item = SlideoutMenuItemUnknown ;
    UIViewController *topController = [SlideoutViewController sharedController].topViewController;
    UIViewController *rootController;
    if ([topController isKindOfClass:[UINavigationController class]]) {
        rootController = [(UINavigationController *)topController viewControllers][0];
    }
    
    if (topController == _temporaryController) {
        item= SlideoutMenuItemTemporary;
    }
    else if ([rootController isKindOfClass:[MainBlipsViewController class]]) {
        item=SlideoutMenuItemBlips;
    }
    else if ([rootController isKindOfClass:[ChannelDetailViewController class]]) {
        item=SlideoutMenuItemAccount;
    }
    else if ([rootController isKindOfClass:[GuruListViewController class]]) {
        item=SlideoutMenuItemGuruList;
    }
    else if ([rootController isKindOfClass:[InfoViewController class]]) {
        item=SlideoutMenuItemInfo;
    }
    return item;
}

-(void)updateSelected {
    SlideoutMenuItem item = [self calculateSelectedMenuItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:item inSection:0];
    
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}


-(NSString *)menuItemName:(NSInteger)index {
    if (index==SlideoutMenuItemAccount) {
        return BBAppDelegate.sharedDelegate.myAccount.name;
    }
    else if (index==SlideoutMenuItemTemporary) {
        return _temporaryMenuTitle;
    }
    else {
        return [@[@"Blips",@"Top Gurus",@"About",] objectAtIndex:index-1];
    }
}

-(UIViewController *)prepareMenuItemViewController:(SlideoutMenuItem)item {
    
    switch (item) {
        case SlideoutMenuItemAccount:
        {
            return [self channelDetailViewControllerForUser:BBAppDelegate.sharedDelegate.myAccount displayTab:ChannelDetailTabBlips];
        }
            
        case SlideoutMenuItemBlips:
        {
            MainBlipsViewController *mvc =[MainBlipsViewController sharedController];
            [mvc.navigationController popToRootViewControllerAnimated:YES];
            return mvc.navigationController;
            break;
        }
        case SlideoutMenuItemGuruList:
        {
            CLLocationCoordinate2D coord =BBAppDelegate.sharedDelegate.myLocation.coordinate;
            GuruListViewController *guruList = [GuruListViewController guruListViewControllerWithCoordinate:coord
                                                                                                    context:@"slideout"];
            BBNavigationController *navCtrlr = [[BBNavigationController alloc] initWithRootViewController:guruList];
            
            return navCtrlr;
        }
            break;
            
        case SlideoutMenuItemInfo:
        {
            InfoViewController *info = [InfoViewController infoViewController];
            BBNavigationController *navCtrlr = [[BBNavigationController alloc] initWithRootViewController:info];
            
            return navCtrlr;
        }
            
        case SlideoutMenuItemTemporary:
        {
            return _temporaryController;
        }
        default:
            assert(false);
            break;
    }
}

- (UIViewController *)channelDetailViewControllerForUser:(Channel *)channel displayTab:(ChannelDetailTab)tab {
    ChannelDetailViewController *channelDetail = [[ChannelDetailViewController alloc]
                                                  initWithChannel:channel
                                                  initialTab:tab
                                                  menuButton:YES];
    BBNavigationController *navCtrlr = [[BBNavigationController alloc] initWithRootViewController:channelDetail];
    
    return navCtrlr;
}

// override the property setter so that table gets reloaded
- (void)setNotificationStream:(NotificationStream *)notificationStream {
    _notificationStream = notificationStream;
    [self.tableView reloadData];
    [self updateSelected];
}

-(void)closeMenu {
    [self selectMenuItem:_selectedMenuItem];
}

- (void)selectMenuItem:(SlideoutMenuItem)item {
    [self selectMenuItem:item completion:nil];
}

- (void)selectMenuItem:(SlideoutMenuItem)item completion:(void (^)(UIViewController *controller))completion {
    UIViewController *newTopViewController;
    if (item!=_selectedMenuItem || item == SlideoutMenuItemTemporary) {
        _selectedMenuItem = item;
        newTopViewController = [self prepareMenuItemViewController:item];
    }
    else {
        newTopViewController = self.slidingViewController.topViewController;
    }
    
    [Flurry logEvent:[NSString stringWithFormat:@"%@-%@",
                      kFlurrySlideoutMenuItemTapped,
                      [[[self menuItemName:item] lowercaseString]
                       stringByReplacingOccurrencesOfString:@" " withString:@"-"]]];
    
    if (newTopViewController !=self.slidingViewController.topViewController) {
        // changing view controllers - animate current one out, and new one in
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = newTopViewController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
            if (completion) {
                completion(newTopViewController);
            }
        }];
    }
    else {
        // we haven't changed the top view controller..
        if (self.slidingViewController.underLeftShowing) {
            // menu is showing, close it:
            [self.slidingViewController resetTopView];
        }
        else {
            // do nothing - top view controller is already showing
        }
        
        if (completion) {
            completion(newTopViewController);
        }
    }
}


-(void)showTemporaryViewController:(UIViewController *)controller withTitle:(NSString *)title {
    _temporaryMenuTitle = title;
    _temporaryController = controller ;
    [self selectMenuItem:SlideoutMenuItemTemporary];
}

-(void)showNotification:(Notification *)notification {
    BBLog(@"%@",notification);
    CGFloat hoursAgo = -[notification.time timeIntervalSinceNow]/(60.*60.);
    [Flurry logEventWithParams:kFlurrySlideoutNotificationTapped,
     @"unread",[@(notification.isUnreadLocally) stringValue],
     @"isNew",[@(notification.isNew) stringValue],
     @"type",notification.type,
     @"hoursAgo",[@(hoursAgo) stringValue],
     nil];
    notification.isUnreadLocally = NO;
    [notification takeAction:self];
}

/** Returns the temporary view controller or nil
 *
 */
- (UIViewController *)temporaryViewController {
    UIViewController *top = [SlideoutViewController sharedController].topViewController;
    return (top ==_temporaryController) ? _temporaryController : nil;
}

- (void)popToMainViewControllerMap {
    BBTrace();
    MainBlipsViewController *mainViewController = [MainBlipsViewController sharedController];
    [mainViewController.navigationController popToRootViewControllerAnimated:NO];
    [mainViewController showMap];
}


#pragma mark -
#pragma mark UITableView delegate/datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (section) {
        case 0:
            if (row==0)
                return 62;
            else
                return 47;
            break;
            
        case 1:
        {
            Notification *notification = self.notificationStream.notifications[row];
            return [SlideoutMenuNotificationCell heightFromNotification:notification];
            break;
        }
            
        default:
            assert(false);
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex) {
        case 0:
            if ([self temporaryViewController]) {
                return SlideoutMenuItemLastWithTemporary;
            }
            else {
                return SlideoutMenuItemLast;
            }
            
        case 1:
            return self.notificationStream.count;
            
        default:
            assert(false);
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (section) {
        case 0:
            
            // navigation menu
            if (row==0) {
                SlideoutMenuUserCell * cell = [tableView dequeueReusableCellWithIdentifier:[SlideoutMenuUserCell reuseIdentifier]];
                if (!cell) {
                    cell = [SlideoutMenuUserCell cell];
                }
                [cell configureWithAccount:BBAppDelegate.sharedDelegate.myAccount];
                return cell;
            }
            else {
                SlideoutMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:[SlideoutMenuCell reuseIdentifier]];
                if (!cell) {
                    cell = [SlideoutMenuCell cell];
                }
                [cell configureWithName:[self menuItemName:row]];
                return cell;
            }
            break;
            
        case 1:
        {
            // notification menu
            SlideoutMenuNotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:[SlideoutMenuNotificationCell reuseIdentifier]];
            if (!cell) {
                cell = [SlideoutMenuNotificationCell cell];
            }
            
            SlideoutMenuNotificationCellStyle style;
            NSInteger count = self.notificationStream.count;
            if (row==0) {
                style = SlideoutMenuNotificationCellFirst;
            }
            else if (count==1) {
                style = SlideoutMenuNotificationCellOnly;
            }
            else if (row==(self.notificationStream.count-1)) {
                style = SlideoutMenuNotificationCellLast;
            }
            else {
                style = SlideoutMenuNotificationCellMiddle;
            }
            
            [cell configureWithNotification:[self.notificationStream.notifications objectAtIndex:row] style:style];
            return cell;
        }
            
        default:
            assert(false);
            break;
    }
    return  nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    switch (section) {
        case 0: // main menu cells:
            [self selectMenuItem:row];
            break;
            
        case 1: // notification cells
            [self showNotification:[self.notificationStream.notifications objectAtIndex:row]];
            break;
            
        default:
            break;
    }
}

// Header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section==1) {
        return self.notificationsHeader.height;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section==1) {
        return self.notificationsHeader;
    }
    
    return nil;
}

#pragma mark -
#pragma mark NotificationActions
-(void)showBlip:(Blip *)blip onSegment:(ContentSegment)segment {
    MainBlipsViewController *mainViewController = [MainBlipsViewController sharedController];

    [self popToMainViewControllerMap];
    [mainViewController showMap];
    [mainViewController selectContentSegment:segment];
    [mainViewController.blipDetailView assignCancelActionToSlideoutMenu];

    [self selectMenuItem:SlideoutMenuItemBlips completion:^(UIViewController *controller) {
        [mainViewController loadMapCenteredAtBlip:blip];
    }];
    
}

-(void)showBlip:(Blip *)blip withLiker:(Channel *)liker {
    BBTrace();
    blip.recentLiker = liker;
    [self showBlip:blip onSegment:ContentSegmentMyBlips];
}

- (void)showBlip:(Blip *)blip withComment:(NSString *)commentId {
    [self showBlip:blip onSegment:ContentSegmentFollowing];
}

- (void)showBlip:(Blip *)blip {
    BBTrace();
    [self showBlip:blip onSegment:ContentSegmentFollowing];
}

- (void)showChannel:(Channel *)channel andDisplay:(ChannelNotificationDisplay)display {
    BBTrace();
    
    [self showTemporaryViewController:[self channelDetailViewControllerForUser:channel displayTab:display] withTitle:channel.name];
}

-(void)showGuruList {
    BBTrace();
    [self selectMenuItem:SlideoutMenuItemGuruList];
}

-(void)showProfileEditor {
    [self selectMenuItem:SlideoutMenuItemAccount completion:^(UIViewController *controller) {
        ChannelDetailViewController *cdvc = (ChannelDetailViewController *)[(BBNavigationController *)controller topViewController];
        [cdvc editAction:cdvc.editButton];
    }];
}

-(void)showWebViewWithURL:(NSString *)urlString andTitle:(NSString *)title {
    NSURL *url = [NSURL URLWithString:urlString];
    WebViewController *nwc = [[WebViewController alloc] initWithURL:url];
    nwc.showSlideoutMenu = YES;
    [nwc openURL:url];
    BBNavigationController *nc = [[BBNavigationController alloc] initWithRootViewController:nwc];
    
    [self showTemporaryViewController:nc withTitle:title];
}

-(void)showCreateBlip:(PlaceChannel *)place {
    [self selectMenuItem:SlideoutMenuItemBlips completion:^(UIViewController *controller) {
        MainBlipsViewController *main = (MainBlipsViewController *)[(BBNavigationController *)controller topViewController];
        if (place || BBAppDelegate.sharedDelegate.myAccount.stats.blips>0) {
            [main showCreateBlip:place];
        }
        else {
            // user has never created a blip - show MyBlips map; MainBlips view controller will pulse the button
            [main showMyBlips];
        }
     
    }];
    
}

#pragma mark -
#pragma mark NSNotificationCenter observers
-(void)didUpdateNotificationStream:(NSNotification *)nsnotification {
    NSDictionary *userInfo = nsnotification.userInfo;
    BBLog(@"%@",userInfo);
    if (userInfo[BBRemoteNotificationManagerFresh]) {
        [self setNotificationStream:userInfo[BBRemoteNotificationManagerStream]];
    }
    if (userInfo[BBRemoteNotificationManagerLaunch]) {
        // user wants to see the blip!
        Notification *notification = userInfo[BBRemoteNotificationManagerNotification];
        [self showNotification:notification];
    }
}
@end
