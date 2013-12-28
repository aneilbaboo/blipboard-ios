//
//  BroadcastSelectPlaceViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 8/6/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "Flurry+Blipboard.h"

#import "Account.h"
#import "BBAppDelegate.h"
#import "BBGenericBarButtonItem.h"
#import "BBLog.h"
#import "BroadcastTextInputViewController.h"
#import "BroadcastSelectPlaceViewController.h"
#import "ChannelDetailViewController.h"
#import "ErrorViewController.h"
#import "UIColor+BBColors.h"
#import "UIView+position.h"
#import "BBDropDownToastView.h"


@implementation BroadcastSelectPlaceViewController {
    NSMutableArray* _placeChannels;
    NSMutableArray* _filteredPlaceChannels;
    
    UISearchBar* _channelSearchBar;
    UISearchDisplayController* _searchDisplayController;
    Cancellation* _cancellation;
}

+ (id)viewControllerWithDelegate:(id<BroadcastFlowDelegate>)delegate {
    BBTrace();
    BroadcastSelectPlaceViewController *bvc = [[BroadcastSelectPlaceViewController alloc] initWithNibName:nil bundle:nil];
    bvc.delegate = delegate;
    return bvc;
}

- (void)_initialize {
    BBTraceLevel(4);
    int width = [[UIScreen mainScreen] bounds].size.width;
    int height = [[UIScreen mainScreen] bounds].size.height;
    _cancellation = [Cancellation cancellation];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    // initialize table
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, width, height - 61) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = YES;
    _tableView.backgroundColor = [UIColor bbGridPattern];
    
    [self.view addSubview:_tableView];
        
    // add the search controller
    _channelSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _channelSearchBar.placeholder = @"Search for a place";
    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_channelSearchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsTableView.delegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    [self.tableView setTableHeaderView:_channelSearchBar];
    
    //[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
    UIBarButtonItem *cancelButton = [BBGenericBarButtonItem barButtonItem:@"Cancel"
                                                                   target:self
                                                                   action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.title = @"Create a Blip";
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self _initialize];   
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    // never called because we're not loading a nib
    [super viewDidLoad];
    [self _initialize];
    
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsTableView.delegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    
    [_cancellation cancel];
    
    id<CancellableOperation> cancellable;
    [BBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    cancellable = [BBAppDelegate.sharedDelegate.myAccount
                   getNearbyChannelsForRegion:BBAppDelegate.sharedDelegate.mainViewController.mapView.region
                   ofType:ChannelTypePlace block:^(NSMutableArray *channels, Paging *paging, ServerModelError *error) {
                       [BBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                       if (!error) {
                           _placeChannels = channels;
                           if (_placeChannels.count == 0) {
                               // !jcf! do something when there are no places.
                               //[self.mapToast showText:@"No places nearby. Please pan/zoom the map." forSeconds:5];
                           }
                           [self.tableView reloadData];
                       }
                       else {
                           BBLog(@"error: %@",error);
                           ErrorViewController *evc = [ErrorViewController errorViewControllerWithError:error];
                           if (![self.navigationController.topViewController isKindOfClass:[ErrorViewController class]]) {
                               [self.navigationController pushViewController:evc animated:YES];
                           }
                       }
                   }];
    [_cancellation addOperation:cancellable];
}

- (void)viewDidAppear:(BOOL)animated {
    BBTrace();
    [Heatmaps track:self.view withKey:@"92e49bf7098d3dd4-29686114"];
}

- (void)viewDidUnload
{
    BBTrace();
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Actions
- (void)cancelPressed:(id)sender
{
    BBTrace();
    [Flurry logEvent:kFlurryBroadcastPlaceCancel];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    //[self.delegate broadcastViewControllerDidCancel:self];
}

- (void)clearPlaces
{
    BBTrace();
}


#pragma mark -
#pragma mark UITableView methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaceChannel* channel = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BBLog(@"tableView=searchResultsTableView");
        channel = [_filteredPlaceChannels objectAtIndex:[indexPath row]];
        //[self.searchDisplayController setActive:FALSE animated:YES];
    }
    else {
        BBLog(@"tableView=regular tableView");
        channel = [_placeChannels objectAtIndex:[indexPath row]];
    }
    
    [Flurry logEvent:kFlurryBroadcastPlaceSelect
               withParameters:[NSDictionary dictionaryWithObject:channel.id forKey:@"id"]];

    BroadcastTextInputViewController *btivc = [BroadcastTextInputViewController viewControllerWithPlaceChannel:channel andDelegate:self.delegate];
    [self.navigationController pushViewController:btivc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)view cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BroadcastPlaceCell *cell = (BroadcastPlaceCell *)[self.tableView dequeueReusableCellWithIdentifier:BroadcastPlaceCell.reuseIdentifier];
    if (!cell) {
        cell = [BroadcastPlaceCell broadcastPlaceCell];
    }
    
    NSUInteger row = [indexPath row];
    if (view == self.searchDisplayController.searchResultsTableView) {
        [cell configureWithChannel:[_filteredPlaceChannels objectAtIndex:row]];
    }
    else {
        [cell configureWithChannel:[_placeChannels objectAtIndex:row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 44; 
}

- (NSInteger)tableView:(UITableView *)view numberOfRowsInSection:(NSInteger)section
{
    if (view == self.searchDisplayController.searchResultsTableView) {
        BBLog(@"search results => %u", _filteredPlaceChannels.count);
        return _filteredPlaceChannels.count;
    }
    else {
        BBLog(@"place results => %u", _placeChannels.count);
        return _placeChannels.count;
    }
}

//-(void)showTextInputController:(PlaceChannel *)channel {
//    BroadcastTextInputViewController *btivc = [BroadcastTextInputViewController broadcastTextInputViewControllerWithPlaceChannel:channel andDelegate:self.delegate];
//    [self.searchDisplayController setActive:NO animated:YES];
//    _filteredPlaceChannels = nil;
//    [self.navigationController pushViewController:btivc animated:YES];
//}

#pragma mark -
#pragma mark SearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    BBLog(@"search %@", searchString);
    [_cancellation cancel];
    
    CLLocationCoordinate2D center = BBAppDelegate.sharedDelegate.mainViewController.mapView.region.center;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 30000, 30000);
    id<CancellableOperation> cancellable;
    cancellable = [BBAppDelegate.sharedDelegate.myAccount
                   getNearbyChannelsForRegion:region
                   withScope:NearbyChannelScopeRegion
                   ofType:ChannelTypePlace
                   matchingPrefix:searchString
                   block:^(NSMutableArray *channels, Paging *paging, ServerModelError *error) {
                       //BBLog(@"result => %@", channels);
                       if (!error) {
                           _filteredPlaceChannels = channels;
                           if (channels.count == 0) {
                               // !jcf! do something when there are no places.
                               //[self.mapToast showText:@"No places nearby. Please pan/zoom the map." forSeconds:5];
                           }
                           //BBLog(@"reloading data");
                           [_searchDisplayController.searchResultsTableView reloadData];
                           // !am! as if Apple didn't make this complicated enough already,
                           //      for God knows what reason, each time user cancels out
                           //      of a search and tries searching again,
                           //      a new searchResultsTableView is created
                           //  So make sure the new table's delegate is set
                           _searchDisplayController.searchResultsTableView.delegate = self;
                       }
                       else {
                           BBLog(@"error: %@",error);
                           ErrorViewController *evc = [ErrorViewController errorViewControllerWithError:error];
                           if (![self.navigationController.topViewController isKindOfClass:[ErrorViewController class]]) {
                               [self.navigationController pushViewController:evc animated:YES];
                           }
                       }
                   }];
    [_cancellation addOperation:cancellable];
    return NO;
}

@end
