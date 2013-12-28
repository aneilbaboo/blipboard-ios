//
//  BaseBlipsViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Flurry+Blipboard.h"
#import <Heatmaps/Heatmaps.h>
#import <stdlib.h> // arcrandom

#import "BBAppDelegate.h"
#import "BBLog.h"
#import "ASIDownloadCache.h"

// UI elements
#import "UIColor+BBColors.h"
#import "ChannelDetailViewController.h"
#import "SingleBlipViewController.h"
#import "BaseBlipsViewController.h"
#import "InfoViewController.h"
#import "BBDropDownToastView.h"
#import "BlipPin.h"
#import "UIView+position.h"
#import "UIView+RoundedCorners.h"
#import "BlipDetailView.h"
#import "NSTimer+Blocks.h"

typedef void (^Action)();

@implementation BaseBlipsViewController  {
    NSMutableDictionary *_mapData;
    NSArray *_blipsModeToolbar;
    Cancellation *_cancellation;
    BOOL _userRequestedLocation;
}

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad
{
    BBLog(@"%@",[self class]);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect frame = CGRectMake(0, 0, self.view.width, self.view.height);
    [self configureMapWithFrame:frame];
    [self configureListWithFrame:frame];
    
    // Setup the navigation controller:
    [self _configure];

    // create the blip detail view controller
    _blipDetailView = [BlipDetailView blipDetailView];
    _blipDetailView.delegate = self;
    [_blipDetailView setLayout:BlipDetailLayoutHidden animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    BBLog(@"%@",[self class]);
    // create the blipDetailView - must be done here so the subclass's .navigationController can be hooked
    [super viewWillAppear:animated];
    
    [_blipDetailView addToViewController:self];
    [_blipDetailView observeKeyboard];
    
    // mapView will be resized by this point; reposition map controls:
    self.mapActivityIndicator.center = self.mapView.center;
    self.locateButton.ry = self.mapView.height - self.locateButton.height - 20;
}

- (void)viewDidAppear:(BOOL)animated {
    BBLog(@"%@",[self class]);
    [super viewDidAppear:animated];
    for (Action action in _viewDidAppearActions) {
        action();
    }
    [_viewDidAppearActions removeAllObjects];


}

- (void)viewWillDisappear:(BOOL)animated {
    BBLog(@"%@",[self class]);
    [_cancellation cancel];
    [super viewWillDisappear:animated];
    [_blipDetailView unobserveKeyboard];
}

-(void)viewWillUnload {
    BBTrace();
    [super viewWillUnload];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // subclasses will handle this
}

#pragma mark -
#pragma mark Configuration
- (void)_configure {
    _cancellation = [Cancellation cancellation];
    _viewDidAppearActions = [NSMutableArray array];
    
    // create toast
    _mapToast = [BBDropDownToastView toastWithFrame:CGRectMake(10,10,300,36)];
    [self.view insertSubview:self.mapToast aboveSubview:_blipTable];
    self.view.autoresizesSubviews = YES;
    
    [self _configureNavBar];
    
    [self showMap];
}

- (void)_configureNavBar {
    // mapList button
    BBGenericBarButtonItem *mapListButton = [BBGenericBarButtonItem barButtonItem:@"Map" target:self action:@selector(toggleMapList:)];
    self.mapListButton = mapListButton;
    
    // add buttons to the navBar:
    self.navigationItem.rightBarButtonItems = @[mapListButton];
    
}

- (void)configureMapWithFrame:(CGRect)frame {
    // _mapPanel holds map & other associated controls (if any) to enable a clean flip transition to listView
    _mapPanel = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    _mapPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapPanel.autoresizesSubviews = YES;
    [self.view insertSubview:_mapPanel atIndex:0];
    
    // create MKMapView
    _mapView = [[BBMapView alloc] initWithFrame:frame];
    [_mapPanel insertSubview:_mapView atIndex:0];
    
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.autoresizesSubviews = YES; // reposition the loading indicator
    _mapView.delegate = self;
    _mapView.zoomEnabled = YES;
    _mapView.userInteractionEnabled = YES;
    _mapView.scrollEnabled = YES;
    [self _addMapTapGesture];
    _mapData = [NSMutableDictionary dictionaryWithCapacity:100];
    
    // Create the activity indicator:
    _mapActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_mapView addSubview:_mapActivityIndicator];
    _mapActivityIndicator.center = self.mapView.center;
    _mapActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapActivityIndicator.hidesWhenStopped = YES;
    
    
    [self _addLocateButton];
    [self hideMapButtons];
    
}

