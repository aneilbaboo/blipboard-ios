//
//  Account.m
//  Blipboard
//
//  Created by Jason Fischl on 4/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <RestKit/RKRequestSerialization.h> 
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Flurry+Blipboard.h"

#import "Account.h"
#import "AccountCaps.h"
#import "BBAppDelegate.h"
#import "Blip.h"
#import "Region.h"
#import "Paging.h"
#import "BBLog.h"
#import "Notification.h"

// !am! for getNotifications test data only:
#import "Blip.h"
#import "Comment.h"
#import "Liker.h"
#import "Channel.h"
#import "Paging.h"
#import "Notification.h"
#import "NotificationStream.h"
#import "NSTimer+Blocks.h"
#import "ReturnedOperation.h"

const NSInteger BlipLimit = 15;

@implementation Account {
    UserChannel *_channel;
}

// !!!!!! if you add properties you must update copyFrom method
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [Account class];
    [mapping mapKeyPath:@"email" toAttribute:@"email"];
    [mapping mapKeyPath:@"facebookId" toAttribute:@"facebookId"];    
    [mapping mapKeyPath:@"capabilities" toRelationship:@"capabilities" withMapping:AccountCaps.mapping];

    return mapping;
}

-(void) copyFrom:(Account*)account {
    assert(account.id);
    self.id = account.id;
    self.password = account.password;
    self.name = account.name;
    self.picture = account.picture;
    self.email = account.email;
    self.desc = account.desc;
    self.stats = account.stats;
    self.capabilities = account.capabilities;
    self.facebookId = account.facebookId;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"[Account ID:%@:%@ name:%@ fb:%@ caps:%@ picture:%@ email:%@ stats:%@]",
            self.id, self.password, self.name, self.facebookId,
            self.capabilities,
            self.picture, self.email,
            self.stats];
}

-(void) persistAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.id forKey:@"account.id"];
    [defaults setObject:self.password forKey:@"account.password"];
    [defaults setObject:self.name forKey:@"account.name"];
    [defaults setObject:self.picture forKey:@"account.picture"];
    [defaults setObject:self.email forKey:@"account.email"];
    [defaults setObject:self.facebookId forKey:@"account.facebookId"];
    [defaults synchronize];
}

-(void) clearAccount {
    self.id = nil;
    self.password = nil;
    self.name = nil;
    self.picture = nil;
    self.email = nil;
    self.facebookId = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"account.id"];
    [defaults removeObjectForKey:@"account.password"];
    [defaults removeObjectForKey:@"account.name"];
    [defaults removeObjectForKey:@"account.picture"];
    [defaults removeObjectForKey:@"account.email"];
    [defaults removeObjectForKey:@"account.facebookId"];
    [defaults synchronize];
}


#pragma mark -
#pragma mark Initial User support

NSString * const kAccountTotalTuneIns = @"account.totalTuneIns";
NSString * const kAccountTotalBlips = @"account.totalBlips";

-(NSInteger)totalTuneIns {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:kAccountTotalTuneIns];
}

-(void)incrementTotalTuneIns {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[defaults integerForKey:kAccountTotalTuneIns]+1
                  forKey:kAccountTotalTuneIns];
}

-(NSInteger)totalBlips {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:kAccountTotalBlips];
}

-(void)incrementTotalBlips {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:[defaults integerForKey:kAccountTotalBlips]+1
                  forKey:kAccountTotalBlips];
}

#pragma mark -
#pragma mark Server methods
-(id<CancellableOperation>) updateFacebookToken:(NSString *)token block:(void (^)(Account *, ServerModelError *))block {

    NSDictionary* params = [NSDictionary dictionaryWithObject:token forKey:@"fbtoken"];
    __block void (^_block)(Account *, ServerModelError *) = block;
    NSString* path = [NSString stringWithFormat:@"/accounts/%@/access_token", self.id];
    [Flurry logEvent:kFlurryAPIUpdateFacebookToken timed:YES];
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPUT
                                 andParams:params
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError* error) {
                                         [Flurry endTimedEvent:kFlurryAPIUpdateFacebookToken withErrorAndParams:error,nil];
                                         _block((Account *)[result objectForKey:@"account"],error);
                                     }];
    
    [self persistAccount]; //saves the access token
}

