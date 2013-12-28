//
//  BBLocationManager.m
//  Blipboard
//
//  Created by Jason Fischl on 3/14/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBLocationManager.h"

static const CGFloat kRetrieveLocationDefaultAccuracy=50.0;
static const CGFloat kRetrieveLocationDefaultTimeout=1.0;
static const CGFloat kBackgroundProcessTimeInterval=10.0;
static const CGFloat kBackgroundProcessReportLocationTimeInterval=2.5;
static NSTimeInterval minLocationUpdatePeriod = kMinLocationUpdatePeriodShort;


@implementation BBLocationManager

-(id) init
{
    self = [super init];
    
    [self setupLocationManagers];
    self->_backgroundTask = UIBackgroundTaskInvalid;
    
    return self;
}

-(void) setupLocationManagers
{
    BBTrace();

    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    BOOL sigLocMonitoringSupported = [CLLocationManager significantLocationChangeMonitoringAvailable];
    if (sigLocMonitoringSupported && self.sigLocationManager == nil) {
        // !jcf! post something to the server so we can have stats on the device caps
        self.sigLocationManager = [[CLLocationManager alloc] init];
        self.sigLocationManager.delegate = self;
    }
    
    BOOL regionMonitoringSupported = [CLLocationManager regionMonitoringAvailable];
    if (regionMonitoringSupported && !self.regionManager) {
        BBLog(@"location: region-manager: created");
        self.regionManager = [[CLLocationManager alloc] init];
        self.regionManager.delegate = self;
    }

    if (self.statusManager==nil) {
        self.statusManager = [[CLLocationManager alloc] init];
        self.statusManager.delegate = self; // !am! we need this always connected
    }
    BBLog(@"location: SignificantLocationChangeMonitor:%@, RegionMonitoring:%@",
          sigLocMonitoringSupported ? @"available" : @"unavailable",
          regionMonitoringSupported ? @"available" : @"unavailable");
}

// to be called when the application enters background mode or is started from the background
-(void) startMonitoring
{
    // if we aren't authenticated, there's no point in continuing with background monitoring
    if (BBAppDelegate.sharedDelegate.authenticated) {
        BBLog(@"start monitoring for location updates");
        assert(self.sigLocationManager);
        self.sigLocationManager.delegate = self;
        self.lastRetrieveTime = 0; // reset the rate limit
        [self.sigLocationManager startMonitoringSignificantLocationChanges];
    }
}

-(void) stopMonitoring
{
    BBLog(@"stop monitoring for location updates");
    [self.sigLocationManager stopMonitoringSignificantLocationChanges];
    self.sigLocationManager.delegate = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    
    [self.regionManager stopMonitoringForRegion:self.tile];
    self.regionManager.delegate = nil;
}

/** Uses location services to discover the user's location
 *
 *  @param accuracy  Minimum required horizontal coordinate accuracy (in meters) - or CLLocationAccuracy___ constant
 *  @param timeout   NSTimeInterval
 */
- (void)retrieveLocationWithAccuracy:(CLLocationAccuracy)accuracy
                         withTimeout:(NSTimeInterval)timeout
{
    NSDate *now = [NSDate date];
    if (!self.lastRetrieveTime || [now timeIntervalSinceDate:self.lastRetrieveTime] > minLocationUpdatePeriod) {
        BBLog(@"location: retrieve with accuracy:%f timeout=%f", accuracy, timeout);
        [self beginBackgroundLocationUpdate];
        self.lastRetrieveTime = now;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLocationFound:) object:@"timeout"];
        
        self.locationManager.desiredAccuracy = accuracy; //kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50; //kCLDistanceFilterNone
        self.bestEffortAtLocation = nil;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        [self performSelector:@selector(onLocationFound:) withObject:@"timeout" afterDelay:timeout];
    }
    else {
        BBLog(@"location: rate limiting retrieval. last request was %fs ago", [now timeIntervalSinceDate:self.lastRetrieveTime]);
        
        // simulate a location find failure only for the FSM. otherwise it's stuck in the wrong state.
        //[_fsm performSelector:@selector(OnLocationError:) withObject:nil afterDelay:0];
    }
}

- (void) retrieveLocationWithTimeout:(NSTimeInterval)timeout
{
    [self retrieveLocationWithAccuracy:kRetrieveLocationDefaultAccuracy withTimeout:timeout];
}

- (void)retrieveLocation
{
    [self retrieveLocationWithAccuracy:kRetrieveLocationDefaultAccuracy withTimeout:kRetrieveLocationDefaultTimeout];
}

- (void) onLocationFound:(NSString *)reason
{
    [self onLocationFound:reason:nil];
}