- (void)configureListWithFrame:(CGRect)frame {
    // create blip table
    self.listPanel = [[UIView alloc] initWithFrame:frame];
    self.listPanel.autoresizesSubviews = YES;
    self.listPanel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _listPanel.hidden = YES;
    [self.listPanel setBackgroundColor:[UIColor bbGridPattern]];

    _blipTable = [[BlipTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _blipTable.bottomInset = 25;
    _blipTable.delegate = self;
    [_listPanel addSubview:_blipTable];
    [self.view addSubview:_listPanel];
}


- (void)_addMapTapGesture {
    // enable tap to gesture on map
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTapGesture:)];
    mapTap.delegate = self;
    [_mapView addGestureRecognizer:mapTap];
}

- (void)_addLocateButton {
    self.locateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 32)];
    
    self.locateButton.backgroundColor = [UIColor clearColor];
    
    [self.locateButton setImage:[UIImage imageNamed:@"btn_location.png"] forState:UIControlStateNormal];
    //    [self.locateButton setImage:[UIImage imageNamed:@"bnt_location.png"] forState:UIControlStateNormal|UIControlStateHighlighted];
    //    [self.locateButton setImage:[UIImage imageNamed:@"location.png"] forState:UIControlStateSelected];
    
    [self.locateButton addTarget:self action:@selector(toggleUserTracking:) forControlEvents:UIControlEventTouchDown];
    
    // hide location button if we're not tracking user location
    // note: we always show location button if user has disabled location services, so that user is prompted to enable location services when he pressed the button
    BOOL locationServicesEnabled = ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized);
    self.locateButton.hidden = locationServicesEnabled && (self.mapView.userTrackingMode != MKUserTrackingModeNone);
    self.locateButton.rx = 10;
    self.locateButton.ry = self.mapView.height - self.locateButton.height - 20;
    
    [self.mapView addSubview:self.locateButton];
}

- (void)_addViewDidAppearAction:(Action)action {
    [_viewDidAppearActions addObject:action];
}

#pragma mark -
#pragma mark Actions
- (void)handleMapTapGesture:(UITapGestureRecognizer *)tapGesture {
    BBTrace();
    [self performSelector:@selector(_hideMapButtonsAndCancelSelection) withObject:nil afterDelay:.5];
}
- (void)_hideMapButtonsAndCancelSelection {
    [Flurry logEvent:kFlurryMapTapped
               withParameters:nil];

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hideMapButtons)
                                               object:nil];
    
    for (id<MKAnnotation> annotation in _mapView.selectedAnnotations) {
        [_mapView deselectAnnotation:annotation animated:YES];
    }
    
    [self showMapButtons];
    [self performSelector:@selector(hideMapButtons) withObject:nil afterDelay:5];

}

- (void)toggleUserTracking:(id)sender {
    BBTrace();
    _userRequestedLocation = YES;
    [self showMap];
    if (self.mapView.userTrackingMode==MKUserTrackingModeNone) {
        [Flurry logEvent:kFlurryUserTrackingOn];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else {
        [Flurry logEvent:kFlurryUserTrackingOff];
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    }
}

- (void)showMapButtons {
}

- (void)hideMapButtons {

}

#pragma mark -
#pragma mark mapList button
- (void)toggleMapList:(id)sender {
    if (_mapPanel.hidden) {
        [self showMap];
        [Flurry logEvent:kFlurryToggleToMap];
    }
    else {
        [self showTable];
        [Flurry logEvent:kFlurryToggleToList];
    }
}

-(void)showBlipDetailViewControllerFor:(Blip *)blip {
    SingleBlipViewController *controller = [SingleBlipViewController blipDetailViewController:blip];

    [self.navigationController pushViewController:controller animated:YES];

}
- (void)showChannelDetailViewControllerFor:(Channel*)channel
{
    BBLog(@"%@", channel);
    ChannelDetailViewController *channelDetail = [[ChannelDetailViewController alloc] initWithChannel:channel];
    [self.navigationController pushViewController:channelDetail animated:YES];
}

- (void)showChannelDetailViewControllerFor:(Channel *)channel withBlip:(Blip *)blip {
    BBLog(@"%@", blip);
    NSAssert([blip.author.id isEqualToString:channel.id] ||
             [blip.place.id isEqualToString:channel.id],
             @"Inconsistent blip and channel in call to showChannelDetailViewControllerFor");
    ChannelDetailViewController *channelDetail =
    [[ChannelDetailViewController alloc] initWithChannel:channel
                                                showBlip:blip];
    [self.navigationController pushViewController:channelDetail animated:YES];
}

- (void)showTable {
    [self showTableWithFlipDuration:.5];
}

- (void) hideBlipTableHUD {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBlipTableHUD) object:nil];
    [BBProgressHUD hideAllHUDsForView:self.listPanel animated:NO];
}

