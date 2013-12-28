//
//  MKMapView+Extensions.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/19/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SystemVersion.h"

@interface BBMapView : MKMapView
- (void)setShowsUserLocation:(BOOL)showsUserLocation;
- (void)setUserTrackingMode:(MKUserTrackingMode)userTrackingMode;

- (void)startUserTrackMode;
- (void)stopLocationServices;
-(void)centerAtCoordinate:(CLLocationCoordinate2D)coord withSpan:(MKCoordinateSpan)span inLatitudeSection:(NSInteger)section ofSections:(NSInteger)sectionCount animated:(BOOL)animated;
@end
