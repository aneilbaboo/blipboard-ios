//
//  ResultDelegator.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <objc/message.h>
#import <RestKit/RestKit.h>
#import "ServerModel.h"
#import "ServerModelResultContext.h"
#import "ServerModelRequests.h"
#import "BBLog.h"
#import "Flurry+Blipboard.h"
#import "NSObject+BaseClassMethod.h"

NSString * const RKRequestMethod_ToString[] = {
    @"GET",
    @"POST",
    @"PUT",
    @"DELETE",
    @"HEAD"
};
static NSMutableDictionary *globalStatusCodeHandlers;

@implementation ServerModel

+ (void)setGlobalStatusCodeHandler:(HTTPStatusCode)code block:(StatusHandler)block {
    [globalStatusCodeHandlers setValue:block forKey:[NSString stringWithFormat:@"%d",code]];
}

+ (StatusHandler)globalStatusCodeHandler:(HTTPStatusCode)code {
    return [globalStatusCodeHandlers objectForKey:[NSString stringWithFormat:@"%d",code]];
}


+(void)load {
    globalStatusCodeHandlers = [NSMutableDictionary dictionaryWithCapacity:1];
}

+(RKObjectMapping *)mapping {
    return nil;
}

// maps a JSON dictionary
//    { key1: { model-key-value-data }, key2: { model-key-value-data }, ...}
// to an an NSMutableDictionary:
//    { key1: serverModelInstance1, key2: serverModelInstance2 }
+(RKDynamicObjectMapping *)dictionaryMapping {
    RKDynamicObjectMapping *mapping = [RKDynamicObjectMapping dynamicMapping];
    mapping.objectMappingForDataBlock = ^(id data) {
        NSDictionary *dict = data;
        NSArray *keys = [dict allKeys];
        RKObjectMapping* dataMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
        for (NSString *key in keys) {
            [dataMapping mapKeyPath:key toRelationship:key withMapping:[self mapping]];
        }
        return dataMapping;
    };
    return mapping;
}

#pragma mark -
#pragma mark Change coordination

/**
 * All model instances of the same class with the same .id
 *     are updated for the keyValues provided in the keyValues dict.
 *     Additionally, any observers registered with observeServerInstaneChanges
 *     are notified.
 */
-(void)changeServerInstancesUsingKeyValues:(NSDictionary *)keyValues {

    for (NSString *key in keyValues.keyEnumerator) {

        // !am! originally wrote this to test carefully for existence
        //  of set{Key}: method exists, KVC does't care - it uses heuristics to set the field
//        BOOL firstIsLetter = [[NSCharacterSet letterCharacterSet] characterIsMember:[key characterAtIndex:0]];
//        NSString *capitalizeKey =  firstIsLetter ? [key capitalizedString] : key;
//        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:",capitalizeKey
//                                             ]);
        
        SEL selector = NSSelectorFromString(key); // only look for the getter; good enough for KVC
        Class baseClass = [[self class] baseClassForInstanceMethod:selector];
        
        NSString *notifName = [self instanceNotificationNameForClass:baseClass];

        // send the notification to the right base class notification name:
        // this mechanism assures the updating Account123.desc
        //      produces a notification Channel123 since Channel is the lowest
        //      base class that contains a setDesc: method
        //
        [[NSNotificationCenter defaultCenter]
         postNotificationName:notifName
         object:self
         userInfo:@{key:keyValues[key]}];
    }
}

-(void)setId:(NSString *)id {
    if (_id) {
        [self _removeChangeObserverForInstances:self];
    }
    [self willChangeValueForKey:@"id"];
    _id = id;
    [self didChangeValueForKey:@"id"];
    if (id) {
        [self _addChangeObserverForInstances:self selector:@selector(_didChangeServerInstanceKeyValues:)];
    }
}

-(void)dealloc {
    [[RKClient sharedClient].requestQueue cancelRequestsWithDelegate:self];
    if (_id) {
        self.id = nil; // remove change observer
    }
}