- (void)showBlipTableHUD {
    BBProgressHUD *hud = [BBProgressHUD showHUDAddedTo:self.listPanel animated:NO];
    hud.hideOnTap = YES;
    hud.labelText = @"No blips nearby";
    hud.detailsLabelText = @"Tap to show map";
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeText;
    [hud setTapAction:^{
        [self showMap];
    }];
}
- (void) showTableWithFlipDuration:(CGFloat)duration
{
    [self hideBlipTableHUD];
    [self.mapListButton setTitle:@"Map"];
    
    [self.blipDetailView setLayout:BlipDetailLayoutHidden animated:YES];
    if (_listPanel.hidden) {
        [UIView transitionFromView:_mapPanel
                            toView:_listPanel
                          duration:duration
                           options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
        if (self.blipTable.blips.count==0) {
            [self performSelector:@selector(showBlipTableHUD) withObject:nil afterDelay:3];
        }
    }
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:SYSTEM_VERSION_LESS_THAN(@"6.0")];
}

- (void)showMap {
    [self showMapWithFlipDuration:.5];
}

- (void) showMapWithFlipDuration:(CGFloat)duration
{
    [self.mapListButton setTitle:@"List"];
//    [self.mapListButton setTitle:@"List" forState:UIControlStateNormal];
//    [self.mapListButton setTitle:@"List" forState:UIControlStateHighlighted];
    
    if (_mapPanel.hidden) {
        [UIView transitionFromView:_listPanel
                            toView:_mapPanel
                          duration:duration
                           options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionTransitionFlipFromLeft
                        completion:nil];
    }
}

#pragma mark -
#pragma mark Blip selection
// superclass overrides
-(void)didHideBlipDetail {} // called when blip detail hides
-(void)didChangeBlipDetail:(Blip *)blip {} // called when blip detail changes
-(void)didShowBlipDetail:(Blip *)blip {} // called when blip detail is first shown

-(void)hideBlipDetail {
    [self hideBlipDetailFor:_blipDetailView.blip];
}

/** Hide detail for the blip if it is the one currently shown.
 *  Otherwise, this method does nothing.  The purpose is to provide
 *  a delayed selector to call that hides the blip detail if the map pin
 *  was deselected, but no new pin was selected.
 *
 * @param blip the blip for which the detail should be hidden.
 */
-(void)hideBlipDetailFor:(Blip *)blip {
    BBTrace();
    
    if (_blipDetailView.blip==blip) {
        [_mapView deselectAnnotation:blip animated:YES];
        BBLog(@"hide the blip detail!");
        [_blipDetailView setLayout:BlipDetailLayoutHidden animated:YES];
        if (blip) {
            [Flurry logEvent:kFlurryBlipDetailHide
                       withParameters:[Flurry                             paramsWithError:nil,
                                       @"id",blip.id,
                                       @"author-type",blip.author._typeString,
                                       @"isListening",blip.author._isListening,
                                       @"blipPinDesign",[(BlipPin *)blip.view designDescription],
                                       nil]];
        }
        [UIView animateWithDuration:.2 animations:^{
            [self setForegroundPin:nil];
        }];
        [self didHideBlipDetail];
    }
}


/** Show the compressed detail for the blip
 *  @param blip the blip to show
 */
-(void)showBlipDetailFor:(Blip *)blip {
    BBTrace();

    [Flurry logEventWithParams:kFlurryBlipDetailShow,
                               @"id",blip.id,
                               @"author-type",blip.author._typeString,
                               @"isListening",blip.author._isListening.stringValue,
                               @"blipPinDesign",[(BlipPin *)blip.view designDescription],
                               nil];

    
    [UIView animateWithDuration:.2 animations:^{
        [self setForegroundPin:(BlipPin *)blip.view];
    }];
    
    if (![_mapView.selectedAnnotations containsObject:blip]) {
        BlipPin *pin = [blip.view isKindOfClass:[BlipPin class]] ? (BlipPin *)blip.view : nil;
        if (!pin || !pin.selected) {
            [_mapView selectAnnotation:blip animated:YES];
        }
    }
    
    BlipDetailLayout oldLayout = _blipDetailView.layout;
    [_blipDetailView configureWithBlip:blip];
    [_blipDetailView setLayout:BlipDetailLayoutCompressed animated:YES];

    if (oldLayout==BlipDetailLayoutHidden) {
        [self didShowBlipDetail:blip];
    }
    else {
        [self didChangeBlipDetail:blip];
    }
}

