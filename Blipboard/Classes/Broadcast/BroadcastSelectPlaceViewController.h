//
//  BroadcastSelectPlaceViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BroadcastPlaceCell.h"
#import "Cancellation.h"
#import "PlaceChannel.h"
#import "Blip.h"
#import "BroadcastDelegate.h"

/** First step in the broadcast process: user selects a place
 *
 */
@interface BroadcastSelectPlaceViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,weak) id<BroadcastFlowDelegate> delegate; // just hold on to this delegate and pass it on
+ (id)viewControllerWithDelegate:(id<BroadcastFlowDelegate>)delegate;

@end
