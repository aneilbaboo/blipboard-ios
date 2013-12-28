//
//  Channel.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "Flurry+Blipboard.h"
#import "Channel.h"
#import "UserChannel.h"
#import "PlaceChannel.h"
#import "Blip.h"
#import "Result.h"
#import "BBAppDelegate.h"
#import "BBLog.h"
#import "ASIDownloadCache.h"

@implementation Channel {
    NSString *_desc;
}
@dynamic desc;
@dynamic isListening;
@dynamic isBlacklistable;

NSString * const kChannelTypeUser = @"user";
NSString * const kChannelTypePlace = @"place";


-(BOOL)isListening {
    return self._isListening.boolValue;
}

-(void)setIsListening:(BOOL)isListening {
    self._isListening = @(isListening);
}

-(BOOL)isBlacklistable {
    return self._isBlacklistable.boolValue;
}

-(void)setIsBlacklistable:(BOOL)isBlacklistable {
    self._isBlacklistable = @(isBlacklistable);
}

-(NSString *) description {
    return [NSString stringWithFormat:@"[Channel ID:%@ name:%@ isListening:%d stats:%@]",
            self.id, self.name, self.isListening, self.stats ];
}

-(void)addPropertiesObserver:(id)observer {
    [self addObserver:observer forKeyPath:@"_isListening" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"desc" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"stats" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removePropertiesObserver:(id)observer {
    [self removeObserver:observer forKeyPath:@"_isListening"];
    [self removeObserver:observer forKeyPath:@"desc"];
    [self removeObserver:observer forKeyPath:@"stats"];
}

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id", @"id",
     @"name", @"name",
     @"description",@"desc",
     @"type", @"_typeString",
     @"picture", @"picture",
     @"isListening", @"_isListening",
     @"isBlacklistable", @"_isBlacklistable",
     nil];
    
    [mapping mapKeyPath:@"stats" toRelationship:@"stats" withMapping:ChannelStats.mapping];

    return mapping;
}

+(RKDynamicObjectMapping *)dynamicMapping {
    RKDynamicObjectMapping *dynChannelMap =[RKDynamicObjectMapping dynamicMapping];
    [dynChannelMap setObjectMapping:UserChannel.mapping whenValueOfKeyPath:@"type" isEqualTo:kChannelTypeUser];
    [dynChannelMap setObjectMapping:PlaceChannel.mapping whenValueOfKeyPath:@"type" isEqualTo:kChannelTypePlace];
    return dynChannelMap;
}

-(ChannelType)type {
    if ([self._typeString isEqualToString:kChannelTypeUser]) {
        return ChannelTypeUser;
    }
    else if ([self._typeString isEqualToString:kChannelTypePlace]) {
        return ChannelTypePlace;
    }
    else {
        return ChannelTypeUnknown;
    }
}

-(void)setDesc:(NSString *)desc {
    _desc = [desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)desc {
    return _desc;
}

-(NSOperation *)loadPictureWithBlock:(void (^)(UIImage *image))block {
    if (self.pictureImage) {
        block(self.pictureImage);
        return nil;
    }
    else {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.picture]
                                                      usingCache:[ASIDownloadCache sharedCache]
                                                  andCachePolicy:ASICacheForSessionDurationCacheStoragePolicy];
        __unsafe_unretained ASIHTTPRequest *weakRequest = request;
        
        [request setShouldRedirect:YES];
        [request setCompletionBlock:^{
            self.pictureImage = [UIImage imageWithData:weakRequest.responseData];
            [[UIApplication sharedApplication] popNetworkActivity];
            block(self.pictureImage);
        }];
        [request setFailedBlock:^{
            self.pictureImage = nil;
            [[UIApplication sharedApplication] popNetworkActivity];
            block(self.pictureImage);
        }];
        [request startAsynchronous];
        [[UIApplication sharedApplication] pushNetworkActivity];
        
        return request;
    }
    
}

