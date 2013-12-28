//
//  MainBlipsViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "MainBlipsViewController.h"
#import "BBBackBarButtonItem.h"
#import "BroadcastSelectPlaceViewController.h"
#import "BroadcastTextInputViewController.h"
#import "BlipPin.h"
#import "InfoViewController.h"
#import "BBNavigationController.h"
#import "SlideoutViewController.h"
#import "FilterList.h"

@implementation MainBlipsViewController 

+(MainBlipsViewController *)sharedController {
    static MainBlipsViewController *ctrlr;
    if (!ctrlr) {
        ctrlr = [[MainBlipsViewController alloc] initWithNibName:nil bundle:nil];
    }
    return ctrlr;
}

#pragma mark -
#pragma mark Lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocation *location = BBAppDelegate.sharedDelegate.myLocation;
    CLLocationCoordinate2D initialCoord = [Account getDefaultStartLocationFromLocation:location];
    
    self.mapView.region=MKCoordinateRegionMakeWithDistance(initialCoord, 1000, 1000);
    
    self.blipTable.topInset = 5;

    [self _setupToolbar];
    [self _setupNotificationBar];
    [self _setupNavBar];
    [self _setupFilterList];
    
    [[SlideoutViewController sharedController] addSlideoutMenu:self];
    [[SlideoutViewController sharedController] addMenuButtonAndBadge:self];
    
    [self startUserTracking];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [BBAppDelegate.sharedDelegate onMainViewControllerIsVisible:self];
    self.mapView.showsUserLocation = YES;
    
    BBLog(@"Heatmaps track MainBlipsViewController");
    [Heatmaps track:self.view withKey:@"92e49bf7098d3dd4-3f7294a2"];
    [Heatmaps trackNavigationBarInNavigationController:self.navigationController withKey:@"92e49bf7098d3dd4-5e6391bc"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[_backButton attachToVisibleViewControllerOf:self];
}

- (void)didReceiveMemoryWarning {
    [self clearOffScreenPins];
    [Flurry logEvent:kFlurryWarningLowMemory];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)_setupNavBar {
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blipboard_logo.png"]];
}

-(void)_setupNotificationBar {
    self.notificationBar = [BBNotificationBar notificationBar];
    [self.mapPanel addSubview:self.notificationBar];
}

-(void)_setupToolbar {
    
    _contentSegmentControl = [ContentSegmentControl contentSegmentControlOnSuperview:self.mapPanel withDelegate:self];
    self.mapView.height = self.mapPanel.height - _contentSegmentControl.barHeight;
}

-(void)_setupFilterList {
    self.filterList = [FilterList filterList];
    [self.filterList addToViewController:self];
    self.filterList.delegate = self;
}

- (void)selectContentSegment:(ContentSegment)mode
{
    self.contentSegmentControl.selectedSegmentIndex = mode;
}

-(void)markBlipRead:(Blip *)blip {
    if (self.contentSegmentControl.selectedSegmentIndex == ContentSegmentFollowing) {
        blip.isRead = YES;
        [blip.place markMyReceivedBlipsRead:^(ServerModelError *error) {
            BBLog(@"Marked read");
            blip.isRead = YES;
            
            // tell the BlipPin to redraw itself.
            BlipPin* pin = (BlipPin *)blip.view;
            [pin redraw];
        }];
    }
}

#pragma mark -
#pragma mark Animations

- (void)tuneInAnimationWithPin:(BlipPin *)blipPin {
    UIImageView* authorPicture = [[UIImageView alloc] initWithImage:blipPin.framedAuthorImage]; // pic to be animated
    CGPoint pinPoint = [self.mapView convertCoordinate:blipPin.blip.coordinate toPointToView:self.view]; // !am! seems aligned with left bottom corner of blip image
    CGFloat height = self.view.height;
    CGPoint alertsCenter =_contentSegmentControl.followingButton.center;
    CGPoint endPoint = [self.view convertPoint:CGPointMake(alertsCenter.x - authorPicture.size.width/2,
                                                           alertsCenter.y - authorPicture.size.height/2)
                                      fromView:_contentSegmentControl.followingButton];
    
    CGPoint startPoint = CGPointMake(pinPoint.x+blipPin.image.size.width/2 -authorPicture.size.width/2, pinPoint.y-authorPicture.size.height);
    authorPicture.alpha = .5;
    authorPicture.frame = CGRectMake( startPoint.x, startPoint.y, authorPicture.frame.size.width, authorPicture.frame.size.height );
    
    CGFloat xDist = (endPoint.x - startPoint.x);
    CGFloat yDist = (endPoint.y - startPoint.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    CGFloat duration = (1.2/height)*distance;
    
    [self.view addSubview:authorPicture];
    
    authorPicture.alpha = 0;
    [UIView animateWithDuration:duration
                          delay:.5
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         // move picture onto "Alerts" tab
                         authorPicture.frame = CGRectMake( endPoint.x, endPoint.y, authorPicture.frame.size.width, authorPicture.frame.size.height );
                         authorPicture.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         // shrink picture to nothing
                         [UIView animateWithDuration:2
                                               delay:.1
                                             options:UIViewAnimationCurveEaseIn
                                          animations:^{
                                              //authorPicture.alpha = 0.0;
                                              authorPicture.frame = CGRectMake(authorPicture.frame.origin.x+authorPicture.frame.size.width/2,
                                                                               authorPicture.frame.origin.y+authorPicture.frame.size.height/2,
                                                                               0, 0 );
                                          }
                                          completion:^(BOOL finished) {
                                              [authorPicture removeFromSuperview];
                                          }];
                     }];
    
}



