//
//  BlipDetailViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/12/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BlipDetailView.h"
@interface SingleBlipViewController : UIViewController <MKMapViewDelegate,BBNavigationControllerEvents,BlipDetailViewDelegate>
@property (nonatomic,strong) BlipDetailView *blipDetailView;
@property (nonatomic,weak) IBOutlet MKMapView *mapView;

+(id)blipDetailViewController:(Blip *)blip;

@end
