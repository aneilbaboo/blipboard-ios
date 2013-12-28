//
//  BaseBlipsViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBMapView.h"
#import "Cancellation.h"
#import "BlipTableView.h"
#import "BlipDetailView.h"
#import "BBNavigationController.h"
#import "BBGenericBarButtonItem.h"

typedef enum {
    BlipViewDisplayModeMap,
    BlipViewDisplayModeTable
} BlipViewDisplayMode;

@class BBDropDownToastView;
@class BaseBlipsViewController;

/** Base controller for showing blips on a map, detail of blips or blips in a list
 */
@interface BaseBlipsViewController : UIViewController <  MKMapViewDelegate,
                                                        BlipTableViewDelegate,
                                                        BlipDetailViewDelegate,
                                                        UIGestureRecognizerDelegate,
                                                        BBNavigationControllerEvents> {
    NSMutableArray *_viewDidAppearActions; // an array of blocks which should be run when viewDidAppear is called
}

@property (nonatomic,strong) UIView *mapPanel; // holds the map & other controls only shown with the mapView
@property (nonatomic,strong) BBMapView* mapView; // created in initializer, not XIB
@property (nonatomic,strong) BlipTableView* blipTable;
@property (nonatomic,strong) UIView *listPanel;
@property (nonatomic,strong) UIBarButtonItem *mapListButton;
@property (nonatomic,strong) UIActivityIndicatorView *mapActivityIndicator;
@property (nonatomic,strong) BBDropDownToastView* mapToast;
@property (nonatomic,strong) Cancellation *cancellation;
@property (nonatomic,strong) BlipDetailView *blipDetailView;
@property (nonatomic,strong) UIButton *locateButton;

+ (MKCoordinateRegion)defaultStartRegion ;

- (void)clearPins;
- (void)showChannelDetailViewControllerFor:(Channel*)channel;
- (void)showChannelDetailViewControllerFor:(Channel *)channel withBlip:(Blip *)blip;
- (BlipViewDisplayMode)displayMode;

// methods used by subclasses:
- (id<CancellableOperation>)loadBlips:(MKCoordinateRegion)region; // !am! override this in subclasses to provide different blip loading behavior
- (NSOperation *)loadedBlips:(NSArray *)blips withError:(ServerModelError *)error; // subclasses call this to update the map
- (void)removeChannelsBlips:(Channel*)channel;

// used by subclass initialization !am! - maybe remove if there's a better way of doing this
- (void)showTable;
- (void)showTableWithFlipDuration:(CGFloat)duration;
- (void)showMapWithFlipDuration:(CGFloat)duration;
- (void)showMap;
- (void)handleMapTapGesture:(UITapGestureRecognizer *)gesture;
- (void)clearOffScreenPins; // for freeing memory

// Public Blip methods
- (NSMutableArray *)visibleBlips;
- (BOOL)isShowingPopularBlips;
- (NSArray *)computeTableBlips; // retrieves blips which should be displayed in the tableview
- (void)loadBlipsForVisibleMap; // kicks off all the animations & loads blips
- (void)loadMapCenteredAtBlip:(Blip*)blip;
- (void)loadMapCenteredAtBlip:(Blip*)blip completion:(void (^)())completion; // loads blips centered at location of blip and selects blip (if exists); calls completion when blip is visible
- (void)hideBlipDetail;
- (void)showBlipDetailFor:(Blip *)blip;

- (Blip *)selectedBlip;  // if there is a single selected blip, it is returned
-(void)didHideBlipDetail; // called when blip detail hides
-(void)didChangeBlipDetail:(Blip *)blip; // called when blip detail changes
-(void)didShowBlipDetail:(Blip *)blip; // called when blip detail is first shown

- (void)startUserTracking;
- (void)stopUserTracking;
- (NSString*) contentDescription; // e.g. discover,me,following

@end
