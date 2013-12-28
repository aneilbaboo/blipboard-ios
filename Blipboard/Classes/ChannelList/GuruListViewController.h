//
//  ChannelListViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelTableView.h"
#import "BBNavigationController.h"
@class GuruListViewController;

@interface GuruListViewController : UIViewController <ChannelTableViewDelegate,BBNavigationControllerEvents>

@property (nonatomic,strong) NSString *context; // for flurry analytics

@property (nonatomic,weak) IBOutlet ChannelTableView *channelTable;
@property (nonatomic,weak) IBOutlet UIView *header;
@property (nonatomic,weak) IBOutlet UILabel *headerTitle;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;

+(id)guruListViewControllerWithCoordinate:(CLLocationCoordinate2D)coordinate context:(NSString *)context;

-(void)setChannels:(NSArray *)channels;
-(NSArray *)channels;

@end