- (void)setForegroundPin:(BlipPin *)pin {
    if (pin) {
        for (id<MKAnnotation>annotation in _mapView.annotations) {
            if ([annotation isKindOfClass:[Blip class]]) {
                Blip *blip = (Blip *)annotation;
                if (blip.view != pin) {
                    ((BlipPin *)blip.view).state = BlipPinStateBackground;
                }
            }
        }
        pin.state = BlipPinStateForeground;
    }
    else {
        for (id<MKAnnotation>annotation in _mapView.annotations) {
            if ([annotation isKindOfClass:[Blip class]]) {
                Blip *blip = (Blip *)annotation;
                ((BlipPin *)blip.view).state = BlipPinStateDefault;
            }
        }
    }
}

// ensure that the blip on the map has the latest info
- (void)updateBlip:(Blip*)blip
{
    Blip* existing = [_mapData objectForKey:blip.place.id];
    if (existing) {
        [_mapView removeAnnotation:existing];
    }
    
    [_mapView addAnnotation:blip];
    [_mapData setObject:blip forKey:blip.place.id];
    [_blipTable updateBlip:blip];
}

- (void)loadMapCenteredAtBlip:(Blip *)blip {
    [self loadMapCenteredAtBlip:blip completion:nil];
}


- (void)loadMapCenteredAtBlip:(Blip*)blip completion:(void (^)())completion {
    BBLog(@"Blip: %@", blip);
    [self updateBlip:blip];
    
    // center the blip in the top 1/2 of the map:
    _mapView.userInteractionEnabled = NO;
    [_mapView centerAtCoordinate:blip.coordinate
                        withSpan:_mapView.region.span
               inLatitudeSection:0
                      ofSections:2
                        animated:YES];
    
    // !am! I think these do not need to be __block, since we're not modifying them:
    __block BaseBlipsViewController *blockSelf = self;
    __block Blip *blockBlip = blip;
    __block MKMapPoint point = MKMapPointForCoordinate(blip.coordinate);
    __block void (^blockCompletion)() = completion;
    
    __block NSUInteger count = 0; // !am! probably only this needs to be __block
    static NSTimer *timer;
    
    // this timer waits until the mapView has animated into position:
    timer = [NSTimer
             scheduledTimerWithTimeInterval:.1
             blockRepeatsWhileTrue:^BOOL{
                 // wait for blip to be in view:
                 count++;
                 NSLog(@"isBlip in view? try %d", count);
                 MKMapRect rect = blockSelf.mapView.visibleMapRect;
                 if (MKMapRectContainsPoint(rect,point)) {
                     [blockSelf showBlipDetailFor:blockBlip];
                     _mapView.userInteractionEnabled = YES;
                     if (blockCompletion) {
                         blockCompletion();
                     }
                     return false;
                 }
                 else {
                     if (count<30) {
                         return true;  // try for 3 seconds
                     }
                     else {
                         _mapView.userInteractionEnabled = YES;
                         return false; // quit
                     }
                 }
             }];
}

#pragma mark SharedMap Methods
- (void)clearOffScreenPins {
    BBTrace();
    MKMapRect visibleRect = _mapView.visibleMapRect;
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        // clear all blips outside of visible region,
        // and remove them from the mapData dictionary
        if (!MKMapRectContainsPoint(visibleRect, MKMapPointForCoordinate(annotation.coordinate))
            && [annotation isKindOfClass:[Blip class]])  {
            Blip * blip = (Blip *)annotation;
            [_mapView removeAnnotation:blip];
            [_mapData removeObjectForKey:blip.place.id];
        }
    }
}

// !JCF! This code is not used
+ (MKCoordinateRegion)defaultStartRegion {
    // get setup values from the info dictionary
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *defaultStartRegion = (NSDictionary *)[infoDictionary objectForKey:@"defaultStartRegion"];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[defaultStartRegion valueForKey:@"latitude"] floatValue],
                                                               [[defaultStartRegion valueForKey:@"longitude"] floatValue]);
    return MKCoordinateRegionMakeWithDistance(center,
                                              [[defaultStartRegion valueForKey:@"widthMeters"] floatValue],
                                              [[defaultStartRegion valueForKey:@"heightMeters"] floatValue]);
    
}

