//
//  MainBlipsViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/29/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BaseBlipsViewController.h"
#import "BroadcastSelectPlaceViewController.h"
#import "ContentSegmentControl.h"
#import "BBBackBarButtonItem.h"
#import "BlipDetailView.h"
#import "Notification.h"
#import "BBNotificationBar.h"
#import "FilterList.h"
#import "NimbusBadge.h" //Badge creation utility
#import "BroadcastDelegate.h"

@interface MainBlipsViewController : BaseBlipsViewController
                                        <   BroadcastFlowDelegate,
                                            ContentSegmentControlDelegate,
                                            BlipDetailViewDelegate,
                                            FilterListDelegate>

@property (nonatomic,strong) ContentSegmentControl *contentSegmentControl;
@property (nonatomic,strong) BBNotificationBar *notificationBar;
@property (nonatomic,strong) FilterList *filterList;

+ (MainBlipsViewController *) sharedController;
- (void) selectContentSegment:(ContentSegment)mode;
- (void) showPopularBlips;
- (void) showReceivedBlips;
- (void) showMyBlips;
- (void) showCreateBlip:(PlaceChannel *)place;
@end