-(id<CancellableOperation>)putAccount:(void(^)(Account *account, ServerModelError *))block {
    NSString *resourcePath = [NSString stringWithFormat:@"/accounts/%@",self.id];
    NSDictionary *params = @{@"id":self.id ? self.id : @"",
                             @"name":self.name ? self.name : @"",
                             @"description":self.desc ? self.desc : @"",
                             @"picture":self.picture ? self.picture : @"",
                             @"email":self.email ? self.email : @""};
    __block void (^blockCallback)(Account *account, ServerModelError *error) = block;
    
    return [self loadObjectsAtResourcePath:resourcePath
                                withMethod:RKRequestMethodPUT
                                 andParams:params
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Account *account = [result valueForKey:@"account"];
                                         if (account &&!error){
                                             [self copyFrom:account];
                                             [self changeServerInstancesUsingKeyValues:@{
                                              @"desc": account.desc}];
                                         }
                                         blockCallback(account,error);
                                     }];
}

//-(BOOL)hasAccessToTwitter {
//    
//}
//-(void)requestAccessToTwitter:(void(^)(BOOL granted, NSError *error))completion {
//    // Create an account store object.
//	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//	
//	// Create an account type that ensures Twitter accounts are retrieved.
//    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
//
//	NSArray *accounts = [accountStore accountsWithAccountType:accountType];
//    
//	// Request access from the user to use their Twitter accounts.
//    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:completion];
//}
//
+(Account*) restoreAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* accountid = [defaults stringForKey:@"account.id"];
    if (accountid) {
        Account* account = [[Account alloc] init];
        
        account.id = accountid;
        account.password = [defaults stringForKey:@"account.password"];
        account.name = [defaults stringForKey:@"account.name"];
        account.picture = [defaults stringForKey:@"account.picture"];
        account.email = [defaults stringForKey:@"account.email"];

        BBLog(@"accountid: %@", account.id);
        return account;
    }
    else {
        return nil;
    }
}

+(NSString*) generatePassword
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+(Account*) createAccountWithToken:(NSString*)token block:(void (^)(Account *account, ServerModelError *error))block
{
    BBTrace();
    
    Account* account = [[Account alloc] init];
    account.password = [self generatePassword]; // use a GUID for the locally generated password
    
    //!jcf! make password a random string
    NSDictionary* params;
    if (token) {
        [Flurry logEvent:kFlurryAPICreateFacebook];
        params = @{@"password": account.password, @"fbtoken": token};
    }
    else {
        [Flurry logEvent:kFlurryAPICreateAnonymous];
        params = @{@"password": account.password};
    }
    
    __block void (^_block)(Account *, ServerModelError *) = block;
    [account loadObjectsAtResourcePath:@"/accounts"
                            withMethod:RKRequestMethodPOST
                             andParams:params
                   andBackgroundPolicy:RKRequestBackgroundPolicyContinue
                                 block:^(ServerModel *model, NSDictionary *result, ServerModelError* error) {
                                     _block((Account *)[result objectForKey:@"account"],error);
                                 }];
    
    
    return account;
}

+(Account*) createAnonymousAccount:(void (^)(Account *account, ServerModelError *error))block
{
    return [Account createAccountWithToken:nil block:block];
}

-(id<CancellableOperation>) reportLocation:(CLLocation *)location 
                         reason:(NSString *)reason 
                          block:(void (^)(Region *region, ServerModelError *error))block
{
    NSString* latlng = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude]; 
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            latlng, @"latlng",
                            reason, @"reason",
                            [NSNumber numberWithDouble:[location.timestamp timeIntervalSinceNow]], @"age",
                            [NSNumber numberWithDouble:location.horizontalAccuracy], @"accuracy",
                            [NSNumber numberWithDouble:location.speed], @"speed",
                            nil];
    //[Flurry logEvent:kFlurryAPIReportLocation];

    __block void (^_block)(Region *, ServerModelError *) = block;
    NSString* path = [NSString stringWithFormat:@"/accounts/%@/location", self.id];
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:params
                       andBackgroundPolicy:RKRequestBackgroundPolicyContinue 
                                     block:^(ServerModel *model, NSDictionary *results, ServerModelError *error) {
                                         _block([results objectForKey:@"region"],error);
                                     }];
}