//
// Helper fns for installing observers that notifications
//     produced by changeServerInstancesUsingKeyValues
//
// !am! This is an internal method only.
//      Controls or other object which wish to detect changes to a model should use KVO.
//      The problem with adding the control as an observer for this notification name
//      is that since the order of notifications is undefined, the control could get
//      the notification before the model it is interested in has been update.
//
-(void)_addChangeObserverForInstances:(id)observer selector:(SEL)selector {
    NSArray *hierarchy = [[self class] classHierarchyToAncestor:[ServerModel class]];

    // install a notification observer for each class in the hierarchy
    // e.g., if we have:  ServerModel > Channel > UserChannel > Account
    //       and we have account.id=@"123",
    //       This installs observers for "Channel123", "UserChannel123" and "Account123"
    
    for (Class class in hierarchy) {
        NSString *notifName = [self instanceNotificationNameForClass:class];
        assert(notifName);
        
        [[NSNotificationCenter defaultCenter]
         addObserver:observer selector:selector
         name:notifName
         object:nil];
    }
}

-(void)_removeChangeObserverForInstances:(id)observer {
    NSArray *hierarchy = [[self class] classHierarchyToAncestor:[ServerModel class]];
    
    for (Class class in hierarchy) {
        NSString *notifName = [self instanceNotificationNameForClass:class];
        assert(notifName);
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:observer name:notifName object:nil];
    }
}

// internal notification response method
-(void)_didChangeServerInstanceKeyValues:(NSNotification *)notification {
    BBLog(@"%@",notification);
    NSDictionary *keyValues = notification.userInfo;
    BOOL objectIsSubclass = [notification.object isKindOfClass:[self class]];
#if !defined (CONFIGURATION_Release)
    // make sure we're receiving a change notification from an instance with the same class & id
    BOOL objectIsSuperclass = [self isKindOfClass:[notification.object class]];
    assert((objectIsSubclass || objectIsSuperclass) &&
           [[(ServerModel *)notification.object id] isEqualToString:self.id]);
#endif
    if (objectIsSubclass) {
        // object may have additional keys - be careful
        for (NSString *key in keyValues.keyEnumerator) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:keyValues[key]  forKey:key];
            }
        }
    }
    else {
        // object is a superclass; guaranteed to have all the keys
        for (NSString *key in keyValues.keyEnumerator) {
            if ([self respondsToSelector:NSSelectorFromString(key)]) {
                [self setValue:keyValues[key]  forKey:key];
            }
        }
    }
}

// internal helper method
-(NSString *)instanceNotificationNameForClass:(Class)class {
    if (self.id) {
        return [NSString stringWithFormat:@"%s%@",class_getName(class), self.id];
    }
    else {
        return nil;
    }
}


#pragma mark  interface methods
- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path
                                withMethod:(RKRequestMethod)method
                                 andParams:(NSDictionary *)params 
                       andBackgroundPolicy:(RKRequestBackgroundPolicy)policy 
                                andMapping:(RKObjectMapping *)mapping 
                                     block:(ServerModelBlock)block 
{
    __block ServerModelResultContext *resultContext = [[ServerModelResultContext alloc] 
                                                       initWithModel:self  // keep a strong ref to self (the model) until this request completes
                                                       andBlock:block];
    
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:path
                                                    usingBlock:^(RKObjectLoader *loader)
     {
         if (mapping) {
             loader.objectMapping = mapping;
         }
         resultContext.request = loader;
         loader.delegate = self;
         loader.backgroundPolicy = policy;
         loader.userData = resultContext;
         loader.params = params;
         loader.method = method;
         loader.timeoutInterval = 15;
         loader.queue = nil;

         [[ServerModelRequests sharedRequests] rememberRequest:loader];
         logRKRequest(loader);
     }];
    
    return resultContext;
}


- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path
                                withMethod:(RKRequestMethod)method
                                 andParams:(NSDictionary *)params
                                     block:(ServerModelBlock)block
{
    return [self loadObjectsAtResourcePath:path
                                withMethod:method
                                 andParams:params
                       andBackgroundPolicy:RKRequestBackgroundPolicyNone
                                andMapping:nil 
                                     block:block];
}

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path 
                                withMethod:(RKRequestMethod)method 
                                 andParams:(NSDictionary *)params 
                       andBackgroundPolicy:(RKRequestBackgroundPolicy)policy 
                                     block:(ServerModelBlock)block
{
    return [self loadObjectsAtResourcePath:path 
                                withMethod:method
                                 andParams:params
                       andBackgroundPolicy:policy
                                andMapping:nil 
                                     block:block];
}