- (void) onLocationFound:(NSString*)reason :(NSError*)error
{
    [self.locationManager stopUpdatingLocation];
    
    // we can also cancel our previous performSelector:withObject:afterDelay: - it's no longer necessary
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLocationFound:) object:@"timeout"];
    
    if (self.bestEffortAtLocation) { // found something new
        BBLog(@"found location %@", self.bestEffortAtLocation);
        [self reportLocation:self.bestEffortAtLocation :reason];
    }
    else {
        BBLog(@"Did not receive an updated location. Previous location=%@", self.lastReportedLocation);
        self.bestEffortAtLocation = self.lastReportedLocation;
        [self endBackgroundLocationUpdate];
    }
    [self recordLocationServicesAuthorization];
}


- (void)updateLocationInBackground
{
    CLLocation* latest = nil;
    if (self.sigLocationManager.location) {
        latest = self.sigLocationManager.location;
        BBLog(@"location: updateLocationInBackground: using location from significantLocationManager: %@", latest);
    }
    else {
        BBLog(@"location: updateLocationInBackground: no location found");
    }
    
    if (latest) {
        // !jcf! note that we do no install a region manager after getting a location.
        // We also do not use the GPS to get an accurate location fix.
        assert (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground );
        [self reportLocation:latest :@"background-start"];
    }
}

- (void)monitorRegionLeave:(CLLocation*)location :(Region*)region
{
    if (self.tile) {
        BBLog(@"location: region-monitoring: remove previous tile[%@]", self.tile);
        [self.regionManager stopMonitoringForRegion:self.tile];
        self.tile = nil;
    }
    
    if ([CLLocationManager regionMonitoringAvailable]) {
        if (location.speed < kMaxRegionMonitorSpeed) {
            BBLog(@"location: region-monitoring: start monitoring: speed:%f m/s under %f [%@,%@ (%@)]",
                  location.speed, kMaxRegionMonitorSpeed,
                  region.latitude,region.longitude,region.radius);
            
            CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([region.latitude doubleValue],[region.longitude doubleValue]);
            CLLocationDistance radius = [region.radius doubleValue];
            if (radius > self.locationManager.maximumRegionMonitoringDistance) {
                radius = self.locationManager.maximumRegionMonitoringDistance;
            }
            
            self.tile = [[CLRegion alloc] initCircularRegionWithCenter:coords radius:radius identifier:@"tile"];
            [self.regionManager startMonitoringForRegion:self.tile];
        }
        else {
            BBLog(@"location: region-monitoring: disable: speed:%f > %f m/s", location.speed, kMaxRegionMonitorSpeed);
        }
    }
    else {
        BBLog(@"location: region-monitoring: not available");
    }
}


- (void) backoffLocationUpdates
{
    minLocationUpdatePeriod = kMinLocationUpdatePeriodLong;
    BBLog(@"location: backoff location updates to %f", minLocationUpdatePeriod);
}

- (void) resetBackoffLocationUpdates
{
    minLocationUpdatePeriod = kMinLocationUpdatePeriodShort;
    BBLog(@"location: reset backoff location updates to %f", minLocationUpdatePeriod);
}


// if user has denied location services, shows a nag box asking them to turn it on
- (void)informUserOfLocationError:(NSError *)error {
    if (error && [error.domain isEqualToString:kCLErrorDomain] && error.code==kCLErrorDenied) {
        BBLog(@"location: can't determine location: %@", error);
        BBAppDelegate.sharedDelegate.mainViewController.locateButton.hidden = NO;
        [self recordLocationServicesAuthorization];
        RIButtonItem *okItem = [RIButtonItem item];
        okItem.label = @"OK";
        okItem.action = ^{}; // no-op block
        NSString *message;
        if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
            message = @"Please enable location services.\nSettings >\nLocation Services >\nBlipboard";
        }
        else {
            message = @"Please enable location services.\nSettings > Privacy > Location Services > Blipboard";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't determine location"
                                                        message:message
                                               cancelButtonItem:okItem
                                               otherButtonItems:nil];
        [alert show];
    }    
}

/** reports a CLLocation to the server with a reason
 *
 * @param location CLLocation to report
 */
- (void)reportLocation:(CLLocation*)location :(NSString*)reason
{
    __block CLLocation *blockLocation = location;
    __block void (^reportedLocation)(Region *, ServerModelError *) = ^(Region *region, ServerModelError *error){
        if (error) {
            if ([error.domain isEqualToString:NetworkRequestErrorDomain] &&
                error.code==ASIAuthenticationErrorType) {
                BBLog(@"location: authentication error in background:%@",error);
                // 401 error while in background - move to state which prevents further location reports
                [self stopMonitoring];
            }
            else {
                BBLog(@"location: error reporting location: %@", error);
                [self backoffLocationUpdates];
            }
        }
        else {
            BBLog(@"location: reportedLocation: center=%@,%@ r=%@", region.latitude, region.longitude, region.radius);
            self.lastReportedLocation = blockLocation;
            [self resetBackoffLocationUpdates];
            [self monitorRegionLeave:blockLocation:region];
        }
        [self endBackgroundLocationUpdate];
    };
    
    // when either of these requests successfully complete, lastReportedLocation will be = location
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground ) {
        BBLog(@"location: (background mode) location:%@, reason:%@",location,reason);
        
        if (BBAppDelegate.sharedDelegate.myAccount) {
            [BBAppDelegate.sharedDelegate.myAccount reportLocationSync:location
                                                               timeout:(kBackgroundProcessReportLocationTimeInterval)
                                                                reason:reason
                                                                 block:reportedLocation];
        }
        else {
            BBLog(@"location: no account available to reportLocation on");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopMonitoring];
                [self endBackgroundLocationUpdate];
            });
        }
    }
    else {
        BBLog(@"location: (foreground mode) location:%@, reason:%@",location,reason);
        
        [BBAppDelegate.sharedDelegate.myAccount reportLocation:location
                                                        reason:reason
                                                         block:reportedLocation];
    }
    
    [Flurry setLatitude:location.coordinate.latitude
                       longitude:location.coordinate.longitude
              horizontalAccuracy:location.horizontalAccuracy
                verticalAccuracy:location.verticalAccuracy];
}


