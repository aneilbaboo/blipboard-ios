//
//  ServerModel.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BBError.h"
#import "ServerModelError.h"
#import "Cancellation.h"

NSString *MKCoordinateRegionAsBoundsString(MKCoordinateRegion region);

typedef void (^StatusHandler)(ServerModelError *error);
@interface ServerModel : NSObject  <RKObjectLoaderDelegate>
@property (nonatomic,strong) NSString *id;  // not used by all subclasses
                                            // but needed for ServerInstanceChangeObserver
+ (void)setGlobalStatusCodeHandler:(HTTPStatusCode)code block:(StatusHandler)block;
+ (StatusHandler)globalStatusCodeHandler:(HTTPStatusCode)code;
+ (RKDynamicObjectMapping *)dictionaryMapping;

-(void)changeServerInstancesUsingKeyValues:(NSDictionary *)keyValues;

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path
                                           withMethod:(RKRequestMethod)method
                                            andParams:(NSDictionary *)params 
                                  andBackgroundPolicy:(RKRequestBackgroundPolicy)policy
                                           andMapping:(RKObjectMapping *)mapping 
                                                block:(ServerModelBlock)block;

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path 
                                           withMethod:(RKRequestMethod)method 
                                            andParams:(NSDictionary *)params 
                                                block:(ServerModelBlock)block;

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path 
                                           withMethod:(RKRequestMethod)method 
                                            andParams:(NSDictionary *)params 
                                  andBackgroundPolicy:(RKRequestBackgroundPolicy)policy 
                                                block:(ServerModelBlock)block;

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path 
                                                block:(ServerModelBlock)block;

@end

#define logRKRequest(request) \
logRKRequestInfo(request,@"");


#define logRKRequestInfo(request,fmt,...) \
BBLog(@"#%X %@ %@ %@ %@", \
(uint)request, \
[request methodName], \
request.URL.relativePath, \
request.params ? [NSString stringWithFormat:@"PARAMS: %@",request.params] : @"(no params)", \
[NSString stringWithFormat:fmt,##__VA_ARGS__]);