- (id<CancellableOperation>)loadObjectsAtResourcePath:(NSString *)path 
                                     block:(ServerModelBlock)block
{
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodGET
                                 andParams:nil
                       andBackgroundPolicy:RKRequestBackgroundPolicyNone
                                andMapping:nil
                                     block:block];
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjectDictionary:(NSDictionary *)dictionary {
    ServerModelResultContext *resultContext = objectLoader.userData;
    resultContext.result = dictionary;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader willMapData:(inout id *)mappableData {
#if 0 //defined (CONFIGURATION_Debug)
    logRKRequest(@" => %@", *mappableData);
#endif
}


// Error cases:
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error  {
    
    ServerModelResultContext *resultContext = objectLoader.userData;
    if (!resultContext.isCancelled) {
        resultContext.error = [ServerModelError errorWithNSError:error
                                                      andRequest:objectLoader];
        
        logRKRequestInfo(objectLoader,
                         @" => %d %@: '%@'",
                          resultContext.error.statusCode,
                          resultContext.error.type,
                          resultContext.error.message);
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    ServerModelResultContext *resultContext = request.userData;
    
    if (!resultContext.isCancelled) {
        resultContext.error = [ServerModelError errorWithNSError:error
                                                      andRequest:request];    

        logRKRequestInfo(request, @" => %d %@: '%@'",
                         resultContext.error.statusCode,
                         resultContext.error.type,
                         resultContext.error.message);    }
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader {
    ServerModelResultContext *resultContext = objectLoader.userData;
    if (!resultContext.isCancelled) {
        logRKRequestInfo(objectLoader, @" => %@",
                         [[objectLoader response] bodyAsString]);
        

        resultContext.error = [ServerModelError errorWithDomain:BBNetworkErrorDomain 
                                                           code:BBNetworkErrorTypeUnexpectedResponse 
                                                        request:objectLoader];
    }
}

// Cleanup --- release resultContext and model when finished loading
- (void)objectLoaderDidFinishLoading:(RKObjectLoader *)request {
    // !am! removing this as it gets called before the retry can happen
    ServerModelResultContext *resultContext = request.userData;
    if (!resultContext.isCancelled) {
        logRKRequestInfo(request, @" => %@",
                         resultContext.result ? resultContext.result : resultContext.error.description);
        [request cancel];   // !am! Steaming mound (i.e., RestKit) alert
        //      Why cancel? RestKit retries automatically
        //      and calls objectLoaderDidFinishLoading TWICE. 
        //      So, it's possible you'll get an error and a success response
        //      in succession.  Thanks, again for the wonderful hours I've
        //      spent with you, RestKit.
        [resultContext informDelegate];
        [[ServerModelRequests sharedRequests] forgetRequest:request];
        StatusHandler statusHandler = [ServerModel  globalStatusCodeHandler:resultContext.error.statusCode];
        if (statusHandler) {
            statusHandler(resultContext.error);
        }
    }
}
@end

#pragma mark -
#pragma mark Helper functions
NSString *MKCoordinateRegionAsBoundsString(MKCoordinateRegion region) {
    
    CLLocationCoordinate2D center = region.center;
    CLLocationCoordinate2D neCoord, swCoord;
    CGFloat latitudeHalfSpan = region.span.latitudeDelta/2.0;
    CGFloat longitudeHalfSpan = region.span.longitudeDelta/2.0;
    
    neCoord.latitude = center.latitude + latitudeHalfSpan;
    neCoord.longitude = center.longitude + longitudeHalfSpan;
    swCoord.latitude = center.latitude - latitudeHalfSpan;
    swCoord.longitude = center.longitude - longitudeHalfSpan;
    
    return [NSString stringWithFormat:@"%f,%f|%f,%f", 
            swCoord.latitude, swCoord.longitude, 
            neCoord.latitude, neCoord.longitude];
}
