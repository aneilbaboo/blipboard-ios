//
//  MKMapView+Extensions.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/19/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBLog.h"
#import "BBMapView.h"

@implementation BBMapView {
    BOOL _observerInstalled;
}

-(id)init {
    self = [super init];    
    [self installObserver];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self installObserver];
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self installObserver];
    return self;
}

-(void)dealloc {
    [self uninstallObserver];
}

-(void)installObserver {
    if (!_observerInstalled) {
        NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];

        [notifCenter
         addObserverForName:UIApplicationDidEnterBackgroundNotification
         object:self
         queue:queue
         usingBlock:^(NSNotification *note) {
             [self stopLocationServices];
         }];
        _observerInstalled = YES;
    }
}

-(void)uninstallObserver {
    if (_observerInstalled) {
        NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
        [notifCenter removeObserver:self];
    }
}

- (void)startUserTrackMode
{
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateBackground) {
        BBLog(@"enable user tracking mode");
        [self setShowsUserLocation:YES];
        [self setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
    else {
        BBLog(@"background mode: skip user tracking mode");
    }
}

- (void)stopLocationServices {
    [self setUserTrackingMode:MKUserTrackingModeNone];
    [self setShowsUserLocation:NO];
}

- (void)setShowsUserLocation:(BOOL)showsUserLocation
{
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateBackground) {
        [super setShowsUserLocation:showsUserLocation];
    }
}

- (void)setUserTrackingMode:(MKUserTrackingMode)userTrackingMode
{
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateBackground
        ||
        userTrackingMode == MKUserTrackingModeNone) {
        [super setUserTrackingMode:userTrackingMode];
    }
}

-(void)setUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateBackground
        ||
        mode == MKUserTrackingModeNone) {
        BOOL allowAnimation = animated && SYSTEM_VERSION_LESS_THAN(@"6.0");
        [super setUserTrackingMode:mode animated:allowAnimation];
    }
}

-(void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated {
    BOOL allowAnimation = animated && SYSTEM_VERSION_LESS_THAN(@"6.0") ;
    [super setRegion:region animated:allowAnimation];
}

// treats the map region as {sectionCount} horizontal (latitudinal) sections,
// and centers the map so that coordinate is centered in the nth section (0-based) from the top
//
-(void)centerAtCoordinate:(CLLocationCoordinate2D)coord withSpan:(MKCoordinateSpan)span inLatitudeSection:(NSInteger)section ofSections:(NSInteger)sectionCount animated:(BOOL)animated {
    CGFloat sectionDelta = self.region.span.latitudeDelta / (CGFloat)sectionCount;
    CGFloat northLatitude = (coord.latitude - .5 * sectionDelta) // point is centered vertically in section N
                            - (sectionDelta * ((CGFloat)sectionCount-1.0)); // there are N-1 sections above N
    CGFloat southLatitude = northLatitude + span.latitudeDelta;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((northLatitude + southLatitude) / 2.0,
                                                               coord.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self setRegion:region animated:animated];
}
@end