-(id<CancellableOperation>)tuneIn:(void (^)(Channel *, ServerModelError *))block {
    NSString *path = [NSString stringWithFormat:@"%@/listensTo/%@",
                      [BBAppDelegate sharedDelegate].myAccount.id, 
                      self.id];
    
    [Flurry logEvent:kFlurryAPIFollow timed:YES];

    __block void (^_block)(Channel *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Channel *channel = nil;
                                         if (!error) {
                                             channel = (Channel *)model;
                                             
                                             // the API returns {result:true} if isListening changed
                                             //              or {result:false} if not
                                             Result *resultModel = [result objectForKey:@"result"];
                                             BOOL didTuneIn = [(NSNumber *)resultModel.result boolValue];
                                             if (didTuneIn) {
                                                 channel.stats.followers++;
                                                 [self changeServerInstancesUsingKeyValues:@{
                                                  @"_isListening":@(YES),
                                                  @"stats": channel.stats}]; // !JF!
                                             }
                                             [BBAppDelegate.sharedDelegate.myAccount incrementTotalTuneIns];
                                         }

                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                  @"id",self.id,
                                                                  @"followers",channel.stats._followers.stringValue,
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIFollow withParameters:params];

                                         _block(channel,error);
                                     }];
    
    self.isListening = YES;  // !jcf! should we wait until the response to set true
}

-(id<CancellableOperation>)tuneOut:(void (^)(Channel *, ServerModelError *))block {
    NSString *path = [NSString stringWithFormat:@"%@/listensTo/%@",
                      [BBAppDelegate sharedDelegate].myAccount.id, 
                      self.id];
    [Flurry logEvent:kFlurryAPIUnfollow timed:YES];

    __block void (^_block)(Channel *, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodDELETE
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Channel *channel = nil;
                                         if (!error) {
                                             channel = (Channel *)model;
                                             
                                             // the API returns {result:true} if isListening changed
                                             //              or {result:false} if not
                                             Result *resultModel = [result objectForKey:@"result"];
                                             BOOL didTuneOut = [(NSNumber *)resultModel.result boolValue];
                                             if (didTuneOut) {
                                                 [self changeServerInstancesUsingKeyValues:@{
                                                  @"_isListening":@(NO),
                                                  @"stats.followers":@(channel.stats.followers-1)}];
                                             }
                                         }
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"id",self.id,
                                                                 @"followers",@(channel.stats.followers),
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIUnfollow withParameters:params];
                                         
                                         _block(channel,error);
                                     }];
    
    
    self.isListening = NO;
    
}

-(id<CancellableOperation>)getFollowers:(void (^)(NSMutableArray *channels, ServerModelError *))block {
    NSString *path = [NSString stringWithFormat:@"%@/listeners",
                      self.id];
    
    [Flurry logEvent:kFlurryAPIFollowers timed:YES];
    __block void (^_block)(NSMutableArray *channels, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         [Flurry endTimedEvent:kFlurryAPIFollowers withErrorAndParams:error,
                                          @"id",self.id,nil];
                                         _block([result objectForKey:@"channels.data"],error);
                                     }];
}


-(id<CancellableOperation>)getFollowing:(void (^)(NSMutableArray *channels, ServerModelError *))block {
    NSString *path = [NSString stringWithFormat:@"%@/listensTo",
                      self.id];
    
    [Flurry logEvent:kFlurryAPIFollowing timed:YES];
    __block void (^_block)(NSMutableArray *channels, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         [Flurry endTimedEvent:kFlurryAPIFollowing withErrorAndParams:error,
                                          @"id",self.id,nil];
                                         _block([result objectForKey:@"channels.data"],error);
                                     }];
}


-(id<CancellableOperation>)getBlipStream:(void (^)(NSMutableArray *blips, ServerModelError *))block {
    [Flurry logEvent:kFlurryAPIBlipStream timed:YES];

    NSString *path = [NSString stringWithFormat:@"%@/stream",
                      self.id];
    __block void (^_block)(NSMutableArray *blips, ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         NSMutableArray *blips = nil;
                                         if (!error) {
                                             blips = [result objectForKey:@"blips"];
                                         }
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"id", self.id,
                                                                 @"count",[@(blips.count) stringValue],
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIBlipStream withParameters:params];

                                         _block(blips,error);
                                     }];
    
}

-(id<CancellableOperation>)blacklist:(void (^)(ServerModelError *))block
{
    BBLog(@"Blacklisting channel %@ (BBID): %@", self.name, self.id);
    
    NSString *path = [NSString stringWithFormat:@"%@/blacklist", self.id];
    
    __block void (^_block)(ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         _block(error);
                                     }];
}
//
//-(BOOL)isPlaceChannel
//{
//    return [self.type isEqualToString:kChannelTypePlace];
//}
//
//-(BOOL)isUserChannel
//{
//    return [self.type isEqualToString:kChannelTypeUser];
//}

@end