- (BOOL) isShowingPopularBlips
{
    return NO;
}

- (NSArray *)computeTableBlips
{
    return [[self visibleBlips] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Blip *blip1 = obj1;
        Blip *blip2 = obj2;
        return [blip2.createdTime compare:blip1.createdTime];
    }];
}

- (NSMutableArray *)visibleBlips {
    NSMutableArray *visibleBlips = [NSMutableArray arrayWithCapacity:_mapView.annotations.count];
    MKMapRect visibleRect = _mapView.visibleMapRect;
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        if ([annotation isKindOfClass:[Blip class]] &&
            MKMapRectContainsPoint(visibleRect, MKMapPointForCoordinate(annotation.coordinate))) {
            [visibleBlips addObject:annotation];
        }
    }
    return visibleBlips;
}

- (void) clearPins {
    BBTrace();
    NSArray *annotations = _mapView.annotations;
    NSUInteger count = 0;
    for (id<MKAnnotation> annotation in annotations) {
        if ([annotation isKindOfClass:[Blip class]]) {
            BlipPin *pin = (BlipPin *)[(Blip *)annotation view];
            __block MKMapView *blockMapView = _mapView;
            if (pin) {
                [pin disappearAnimationWithDelay:arc4random_uniform(25.)/100. completion:^(BlipPin *blipPin) {
                    [blockMapView removeAnnotation:annotation];
                }];
            }
            else {
                [_mapView removeAnnotation:annotation];
            }

            count++;
        }
    }
    [_mapData removeAllObjects];
    BBLog(@"Removed %d map annotations",count);
}


#pragma mark -
#pragma mark Blip loading & Toast

-(void)temporaryToastWithText:(NSString *)text {
    if (![BBAppDelegate.sharedDelegate isSplashVisible]) {
        [_mapToast showText:text forSeconds:3.0];
    }
}

-(void)handleNoBlipsReturned {
    _blipTable.blips = nil;
}

-(void)handleError:(ServerModelError *)error {
    if (error.statusCode==500) {
        [self temporaryToastWithText:@"Server error"];
    }
}

- (void)loadBlipsForVisibleMapWithDelay:(CGFloat)seconds clearPins:(BOOL)clearPins {
    BBLog(@"seconds: %f.",seconds);
    [_cancellation cancel];
    [self performSelector:@selector(loadBlipsForVisibleMap) withObject:nil afterDelay:seconds];
    if (clearPins) {
        [self performSelector:@selector(clearPins) withObject:nil afterDelay:0];
    }
    
    __block BaseBlipsViewController *Self = self;
    [_cancellation addOperationNamed:@"stop clearPins & stop previous loadBlipsForVisibleMap" block:^{
        [NSObject cancelPreviousPerformRequestsWithTarget:Self selector:@selector(clearPins) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:Self selector:@selector(loadBlipsForVisibleMap) object:nil];
    }];
}

- (void)loadBlipsForVisibleMap {
    BBTrace();
    [_cancellation cancel];
    [_mapActivityIndicator startAnimating];
    [_cancellation addOperation:[self loadBlips:_mapView.region]];
}

-(void)hideMapActivityIndicator {
    [UIView animateWithDuration:.25 animations:^{
        _mapActivityIndicator.layer.backgroundColor = UIColor.clearColor.CGColor;
    } completion:^(BOOL finished) {
        [_mapActivityIndicator stopAnimating];
    }];
}
// this method is overridden by subclasses
- (id<CancellableOperation>)loadBlips:(MKCoordinateRegion)region {
    NSAssert(false, @"Method should be implemented by subclass");
    return nil; 
}

- (BlipViewDisplayMode)displayMode {
    return _listPanel.hidden ? BlipViewDisplayModeMap : BlipViewDisplayModeTable;
}

- (Blip *)selectedBlip {
    NSArray *selected = _mapView.selectedAnnotations;
    if (selected &&
        selected.count==1 &&
        [[selected objectAtIndex:0] isKindOfClass:[Blip class]]) {
        return [selected objectAtIndex:0];
    }
    return nil;
}