#pragma mark -
#pragma mark Specialization of BaseBlipViewController

- (void)didHideBlipDetail {
    switch (self.contentSegmentControl.selectedSegmentIndex) {
        case ContentSegmentDiscover:
            break;
        case ContentSegmentFollowing:
            if (self.blipDetailView.blip) {
                [self markBlipRead:self.blipDetailView.blip];
            }
            break;
        case ContentSegmentMyBlips:
            break;
        default:
            break;
    }
}

- (void)didChangeBlipDetail:(Blip *)blip {
    switch (self.contentSegmentControl.selectedSegmentIndex) {
        case ContentSegmentDiscover:
            break;
        case ContentSegmentFollowing:
            [self markBlipRead:blip];
            break;
        case ContentSegmentMyBlips:
            break;
        default:
            break;
    }
}

- (void)didShowBlipDetail:(Blip *)blip {

    switch (self.contentSegmentControl.selectedSegmentIndex) {
        case ContentSegmentDiscover:
            break;
        case ContentSegmentFollowing:
            break;
        case ContentSegmentMyBlips:
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Methods
- (void) showPopularBlips {
    BBTrace();
    self.contentSegmentControl.selectedSegmentIndex = ContentSegmentDiscover;
}

- (void) showReceivedBlips {
    BBTrace();
    self.contentSegmentControl.selectedSegmentIndex = ContentSegmentFollowing;
}

- (void) showMyBlips {
    BBTrace();
    self.contentSegmentControl.selectedSegmentIndex = ContentSegmentMyBlips;
}

- (void) showTable {
    self.blipTable.blips = [self visibleBlips];
    [super showTable];
}

- (void) showCreateBlip:(PlaceChannel *)place {
    UIViewController * vc;
    [self _clearMapHUD];
    if (place) {
        NSDictionary* params = [NSDictionary dictionaryWithObject:place.id forKey:@"id"];
        [Flurry logEvent:kFlurryBroadcastAtPlace withParameters:params];
        
        vc = [BroadcastTextInputViewController
              viewControllerWithPlaceChannel:place
              andDelegate:self];
    }
    else {
        [Flurry logEvent:kFlurryMapBroadcast];
        vc = [BroadcastSelectPlaceViewController viewControllerWithDelegate:self];
    }
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
    navCtrl.navigationBar.barStyle = UIBarStyleDefault;
    navCtrl.modalInPopover = YES;
    navCtrl.modalPresentationStyle = UIModalPresentationFullScreen;
    navCtrl.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    //[Flurry logAllPageViews:navCtrl];
    [self presentViewController:navCtrl animated:YES completion:nil];
}


- (void)_clearMapHUD {
    [BBProgressHUD hideAllHUDsForView:self.mapView animated:YES];
}

- (void)_showAddBlipsPrompt {
    // user has never created a blip --- highlight the (+) button
    self.contentSegmentControl.plusButton.selected = YES;
    [self.contentSegmentControl startPulsingButton];
    BBProgressHUD *hud = [BBProgressHUD showHUDAddedTo:self.mapView animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_blips_picture.png"]];
    hud.labelText = @"Start adding blips to your map";
    hud.hideOnTap = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud setTapAction:^{
        [self contentSegmentControlPlusPressed:self.contentSegmentControl];
    }];
    [self stopUserTracking];
}

- (id<CancellableOperation>)loadBlips:(MKCoordinateRegion)region {
    BBTrace();
    Cancellation *cancellation = [Cancellation cancellation];
    if (BBAppDelegate.sharedDelegate.authenticated) {
        ContentSegment segment = self.contentSegmentControl.selectedSegmentIndex;
        switch (segment) {
            case ContentSegmentDiscover:
                [cancellation addOperation:[self loadPopular:region]];
                break;
            case ContentSegmentFollowing:
                [cancellation addOperation:[self loadTunedIn:region]];
                break;
                
            case ContentSegmentMyBlips:
                [cancellation addOperation:[self loadMyBlips:region]];
                break;
                
            default:
                //assert(0);
                return nil;
        }
        [cancellation addOperationNamed:@"stop map activity indicator" block:^{
            [self.mapActivityIndicator stopAnimating];
        }];
        return cancellation;
    }
    return nil;
}

- (id<CancellableOperation>)loadTunedIn:(MKCoordinateRegion)region {
    BBTrace();
    // received ("incoming") blips
    MKCoordinateRegion __block requestedRegion = region;
    return [BBAppDelegate.sharedDelegate.myAccount
            getReceivedBlipsInRegion:requestedRegion
            topic:self.filterList.selectedTopic
            block: ^(NSMutableArray *blips, ServerModelError *error) {
                [self loadedBlips:blips withError:error];
            }];
}

- (id<CancellableOperation>)loadPopular:(MKCoordinateRegion)region {
    BBTrace();
    
    // popular blips
    return [BBAppDelegate.sharedDelegate.myAccount
            getPopularBlipsInRegion:self.mapView.region
            type:nil
            topic:self.filterList.selectedTopic
            block:^(NSMutableArray *blips, ServerModelError *error) {
                [self loadedBlips:blips withError:error];
            }];
}

- (id<CancellableOperation>)loadMyBlips:(MKCoordinateRegion)region {
    BBTrace();
    
    // my blips
    return [BBAppDelegate.sharedDelegate.myAccount
            getMyBlipsInRegion:self.mapView.region
            topic:self.filterList.selectedTopic
            block:^(NSMutableArray *blips, ServerModelError *error) {
                [self loadedBlips:blips withError:error];
            }];
}

- (BOOL) isShowingPopularBlips
{
    return (self.contentSegmentControl.selectedSegmentIndex == ContentSegmentDiscover);
}

- (NSArray *)computeTableBlips
{
    if (self.contentSegmentControl.selectedSegmentIndex == ContentSegmentDiscover) {
        return [[self visibleBlips] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Blip *blip1 = obj1;
            Blip *blip2 = obj2;
            return [blip2._popularity compare:blip1._popularity];
        }];
    }
    else {
        return [super computeTableBlips];
    }
}

- (NSString*) contentDescription
{
    switch (self.contentSegmentControl.selectedSegmentIndex) {
        case ContentSegmentDiscover: return @"discover";
        case ContentSegmentFollowing: return @"alerts";
        case ContentSegmentMyBlips: return @"my-blips";
        default: assert(false);
    }
}

#pragma mark -
#pragma mark BlipDetailViewDelegate
-(void)blipDetailViewDidTuneOut:(BlipDetailView *)blipDetailView
{
    __unsafe_unretained MainBlipsViewController *weakSelf = self;
    if (self.contentSegmentControl.selectedSegmentIndex == ContentSegmentFollowing) {
        [(BlipPin *)blipDetailView.blip.view disappearAnimationWithDelay:0 completion:^(BlipPin *blipPin) {
            [weakSelf removeChannelsBlips:blipPin.blip.author];
        }];
    }
    else {
        [(BlipPin *)blipDetailView.blip.view tuneInChangedAnimation:nil];
    }
}

- (void)blipDetailViewDidTuneIn:(BlipDetailView *)blipDetailView
{
    __unsafe_unretained MainBlipsViewController *weakSelf = self;
    [self hideBlipDetail];
    [(BlipPin *)blipDetailView.blip.view tuneInChangedAnimation:^(BlipPin *pin) {
        [weakSelf tuneInAnimationWithPin:pin];
    }];

}

#pragma mark -
#pragma mark BroadcastFlowDelegate
- (void)broadcastFlowDidFinish:(Blip *)blip {
    [self selectContentSegment:ContentSegmentMyBlips];
    // dismisses the view controller presented by the receiver
    [self dismissViewControllerAnimated:YES completion:^{
        [self loadMapCenteredAtBlip:blip];
    }];
    
}

- (void)broadcastFlowDidCancel {

}

#pragma mark -
#pragma mark ContentSegmentControl
- (void)contentSegmentControlPlusPressed:(ContentSegmentControl *)control {
    BBTrace();
    Blip *selectedBlip = [self selectedBlip];
    
    [self showCreateBlip:selectedBlip.place];
}

- (void)contentSegmentControl:(ContentSegmentControl*)control didSelectIndex:(ContentSegment)index
{
    BBTrace();
    [self clearPins];
    [self showMap];
    [self loadBlipsForVisibleMap];
    [self _clearMapHUD];
    if (index == ContentSegmentMyBlips && BBAppDelegate.sharedDelegate.myAccount.stats.blips<1) {
        [self _showAddBlipsPrompt];
    }
    else {
        self.contentSegmentControl.plusButton.selected = NO;
        [self.contentSegmentControl stopPulsingButton];
    }
}

#pragma mark -
#pragma mark FilterListDelegate
-(void)filterList:(FilterList *)filterList didSelectTopic:(Topic *)topic {
    [self clearPins];
    [self loadBlipsForVisibleMap];
}

@end