- (void)beginBackgroundLocationUpdate
{
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground && _backgroundTask == UIBackgroundTaskInvalid) {
        BBLog(@"location: beginning background location update")
        _backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            BBLog(@"location: background task expired");
            [self endBackgroundLocationUpdate];
        }];
    }
}

- (void)endBackgroundLocationUpdate
{
    if (_backgroundTask != UIBackgroundTaskInvalid) {
        BBTrace();
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
}

NSString * const kUserEnabledLocationServices=@"UserEnabledLocationServices";

- (void)recordLocationServicesAuthorization {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstRecordingOfState = ![defaults objectForKey:kUserEnabledLocationServices];
    BOOL previousState = [defaults boolForKey:kUserEnabledLocationServices];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL stateDetermined = status != kCLAuthorizationStatusNotDetermined;
    BOOL currentState =  status != kCLAuthorizationStatusDenied;
    
    if (stateDetermined) {
        if (firstRecordingOfState || previousState!=currentState) {
            BBLog(@"location services authorization changed from %d to %d",previousState,currentState);
            if (currentState) {
                [Flurry logEvent:kFlurryUserEnabledLocation];
            }
            else {
                [Flurry logEvent:kFlurryUserDisabledLocation];
            }
            [defaults setBool:currentState forKey:kUserEnabledLocationServices];
            [defaults synchronize];
        }
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate
- (void) locationManager:(CLLocationManager*) manager
     didUpdateToLocation:(CLLocation*) newLocation
            fromLocation:(CLLocation*) oldLocation
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (manager == self.locationManager) {
        BBLog(@"location: update: age=%f accuracy=%f new=%@ ", locationAge, newLocation.horizontalAccuracy, newLocation);
        if (locationAge > 5.0) return; // do not rely on cached measurements
        
        // test that the horizontal accuracy does not indicate an invalid measurement
        if (newLocation.horizontalAccuracy < 0) return;
        
        // test the measurement to see if it is more accurate than the previous measurement
        if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy >= newLocation.horizontalAccuracy) {
            // store the location as the new "best effort"
            self.bestEffortAtLocation = newLocation;
            BBLog(@"location: updated best=%@", self.bestEffortAtLocation);
            
            if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
                [self onLocationFound:@"Found"];
            }
        }
    }
    else if (manager == self.sigLocationManager) { // must be significant location change manager - may be from an earlier app start
        BBLog(@"location: significant age=%f accuracy=%f new=%@ ", locationAge, newLocation.horizontalAccuracy, newLocation);
        self.bestEffortAtLocation = newLocation;
        [self retrieveLocation];
    }
}

- (void) locationManager:(CLLocationManager*) manager
        didFailWithError:(NSError*) error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a
    // timeout that will stop the location manager to save power.
    if (manager == self.sigLocationManager) {
        BBLog(@"location: significant error=%@", error);
    }
    else if (manager == self.locationManager) {
        BBLog(@"location: location error=%@", error);
        if ([error code] != kCLErrorLocationUnknown) {
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
            [self onLocationFound:@"Failed":error];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager
          didEnterRegion:(CLRegion *)region
{
    BBLog(@"location: region-monitoring: entered '%@'", region);
    BBLog(@"location: region-monitoring: monitoring %d regions: %@", [manager.monitoredRegions count], manager.monitoredRegions);
}

- (void) locationManager:(CLLocationManager *)manager
           didExitRegion:(CLRegion *)region
{
    BBLog(@"location: region-monitoring: left '%@'", region);
    BBLog(@"location: region-monitoring: monitoring %d regions: %@", [manager.monitoredRegions count], manager.monitoredRegions);
    [manager stopMonitoringForRegion:region];
    
    // report updated location
    if ([region.identifier isEqualToString:@"tile"]) {
        [self retrieveLocation];
    }
}

- (void)locationManager:(CLLocationManager *) manager
monitoringDidFailForRegion:(CLRegion *) region
              withError:(NSError *) error
{
    BBLog(@"location: region-monitoring: error: %@", error);
    [manager stopMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BBLog(@"status:%d",status);
    [self recordLocationServicesAuthorization];
}
@end