// handles all error reporting/adding
- (NSOperation *)loadedBlips:(NSArray *)blips withError:(ServerModelError *)error {
    [_mapActivityIndicator stopAnimating];
    if (error) {
        [self showMap];
        BBLog(@"error: %@",error);
        [self temporaryToastWithText:error.explanation];
    }
    else {
        [self hideBlipTableHUD];
        BBLog(@"loaded %d blips",[blips count]);
        if (blips) {
            if (blips.count==0) {
                [self handleNoBlipsReturned];
            }
            // completion is an NSOperation completion block, which is held by
            // [NSOperationQueue mainQueue].  __block is correct here, since
            // there is no circular retain issue.
            __block BaseBlipsViewController *Self = self;
            return [self _addBlipsToMap:blips completion:^{
                if (Self.displayMode==BlipViewDisplayModeTable) {
                    Self.blipTable.blips = [Self computeTableBlips];
                    [Self.blipTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                }                
            }];
        }
        else {
            [self handleNoBlipsReturned];
        }
    }
    return nil;
}

// internal function
- (NSOperation *)_addBlipsToMap:(NSArray *)blips completion:(void (^)())completion {
    BBBlockOperation *combinedOperation = [NSBlockOperation blockOperationWithBlock:^{
        
    }];
    [combinedOperation setCompletionBlock:completion];

    for (Blip* blip in blips) {
        Blip* existing = [_mapData objectForKey:blip.place.id];
        // !jcf! should also update if the likeCount changed.
        if (!existing || (existing.id == blip.id && existing.isRead != blip.isRead)) {
            blip.message = [[blip.message stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                            stringByReplacingOccurrencesOfString:@"\n\n" withString:@" "];
            [_mapData setObject:blip forKey:blip.place.id];
            // !jcf! we really should be updating the existing annotation rather than remove/insert.
            if (existing) {
                [_mapView removeAnnotation:existing];
            }
            __block Blip *blockBlip = blip;
            __block MKMapView *blockMap = _mapView;
            
            NSOperation *addAnnotationBlock = [blip.author loadPictureWithBlock:^(UIImage *image) {
                [blockMap addAnnotation:blockBlip];
            }];
            if (addAnnotationBlock) {
                [combinedOperation addDependency:addAnnotationBlock];
            }
        }
    }
    

    [[NSOperationQueue mainQueue] addOperation:combinedOperation];
    return combinedOperation;
}

- (void)updateAuthorsBlips:(Channel *)author
{
    BBTrace();
    // we must copy the author's blips out of mapData:
    //    updateBlip alters mapData
    //    and altering a NSDictionary during an iteration will cause a crash
    NSMutableArray *authorBlips=[NSMutableArray arrayWithCapacity:_mapData.count];
    for (NSString *blipId in _mapData) {
         Blip *blip= [_mapData objectForKey:blipId];
        if ([blip.author.id isEqualToString:author.id]) {
            blip.author = author; // update the author object in the blip!
            [authorBlips addObject:blip];
        }
    }
    for (Blip *blip in authorBlips) {
        [self updateBlip:blip];
    }
}

- (void)removeChannelsBlips:(Channel*)channel
{
    BBTrace();
    NSMutableArray* discardedKeys = [NSMutableArray arrayWithCapacity:_mapData.count];
    for (id key in [_mapData keyEnumerator]) {
        Blip* blip = [_mapData valueForKey:key];
        if ([blip.author.id isEqualToString:channel.id] || [blip.place.id isEqualToString:channel.id]) {
            [_mapView removeAnnotation:blip];
            [discardedKeys addObject:key];
        }
    }
    [_mapData removeObjectsForKeys:discardedKeys];
}

- (void)deselectAllPins {
    MKMapRect visibleRect = _mapView.visibleMapRect;
    // deselect the annotion if it is outside of the visible map rect
    for (id<MKAnnotation> annotation in _mapView.selectedAnnotations) {
        if (!MKMapRectContainsPoint(visibleRect, MKMapPointForCoordinate(annotation.coordinate))) {
            [_mapView deselectAnnotation:annotation animated:YES];
        }
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate methods
-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    BBTraceLevel(4);
}
-(void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    BBLog(@"%@",error);
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [BBAppDelegate.sharedDelegate setMyLocation:userLocation.location];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    static MKCoordinateRegion previousRegion;
    
    // if zooming out more than 5%, clear the pins
    MKCoordinateSpan prevSpan = previousRegion.span;
    MKCoordinateSpan span = mapView.region.span;
    CGFloat mapZoomPercent = (span.latitudeDelta - prevSpan.latitudeDelta)/prevSpan.latitudeDelta;
    BOOL clearPins = (prevSpan.latitudeDelta==0 ||
                      mapZoomPercent > .05);
    [self deselectAllPins];

    // if moving less than 5%, ignore this region update
    CLLocationCoordinate2D curCenter = mapView.region.center;
    CLLocationCoordinate2D prevCenter = previousRegion.center;
    CGFloat latChange = fabs(curCenter.latitude - prevCenter.latitude);
    CGFloat lngChange = fabs(curCenter.longitude - prevCenter.longitude);
    BOOL allowUpdate = (clearPins || // must allow update since we're clearing pins
                        (prevSpan.latitudeDelta==0) || // indicates this is the first time through
                        (latChange/span.latitudeDelta > .05) ||
                        (lngChange/span.longitudeDelta > .05) );
        
    // save previous region
    previousRegion = mapView.region;
    
    if (!allowUpdate) {
        BBLog(@"insignificant change; refusing to load blips");
        return;
    }

    BBLog(@"%f,%f,%f,%f",
          mapView.centerCoordinate.latitude,
          mapView.centerCoordinate.longitude,
          mapView.region.span.latitudeDelta,
          mapView.region.span.longitudeDelta);
    NSString* mapEvent = fabs(mapZoomPercent)>.01 ? kFlurryMapZoom : kFlurryMapPan;
    [Flurry logEventWithParams:mapEvent,
     @"latitude",       [@(mapView.centerCoordinate.latitude) stringValue],
     @"longitude",      [@(mapView.centerCoordinate.longitude) stringValue],
     @"latitudeDelta",  [@(mapView.region.span.latitudeDelta) stringValue],
     @"longitudeDelta", [@(mapView.region.span.longitudeDelta) stringValue],
     nil];
    
    if (![Account isInSupportedAreaWithCoordinate:mapView.centerCoordinate]) {
        BBLog(@"outside of supported area - go to default location");
        [Flurry logEvent:kFlurryMapUnsupportedRegion];
        
        [self temporaryToastWithText:@"Only SF for now..." ];
        [self stopUserTracking];
        CLLocationCoordinate2D coord = [Account getDefaultStartLocationFromCoordinate:mapView.centerCoordinate];
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coord,1000,1000) animated:NO];
    }
    
    [self loadBlipsForVisibleMapWithDelay:0.25 clearPins:clearPins];
}

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    BBLog(@"Mode changed to %d",mode);
    BOOL locationServicesEnabled = [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
    BOOL tracking = locationServicesEnabled && mapView.userTrackingMode!=MKUserTrackingModeNone;
    __block MKMapView *blockMapView = mapView;
    if (tracking) {
        [UIView animateWithDuration:.5
                         animations:^{
                             self.locateButton.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             // !am! without checking again, we run into a race condition between the two states
                             BOOL locationServicesEnabled = [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
                             BOOL tracking = locationServicesEnabled && (blockMapView.userTrackingMode!=MKUserTrackingModeNone);
                             BBLogLevel(4,@"tracking=%d",tracking);
                             self.locateButton.alpha = tracking ? 0 : 1;
                             self.locateButton.hidden = tracking;
                         }];
    }
    else {
        self.locateButton.hidden = NO;
        [UIView animateWithDuration:.5
                         animations:^{
                             self.locateButton.alpha = 1;
                         }];
    }
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    BBLog(@"%@",error);
    CLLocationCoordinate2D coord = [Account getDefaultStartLocationFromLocation:nil];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(coord, 1000,1000) animated:YES];

    self.locateButton.selected = NO;
    if (_userRequestedLocation) {
        _userRequestedLocation = NO;
        [BBAppDelegate.sharedDelegate.locationManager informUserOfLocationError:error];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    BBTraceLevel(4);
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews {
    BBTraceLevel(4);
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    BBTrace();
    [self performSelector:@selector(hideBlipDetailFor:) withObject:self.blipDetailView.blip afterDelay:.1];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(_hideMapButtonsAndCancelSelection)
                                               object:nil];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id annotation = view.annotation;
    if ([annotation isKindOfClass:[Blip class]]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(_hideMapButtonsAndCancelSelection)
                                                   object:nil];

        Blip *blip = annotation;
        BBLog(@"Selected annotation for %@", blip);
        
        [self showBlipDetailFor:(Blip *)blip];
    }
    else {
        [mapView deselectAnnotation:view.annotation animated:NO];
    }

}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    BBTraceLevel(4);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[Blip class]]) {
        Blip *blip = (Blip *)annotation;
        __block BlipPin * pin = (BlipPin *)[_mapView dequeueReusableAnnotationViewWithIdentifier:BlipPin.reuseIdentifier];
        if (!pin) {
            pin = [[BlipPin alloc] init];
        }
        BOOL aBlipIsSelected = (mapView.selectedAnnotations.count>0 &&
                                [[mapView.selectedAnnotations objectAtIndex:0]
                                 isKindOfClass:[Blip class]]);
        BlipPinState state = aBlipIsSelected ? BlipPinStateBackground : BlipPinStateDefault;
        [pin configureWithBlip:blip state:state animate:YES delay:((CGFloat)arc4random_uniform(50.))/100.0];
        blip.view = pin; // !am! needed for reverse lookup
        
        return pin;
    }
    return nil;
}

