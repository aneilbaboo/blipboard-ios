
//
//  Account.h
//  Blipboard
//
//  Created by Jason Fischl on 4/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "ServerModel.h"
#import "Paging.h"
#import "NotificationStream.h"
#import "UserChannel.h"
#import "AccountCaps.h"

@class Channel;
@class UserChannel;
@class Blip;
@class Region;
@class Area;

typedef enum {
    NearbyChannelScopeRegion=1,
    NearbyChannelScopeCity=2
} NearbyChannelScope;

@interface Account : UserChannel
@property (nonatomic,strong) NSString* password;
@property (nonatomic,strong) NSString* email;
@property (nonatomic,strong) NSString* facebookId;
@property (nonatomic,strong) AccountCaps* capabilities;

/*
@property (nonatomic,strong) NSString* id;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* picture;

*/

-(void) incrementTotalTuneIns;
-(void) incrementTotalBlips;
-(void) copyFrom:(Account*)account;
-(void) persistAccount; // save to NSUserDefaults
-(void) clearAccount; // remove from NSUserDefaults

-(id<CancellableOperation>)putAccount:(void(^)(Account *account, ServerModelError *))block;
-(id<CancellableOperation>) updateFacebookToken:(NSString*)token block:(void (^)(Account *account,ServerModelError *error))block;
-(id<CancellableOperation>) reportLocation:(CLLocation*)location reason:(NSString*)reason block:(void (^)(Region *region, ServerModelError *error))block;
// !jcf! Note: this code is no longer used as there is a synchronous version in the RestKit stuff. 
-(void) reportLocationSync:(CLLocation*)location timeout:(NSTimeInterval)timeout reason:(NSString*)reason block:(void (^)(Region *region, ServerModelError *error))block;;

-(id<CancellableOperation>) getPopularBlipsInRegion:(MKCoordinateRegion)region block:(void (^)(NSMutableArray *blips, ServerModelError *error))block;

-(id<CancellableOperation>) getPopularBlipsInRegion:(MKCoordinateRegion)region type:(NSString*)type topic:(Topic *)topic block:(void (^)(NSMutableArray *blips, ServerModelError *error))block;

-(id<CancellableOperation>) getReceivedBlipsInRegion:(MKCoordinateRegion)region topic:(Topic *)topic block:(void (^)(NSMutableArray *blips, ServerModelError *error))block;

-(id<CancellableOperation>) markReceivedBlipsAsReadInRegion:(MKCoordinateRegion)region block:(void (^)(ServerModelError *error))block;

-(id<CancellableOperation>) getMyBlipsInRegion:(MKCoordinateRegion)region  topic:(Topic *)topic block:(void (^)(NSMutableArray * blips, ServerModelError *error))block;

-(id<CancellableOperation>) getNearbyChannelsForRegion:(MKCoordinateRegion)region
                                             withScope:(NearbyChannelScope)scope
                                                ofType:(ChannelType)channelType
                                        matchingPrefix:(NSString*)prefix
                                                 block:(void (^)(NSMutableArray *channels, Paging *paging, ServerModelError *error))block;

-(id<CancellableOperation>) getNearbyChannelsForRegion:(MKCoordinateRegion)region
                                                ofType:(ChannelType)channelType
                                                 block:(void (^)(NSMutableArray *channels, Paging *paging, ServerModelError *error))block;
-(id<CancellableOperation>) getChannel:(NSString *)id block:(void (^)(Channel *channel, ServerModelError*error))block;
-(id<CancellableOperation>) getBlip:(NSString *)id block:(void (^)(Blip *blip, ServerModelError*error))block;
-(id<CancellableOperation>)getTopics:(void (^)(NSMutableArray *topics, ServerModelError *error))block;
// notifications
-(id<CancellableOperation>)getNotifications:(void (^)(NotificationStream *notificationStream, ServerModelError *error))block;
-(id<CancellableOperation>)markLastNewNotification:(Notification *)notification block:(void (^)(ServerModelError *error))block;

+(BOOL) isInSupportedAreaWithCoordinate:(CLLocationCoordinate2D)coordinate;
+(BOOL) isInSupportedAreaWithLocation:(CLLocation*)location;
+(CLLocationCoordinate2D) getDefaultStartLocationFromCoordinate:(CLLocationCoordinate2D)coordinate;
+(CLLocationCoordinate2D) getDefaultStartLocationFromLocation:(CLLocation*)location;

+(Account*) createAccountWithToken:(NSString*)token block:(void (^)(Account *account, ServerModelError *error))block;
+(Account*) createAnonymousAccount:(void (^)(Account *account,ServerModelError *error))block;

+(Account*) restoreAccount; // restore from NSUserDefaults
+(RKObjectMapping *)mapping;

@end