// we require a synchronous version of this since the update may have to occur in the background 
// !jcf! Note: this code is no longer used as there is a synchronous version in the RestKit stuff. 
-(void) reportLocationSync:(CLLocation*)location
                   timeout:(NSTimeInterval)timeout
                    reason:(NSString*)reason
                     block:(void (^)(Region *region, ServerModelError *error))block
{
    NSString* latlng = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    NSString* path = [NSString stringWithFormat:@"/accounts/%@/location", self.id];
    NSURL* url = [[[RKClient sharedClient] baseURL] URLByAppendingResourcePath:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.timeOutSeconds = timeout;
    [request setPostValue:latlng forKey:@"latlng"];
    [request setPostValue:reason forKey:@"reason"];

    BBLog(@"reportLocationSync: %@:%@", location, reason);
    [request setUsername:self.id];
    
    if(FBSession.activeSession.isOpen) {
        [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"OAuth2 %@",
                                                          FBSession.activeSession.accessTokenData.accessToken]];
    }
    else {
        [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
        [request setPassword:self.password];        
    }
    
    [request startSynchronous];
    
    NSError* error = [request error];
    __block void (^_block)(Region *region, ServerModelError *error) = block;
    if (!error) {
        NSString* response = [request responseString];
        NSData* data = [response dataUsingEncoding:NSUTF8StringEncoding];
        BBLog(@"response=%@", response);
        NSDictionary* results = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:0 //NSJSONReadingMutableLeaves
                                 error:&error];
        NSDictionary* r = [results objectForKey:@"region"];
        
        // !jcf! note: using dispatch_async to force the delegate to be called asynchronously. 
        // this avoids calling a transition within an action on the FSM
    
        dispatch_async(dispatch_get_main_queue(), ^{
            Region* region = [[Region alloc] init];
            region.latitude = [r objectForKey:@"latitude"];
            region.longitude = [r objectForKey:@"longitude"];
            region.radius = [r objectForKey:@"radius"];
            _block(region,nil);
        });
    }
    else {
        BBLog(@"error=%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            _block(nil,[ServerModelError errorWithNSError:error
                                               andRequest:nil]);
        });
    }
} 

-(id<CancellableOperation>) getPopularBlipsInRegion:(MKCoordinateRegion)region block:(void (^)( NSMutableArray *blips, ServerModelError *error))block
{
    return [self getPopularBlipsInRegion:region type:nil topic:nil block:block];
}

-(id<CancellableOperation>) getPopularBlipsInRegion:(MKCoordinateRegion)region
                                               type:(NSString*)type
                                              topic:(Topic *)topic
                                              block:(void (^)(NSMutableArray *blips, ServerModelError *error))block
{
    BBTrace();
    [Flurry logEvent:kFlurryAPIGetPopularBlips timed:YES];
    __block void (^_block)(NSMutableArray *, ServerModelError *) = block;
    NSString* resourcePath;
    
    if (type) {
        resourcePath = [NSString stringWithFormat:@"/blips/popular?type=%@&bounds=%@&limit=%d", type, MKCoordinateRegionAsBoundsString(region),BlipLimit];
    }
    else {
        resourcePath = [NSString stringWithFormat:@"/blips/popular?bounds=%@&limit=%d", MKCoordinateRegionAsBoundsString(region),BlipLimit];
    }
    
    NSString *topicName = @"all";
    if (topic) {
        resourcePath = [NSString stringWithFormat:@"%@&topicids=%@",resourcePath, topic.id];
        topicName = topic.name;
    }
    
    return [self loadObjectsAtResourcePath:resourcePath
                                     block:^(ServerModel *account,NSDictionary *result,ServerModelError *error) {
                                         NSMutableArray *blips = [result objectForKey:@"blips"];

                                         NSDictionary* fparams = [Flurry paramsWithError:error ,
                                                                 @"region", MKCoordinateRegionAsBoundsString(region),
                                                                  @"topic",topicName,
                                                                  @"count", [NSString stringWithFormat:@"%d", blips.count],
                                                                 @"limit", [NSString stringWithFormat:@"%d", BlipLimit],
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIGetPopularBlips withParameters:fparams];
                                         blips = [NSMutableArray arrayWithArray:[blips subarrayWithRange:NSMakeRange(0, MIN(BlipLimit,blips.count))]];
                                         _block(blips,error);
                                     }];
}

