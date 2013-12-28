//
//  PlaceChannel.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/20/12.
//  Copyright (c) 2012 Blipboard, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "Channel.h"
#import "Location.h"
#import "Topic.h"

@class Blip;

@interface PlaceChannel : Channel <MKAnnotation> {
    Location* _location;
}

@property (nonatomic,strong) NSString  *facebookId; // not yet
@property (nonatomic,strong) Location  *location;
@property (nonatomic,strong) NSString  *category;
@property (nonatomic,strong) NSString  *categoryId;
@property (nonatomic,strong) NSString  *website;
@property (nonatomic,strong) NSString  *phone;
@property (nonatomic,strong) Topic*    defaultTopic;

+(RKObjectMapping *)mapping;
+(NSString*)type;

-(id<CancellableOperation>)broadcastHere:(NSString*)message topic:(Topic *)topic expiry:(NSDate*)expiry block:(void (^)(Blip *blip, ServerModelError *error))block;
-(id<CancellableOperation>) markMyReceivedBlipsRead:(void (^)(ServerModelError *error))block;
-(void)callPhone;
-(BOOL)canCallPhone;
-(BOOL)hasWebsite;
-(void)showWebsite;
-(BOOL)hasDirections;
-(void)showDirections;
@end