- (void) startUserTracking
{
    BBTrace();
    [self.mapView startUserTrackMode];
}

- (void) stopUserTracking
{
    BBTrace();
    [self.mapView stopLocationServices];
}

- (NSString*) contentDescription
{
    assert(false);
    return @"invalid";
}

// debugging code for visualizing requested region
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    MKPolygonView *view = [[MKPolygonView alloc] initWithPolygon:overlay];
    view.fillColor = [[UIColor redColor] colorWithAlphaComponent:.2];
    view.strokeColor = [UIColor redColor];
    view.lineWidth = 2;
    return view;
}

#pragma mark -
#pragma mark UIGestureRecognizer - for MapView
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

#pragma mark -
#pragma mark BlipTableViewDelegate methods

-(void)blipTableView:(BlipTableView *)blipTable didSelectChannel:(Channel *)channel
{
    [self showChannelDetailViewControllerFor:channel];
}

-(void)blipTableView:(BlipTableView *)blipTable didSelectBlip:(Blip *)blip
{
    BBTrace();
    [self showBlipDetailViewControllerFor:blip];
}

-(void)blipTableView:(BlipTableView *)blipTable didTapBlipComment:(Blip *)blip {
    [self showBlipDetailViewControllerFor:blip];    
}

#pragma mark -
#pragma mark ChannelDetailViewControllerDelegate
// !am! these methods may be overriden by subclasses (e.g., just MainBlipsViewController) to provide behavior 
- (void)blipViewController:(BaseBlipsViewController *)controller didLikeBlip:(Blip *)blip {
    __weak BaseBlipsViewController *weakSelf = self;
    [self _addViewDidAppearAction:^{
        [weakSelf updateBlip:blip];
    }];

}
- (void)blipViewController:(BaseBlipsViewController *)controller didUnlikeBlip:(Blip *)blip {
    __weak BaseBlipsViewController *weakSelf = self;
    [self _addViewDidAppearAction:^{
        [weakSelf updateBlip:blip];
    }];}