-(id<CancellableOperation>) getReceivedBlipsInRegion:(MKCoordinateRegion)region topic:(Topic *)topic block:(void (^)( NSMutableArray *blips, ServerModelError *error))block
{
    BBTrace();
    [Flurry logEvent:kFlurryAPIGetReceivedBlips timed:YES];
    
    NSString *resourcePath = [NSString stringWithFormat:@"/channels/%@/received?bounds=%@&limit=%d",
                              self.id,
                              MKCoordinateRegionAsBoundsString(region),
                              BlipLimit];
    NSString *topicName = @"all";
    if (topic) {
        resourcePath = [NSString stringWithFormat:@"%@&topicids=%@",resourcePath, topic.id];
        topicName = topic.name;
    }
    __block  void (^_block)(NSMutableArray *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:resourcePath
                                     block:^(ServerModel *account,NSDictionary *result,ServerModelError *error) {
                                         NSMutableArray *blips = [result objectForKey:@"blips"];
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"region", MKCoordinateRegionAsBoundsString(region),
                                                                 @"topic",  topicName,
                                                                 @"count",  [NSString stringWithFormat:@"%d", blips.count],
                                                                 @"limit",  [NSString stringWithFormat:@"%d", BlipLimit],                                                                 
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIGetReceivedBlips withParameters:params];

                                         _block(blips,error);
                                     }];
}

-(id<CancellableOperation>) getMyBlipsInRegion:(MKCoordinateRegion)region topic:(Topic *)topic block:(void (^)(NSMutableArray *, ServerModelError *))block
{
    BBTrace();
    [Flurry logEvent:kFlurryAPIGetMyBlips timed:YES];
    NSString *resourcePath = [NSString stringWithFormat:@"/%@/stream?bounds=%@",
                              self.id,
                              MKCoordinateRegionAsBoundsString(region)];
    NSString *topicName = @"all";
    if (topic) {
        resourcePath = [NSString stringWithFormat:@"%@&topicids=%@",resourcePath, topic.id];
        topicName = topic.name;
    }
    __block  void (^_block)(NSMutableArray *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:resourcePath
                                     block:^(ServerModel *account,NSDictionary *result,ServerModelError *error) {
                                         NSMutableArray *blips = [result objectForKey:@"blips"];

                                         NSDictionary* params = [Flurry paramsWithError:error, 
                                                                 @"region",MKCoordinateRegionAsBoundsString(region),
                                                                 @"topic",topicName,
                                                                 @"count",[NSString stringWithFormat:@"%d", blips.count],
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIGetMyBlips withParameters:params];

                                         _block(blips,error);
                                     }];

}

-(id<CancellableOperation>) markReceivedBlipsAsReadInRegion:(MKCoordinateRegion)region block:(void (^)(ServerModelError *error))block
{
    BBTrace();
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            MKCoordinateRegionAsBoundsString(region), @"bounds", nil];
    __block void (^_block)(ServerModelError *)  = block;
    NSString* path = [NSString stringWithFormat:@"/channels/%@/received/mark-read", self.id];
    return [self loadObjectsAtResourcePath:path
                         withMethod:RKRequestMethodPOST
                          andParams:params 
            block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                _block(error);
            }];
}

-(id<CancellableOperation>) getNearbyChannelsForRegion:(MKCoordinateRegion)region
                                             withScope:(NearbyChannelScope)scope
                                                ofType:(ChannelType)channelType
                                        matchingPrefix:(NSString*)prefix
                                                 block:(void (^)(NSMutableArray *channels, Paging *paging, ServerModelError *error))block
{
    BBTrace();
    NSString *resourcePath;
    NSString *prefixParam = prefix ? [NSString stringWithFormat:@"&q=%@",prefix] : @"";
    NSString *scopeParam = scope==NearbyChannelScopeRegion ? @"&scope=region" : @"&scope=city";
    NSString *type = channelType==ChannelTypeUser ? @"user" : @"place";
    resourcePath = [NSString stringWithFormat:@"/channels?type=%@&bounds=%@&limit=50%@%@",
                    type,
                    MKCoordinateRegionAsBoundsString(region),
                    prefixParam,
                    scopeParam];
    
    __block  void (^_block)(NSMutableArray *, Paging *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:resourcePath
                                     block:^(ServerModel *account, NSDictionary *result, ServerModelError *error) {
                                         NSMutableArray *channels = [result objectForKey:@"channels.data"];
                                         Paging  *paging = [result objectForKey:@"channels.paging"];
                                         paging.dataKey=@"channels.data";
                                         paging.pagingKey=@"channels.paging";
                                         _block(channels,paging,error);
                                     }];
}

