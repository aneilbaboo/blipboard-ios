//
//  Blip.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

#import "Channel.h"
#import "PlaceChannel.h"
#import "Likes.h"
#import "ServerModel.h"
#import "Comment.h"

// !JKF! TODO: Do we want some kind of boolean lock
//  ivar that allows us to say "can't perform another"
//  operation right now because I'm already in the middle
//  of one?
@interface Blip : ServerModel <MKAnnotation>

@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) NSNumber *_isRead;
@property (nonatomic) BOOL isRead; // convenience metho
@property (nonatomic,strong) Channel *author;
@property (nonatomic,strong) NSDate *expiryTime;
@property (nonatomic,strong) NSDate *createdTime;
@property (nonatomic,strong) NSString *photo;

@property (nonatomic,strong) NSString *sourcePhoto;
@property (nonatomic,strong) NSNumber *_sourceWidth;
@property (nonatomic)        CGFloat sourceWidth;
@property (nonatomic,strong) NSNumber *_sourceHeight;
@property (nonatomic)        CGFloat sourceHeight;
@property (nonatomic,strong) NSNumber *_popularity;
@property (nonatomic)        CGFloat popularity; 
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) PlaceChannel *place;
@property (nonatomic,strong) Likes* likes;
@property (nonatomic,strong) NSDate *effectiveTime;
@property (nonatomic,strong) NSNumber *_isHighlighted;
@property (nonatomic)        BOOL isHighlighted;
@property (nonatomic,strong) NSMutableArray *comments;
@property (nonatomic,strong) NSMutableArray *topics;
@property (nonatomic,weak)   UIView *view;

@property (nonatomic,strong) Channel *recentLiker;
@property (nonatomic,strong) NSString *recentCommentId;

@property (nonatomic,readonly) Topic *displayTopic;

+(RKObjectMapping *)mapping;
+(int) getPlaceCountWithUnreadBlips:(NSMutableArray*) blips;

-(BOOL)isLiker; // simple, safe way of discovering liker state rather than likes.isLikers.boolvalue
-(id<CancellableOperation>)like:(void (^)(Blip *blip, ServerModelError *error))block;
-(id<CancellableOperation>)unlike:(void (^)(Blip *blip, ServerModelError *error))block;
-(id<CancellableOperation>)markRead:(void (^)(ServerModelError *error))block;
-(id<CancellableOperation>)addComment:(NSString *)text block:(void(^)(Blip *blip, ServerModelError *error))block; // the last comment in blip is the new comment
-(NSOperation *)loadPictureForAuthor:(BOOL)author place:(BOOL)place topic:(BOOL)topic completion:(void (^)(UIImage *authorPicture, UIImage *placePicture, UIImage *topicPicture))completion;
-(void)shareToFacebook:(void (^)(id result,NSError *error))completion;
-(void)addPropertiesObserver:(id)observer;
-(void)removePropertiesObserver:(id)observer;
@end
