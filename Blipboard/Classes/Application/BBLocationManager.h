//
//  BBLocationManager.h
//  Blipboard
//
//  Created by Jason Fischl on 3/14/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// Top speed for region monitoring
// 10m/s = 22mph
// Given ~400m/tile, a tile is traversed in 40s
static const CLLocationSpeed kMaxRegionMonitorSpeed = 10.0;
static const NSTimeInterval kMinLocationUpdatePeriodShort = 5*60; // 5 minutes
static const NSTimeInterval kMinLocationUpdatePeriodLong = 20*60; // 20 minutes


@interface BBLocationManager : NSObject<CLLocationManagerDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTask;
}

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLLocationManager* statusManager;
@property (nonatomic, strong) CLLocationManager* regionManager;
@property (nonatomic, strong) CLLocationManager* sigLocationManager;

@property (nonatomic, strong) CLLocation* bestEffortAtLocation;
@property (nonatomic, strong) CLLocation* lastReportedLocation;
@property (nonatomic, strong) CLRegion* tile;
@property (nonatomic, strong) NSDate* lastRetrieveTime;

- (id) init;
- (void) startMonitoring;
- (void) stopMonitoring;
- (void) recordLocationServicesAuthorization;
- (void) updateLocationInBackground;
- (void) retrieveLocationWithAccuracy:(CLLocationAccuracy)accuracy
                          withTimeout:(NSTimeInterval)timeout;
- (void) retrieveLocationWithTimeout:(NSTimeInterval)timeout;
- (void) retrieveLocation;
- (void) informUserOfLocationError:(NSError *)error;
- (void) monitorRegionLeave:(CLLocation*)location :(Region*)region;
- (void) beginBackgroundLocationUpdate;
- (void) endBackgroundLocationUpdate;
- (void) backoffLocationUpdates;
- (void) resetBackoffLocationUpdates;
- (void) reportLocation:(CLLocation*)location :(NSString*)reason;

@end