- (id<CancellableOperation>)getNearbyChannelsForRegion:(MKCoordinateRegion)region
                                                ofType:(ChannelType)channelType
                                                 block:(void (^)(NSMutableArray *channels, Paging *paging, ServerModelError *))block
{
    return [self getNearbyChannelsForRegion:region
                                  withScope:NearbyChannelScopeRegion
                                     ofType:channelType
                             matchingPrefix:nil
                                      block:block];
}

-(id<CancellableOperation>)getChannel:(NSString *)id block:(void (^)(Channel *, ServerModelError*))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIGetChannel timed:YES];

    NSString *resourcePath = [NSString stringWithFormat:@"/channels/%@",id];
    __block  void (^_block)(Channel *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:resourcePath 
                                 block:^(ServerModel *account, NSDictionary *result, ServerModelError *error) {
                                     
                                     NSDictionary* params = [Flurry paramsWithError:error, 
                                                             @"id",id,
                                                             nil];
                                     [Flurry endTimedEvent:kFlurryAPIGetChannel withParameters:params];

                                     _block([result objectForKey:@"channel"],error);
                                 }];
}

-(id<CancellableOperation>) getBlip:(NSString *)id block:(void (^)(Blip *blip, ServerModelError*error))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIGetBlip timed:YES];

    NSString *resourcePath = [NSString stringWithFormat:@"/blips/%@",id];
    __block  void (^_block)(Blip*, ServerModelError*) = block;
    return [self loadObjectsAtResourcePath:resourcePath
                                     block:^(ServerModel *account, NSDictionary *result, ServerModelError *error) {
                                         NSDictionary* params = [Flurry paramsWithError:error, 
                                                                 @"id",id,
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIGetBlip withParameters:params];

                                         _block([result objectForKey:@"blip"],error);
                                     }];    
}


-(id<CancellableOperation>)getNotifications:(void (^)(NotificationStream *stream, ServerModelError *error))block {
    NSString *resourcePath = [NSString stringWithFormat:@"/accounts/%@/notifications",self.id];
    __block void (^blockCallback)(NotificationStream *, ServerModelError *) = block;
    [self loadObjectsAtResourcePath:resourcePath block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
        if (error) {
            blockCallback(nil,error);
        }
        else {
            NotificationStream *ns = [NotificationStream notificationStream:result];
            blockCallback(ns,nil);
        }
    }];
    
    return nil;
}


-(id<CancellableOperation>)markLastNewNotification:(Notification *)notification block:(void (^)(ServerModelError *))block {
    NSString *resourcePath = [NSString stringWithFormat:@"/accounts/%@/notifications/last-new/%@",self.id,notification.id];
    [self loadObjectsAtResourcePath:resourcePath block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
        block(error);
    }];

    return nil;
}

+(BOOL) isInSupportedAreaWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D sw = CLLocationCoordinate2DMake(37.6819, -122.555);
    CLLocationCoordinate2D ne = CLLocationCoordinate2DMake(37.8361, -122.344);
    return  (coordinate.latitude >= sw.latitude &&
             coordinate.latitude <= ne.latitude &&
             coordinate.longitude >= sw.longitude &&
             coordinate.longitude <= ne.longitude);
}

+(BOOL) isInSupportedAreaWithLocation:(CLLocation*)location
{
    return (location && [Account isInSupportedAreaWithCoordinate:location.coordinate]);
}

+(CLLocationCoordinate2D) getDefaultStartLocationFromCoordinate:(CLLocationCoordinate2D)coordinate
{
    if ([Account isInSupportedAreaWithCoordinate:coordinate]) {
        return coordinate;
    }
    else {
        return CLLocationCoordinate2DMake(37.80104, -122.40993);
    }
}

+(CLLocationCoordinate2D) getDefaultStartLocationFromLocation:(CLLocation*)location
{
    if ([Account isInSupportedAreaWithLocation:location]) {
        return location.coordinate;
    }
    else {
        return [Account getDefaultStartLocationFromCoordinate:location.coordinate];
       
    }
}

-(id<CancellableOperation>)getTopics:(void (^)(NSMutableArray *topics, ServerModelError *error))block {
    static NSMutableArray *topics;
    NSString *resourcePath = @"/topics/";
    [self loadObjectsAtResourcePath:resourcePath block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
        if (!error) {
            topics = result[@"topics"][@"data"];
            // Paging *paging = result[@"paging"]; // not using paging yet
            block(topics,nil);
        }
        else if (topics) {
            block(topics,nil); // ignore the error if we've already retrieved topics
        }
        else {
            block(nil,error);
        }
    }];
    
    return nil;
}

@end
