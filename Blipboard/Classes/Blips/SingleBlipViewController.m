//
//  BlipDetailViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/12/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SingleBlipViewController.h"
#import "ChannelDetailViewController.h"
#import "BlipPin.h"

// shows a single blip; blip detail view controller cancel button
// acts as a back button; no listview   
@implementation SingleBlipViewController

+(id)blipDetailViewController:(Blip *)blip {
    SingleBlipViewController *controller = [[SingleBlipViewController alloc] initWithNibName:nil bundle:nil];
    controller.blipDetailView = [BlipDetailView blipDetailView];
    controller.blipDetailView.blip = blip;
    controller.blipDetailView.disableNavBar = YES;
    controller.blipDetailView.delegate = controller;
    return controller;
}

-(Blip *)blip {
    return self.blipDetailView.blip;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.userInteractionEnabled = NO;
    self.mapView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    BBTrace();
    [super viewWillAppear:animated];

    [self.blipDetailView addToViewController:self];
    [self.blipDetailView observeKeyboard];
    
    // map region with blip centered
    MKCoordinateRegion blipRegion = MKCoordinateRegionMakeWithDistance(self.blip.coordinate, 1000, 1000);
    
    // map region with blip in top 1/4 of map:
    CGFloat regionLatitude =  self.blip.coordinate.latitude - blipRegion.span.latitudeDelta/4;
    CGFloat regionLongitude = self.blip.coordinate.longitude - blipRegion.span.longitudeDelta/4;
    CLLocationCoordinate2D regionCenter = CLLocationCoordinate2DMake(regionLatitude, regionLongitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(regionCenter,1000,1000);
    
    [self.mapView setRegion:region animated:NO];
    
    __unsafe_unretained SingleBlipViewController *weakSelf = self;
    [self.blipDetailView setCancelAction:^{
        BBLog(@"weakSelf=%@",weakSelf);
        if (weakSelf.navigationController) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else if (weakSelf.presentingViewController) {
            [weakSelf dismissModalViewControllerAnimated:YES];
        }
        [weakSelf.blipDetailView unobserveKeyboard];
    }];

    [self.mapView addAnnotation:self.blip];
    [self.blipDetailView configureWithBlip:self.blip];
    
    [self.blipDetailView setLayout:BlipDetailLayoutCompressed animated:NO  completion:^{
        weakSelf.blipDetailView.navBar.hidden = YES;
    }];

}

-(void)viewWillDisappear:(BOOL)animated {
    [self.blipDetailView unobserveKeyboard];
}

#pragma mark -
#pragma mark MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    BlipPin *pin = [[BlipPin alloc] init];
    [pin configureWithBlip:self.blip state:BlipPinStateForeground animate:YES delay:0];
    return pin;
}

#pragma mark -
#pragma mark BBNavigationControllerEvents

-(void)navigationController:(UINavigationController *)navigationController willPopViewController:(UIViewController *)controller animated:(BOOL)animated {
    if (controller==self) {
        [self.blipDetailView removeFromViewController];
        [self.blipDetailView unobserveKeyboard];
    }
}

#pragma mark -
#pragma mark BlipDetailViewDelegate
-(void)blipDetailView:(BlipDetailView *)blipDetailView channelPressed:(Channel *)channel {
    ChannelDetailViewController *cdvc = [[ChannelDetailViewController alloc] initWithChannel:channel];
    [self.navigationController pushViewController:cdvc animated:YES];
}

-(void)blipDetailViewDidTuneIn:(BlipDetailView *)blipDetailView {
    
}

-(void)blipDetailViewDidTuneOut:(BlipDetailView *)blipDetailView {
    
}

-(void)blipDetailViewDidHide:(BlipDetailView *)blipDetailView {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
