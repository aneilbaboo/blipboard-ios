//
//  ChannelListViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "GuruListViewController.h"
#import "ChannelDetailViewController.h"
#import "BBGenericBarButtonItem.h"
#import "SystemVersion.h"
#import "SlideoutViewController.h"

@implementation GuruListViewController {
    CLLocationCoordinate2D _coordinate;
    NSInteger _tuneInTotal;
}

+(id)guruListViewControllerWithCoordinate:(CLLocationCoordinate2D)coordinate context:(NSString *)context {
    GuruListViewController *glvc = [[GuruListViewController alloc] initWithNibName:nil bundle:nil];
    glvc->_coordinate = coordinate;
    glvc->_tuneInTotal = 0;
    glvc.context = context;

    return glvc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Follow Gurus";
    self.view.backgroundColor = [UIColor bbGridPattern];
    
    self.header.backgroundColor = [UIColor bbHeaderPattern];
    self.header.layer.shadowOffset = CGSizeMake(0, 1);
    self.header.layer.shadowRadius = 3;
    self.header.layer.shadowColor = UIColor.blackColor.CGColor;
    self.header.layer.shadowOpacity = .5;
    
    self.headerTitle.font = [UIFont bbFont:18];
    self.headerTitle.textColor = [UIColor bbGray5];
    
    self.channelTable.delegate = self;
    self.channelTable.listName = [NSString stringWithFormat:@"%@-guru-list",self.context];
    //self.channelTable.topInset = 5;
    self.channelTable.header = self.header;
    
    // detect if being presented modally; add a "Done" button
    if (self.presentingViewController) {
        self.navigationItem.rightBarButtonItem = [BBGenericBarButtonItem barButtonItem:@"Done"
                                                                                target:self
                                                                                action:@selector(donePressed:)];
    }
    else {
        [[SlideoutViewController sharedController] addSlideoutMenu:self];
        [[SlideoutViewController sharedController] addMenuButtonAndBadge:self];
    }
    
    [self.activityIndicator setColor:[UIColor bbDarkBlue]];
    [self.activityIndicator startAnimating];
        
    [BBAppDelegate.sharedDelegate.myAccount
     getNearbyChannelsForRegion:MKCoordinateRegionMake(_coordinate, MKCoordinateSpanMake(.001, .001))
     withScope:NearbyChannelScopeCity
     ofType:ChannelTypeUser
     matchingPrefix:nil
     block:^(NSMutableArray *channels, Paging *paging, ServerModelError *error) {
         self.channels = channels;
         [self.activityIndicator stopAnimating];
     }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setChannels:(NSArray *)channels {
    self.channelTable.channels = channels;
}

-(NSArray *)channels {
    return self.channelTable.channels;
}

-(void)donePressed:(id)sender {
    [self logToFlurry];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)logToFlurry {
    BBLog(@"total-follows=%d",_tuneInTotal);
    NSString *eventName = [NSString stringWithFormat:@"%@-%@",kFlurryGuruList,self.context];
    [Flurry logEvent:eventName
               withParameters:@{@"total-follows":[@(_tuneInTotal) stringValue]}];
}

#pragma mark -
#pragma mark BBNavigationControllerEvents

-(void)navigationController:(UINavigationController *)navigationController willPopViewController:(UIViewController *)controller animated:(BOOL)animated {
    if (controller==self) {
        [self logToFlurry];
    }
}

#pragma mark -
#pragma mark ChannelTableViewDelegate
-(void)channelTableView:(ChannelTableView *)channelTable didSelectChannel:(Channel *)channel {
    ChannelDetailViewController *channelDetail = [[ChannelDetailViewController alloc]
                                                  initWithChannel:channel];
    [self.navigationController pushViewController:channelDetail animated:YES];
}

-(void)channelTableView:(ChannelTableView *)channelTable didTuneIn:(Channel *)channel {
    
}

-(void)channelTableView:(ChannelTableView *)channelTable didTuneOut:(Channel *)channel {
    
}


@end