- (void)blipViewController:(BaseBlipsViewController *)controller didTuneInChannel:(Channel *)channel {
    __weak BaseBlipsViewController *weakSelf = self;
    [self _addViewDidAppearAction:^{
        [weakSelf updateAuthorsBlips:channel];
    }];
}

- (void)blipViewController:(BaseBlipsViewController *)controller didTuneOutChannel:(Channel *)channel {
    BBTrace();
    __weak BaseBlipsViewController *weakSelf = self;
    [self _addViewDidAppearAction:^{
        [weakSelf updateAuthorsBlips:channel];
    }];

    //[self removeChannelsBlips:channel];
}

#pragma mark -
#pragma mark BlipDetailViewDelegate
- (void)blipDetailViewDidHide:(BlipDetailView *)blipDetailView {
    [_mapView deselectAnnotation:blipDetailView.blip animated:YES];
}

- (void)blipDetailView:(BlipDetailView *)blipDetailView channelPressed:(Channel *)channel
{
    [self showChannelDetailViewControllerFor:channel];
}

#pragma mark -
#pragma mark BBNavigationControllerEvents
-(void)navigationController:(UINavigationController *)navigationController willPopViewController:(UIViewController *)controller animated:(BOOL)animated {
    if (controller==self) {
        [_blipDetailView unobserveKeyboard];
        [_blipDetailView removeFromViewController];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willCoverViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self.blipDetailView retractNavBar];
}

-(void)navigationController:(UINavigationController *)navigationController willUncoverViewController:(UIViewController *)controller animated:(BOOL)animated {
    self.mapView.delegate = self;
    [self.blipDetailView unretractNavBar];
    if (self.blipDetailView.layout == BlipDetailLayoutExpanded) {
        [self.blipDetailView setLayout:BlipDetailLayoutCompressed animated:YES];
    }
    else {
        // !am! sometimes navBar gets stuck in a partial position due to
        //      iOS animation race problem.  This cures it:
        [self.blipDetailView setLayout:self.blipDetailView.layout animated:YES];
    }
}
@end


