//
//  Channel.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "ServerModel.h"
#import "ChannelStats.h"

@class Channel;

typedef enum {
    ChannelTypeUser,
    ChannelTypePlace,
    ChannelTypeUnknown
} ChannelType;

/**
 * Channel Model
 */
@interface Channel : ServerModel 

@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *_typeString;
@property (nonatomic,readonly) ChannelType type;
@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSNumber *_isListening; // whether the current user is tuned in
@property (nonatomic)        BOOL      isListening;
@property (nonatomic,strong) UIImage  *pictureImage;
@property (nonatomic,strong) NSNumber *_isBlacklistable; // whether the user is allowed to blacklist the channel or not
@property (nonatomic)        BOOL      isBlacklistable;
@property (nonatomic,strong) ChannelStats* stats;


+(RKObjectMapping *)mapping;
+(RKDynamicObjectMapping *)dynamicMapping;

-(void)addPropertiesObserver:(id)observer;
-(void)removePropertiesObserver:(id)observer;

-(id<CancellableOperation>)tuneIn:(void (^)(Channel *channel, ServerModelError *error))block;
-(id<CancellableOperation>)tuneOut:(void (^)(Channel *channel, ServerModelError *error))block;
-(id<CancellableOperation>)getFollowers:(void (^)(NSMutableArray *channels, ServerModelError *error))block;
-(id<CancellableOperation>)getFollowing:(void (^)(NSMutableArray *channels, ServerModelError *error))block;
-(id<CancellableOperation>)getBlipStream:(void (^)(NSMutableArray *blips, ServerModelError *error))block;

-(id<CancellableOperation>)blacklist:(void (^)(ServerModelError *error))block;

-(NSOperation *)loadPictureWithBlock:(void (^)(UIImage *image))block;
//-(BOOL)isPlaceChannel;
//-(BOOL)isUserChannel;

@end
