//
//  Blip.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/30/11.
//  Copyright (c) 2011 Blipboard. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "Flurry+Blipboard.h"

#import "BBLog.h"
#import "Blip.h"
#import "Channel.h"
#import "PlaceChannel.h"
#import "Comment.h"
#import "BBAppDelegate.h"

@implementation Blip
@dynamic isRead;
@dynamic sourceWidth;
@dynamic sourceHeight;
@dynamic popularity;
@dynamic isHighlighted;
@dynamic displayTopic;

#pragma mark - Class Methods
#pragma mark

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id",                 @"id", // blip id
     @"message",            @"message",
     @"photo",              @"photo",
     @"sourcePhoto",        @"sourcePhoto",
     @"sourceWidth",        @"_sourceWidth",
     @"sourceHeight",       @"_sourceHeight",
     @"link",               @"link",
     @"expiryTime",         @"expiryTime",
     @"createdTime",        @"createdTime",
     @"isRead",             @"_isRead",
     @"popularity",         @"_popularity",
     @"effectiveDate",      @"effectiveTime",
     @"isHighlighted",      @"_isHighlighted",
     nil];
    
    [mapping mapRelationship:@"author" withMapping:Channel.dynamicMapping];
    [mapping mapRelationship:@"place" withMapping:PlaceChannel.mapping];
    [mapping mapRelationship:@"likes" withMapping:Likes.mapping];
    [mapping mapRelationship:@"comments" withMapping:Comment.mapping];
    [mapping mapRelationship:@"topics" withMapping:Topic.mapping];
    return mapping;
}



#pragma mark - Instance Methods
#pragma mark
-(Topic *)displayTopic {
    return (self.topics && self.topics.count) ? self.topics[0] : nil;
}

-(BOOL)isRead {
    return self._isRead && self._isRead.boolValue;
}

-(void)setIsRead:(BOOL)isRead {
    self._isRead = @(isRead);
}

-(BOOL)isHighlighted {
    return self.isHighlighted && self._isHighlighted.boolValue;
}

-(void)setIsHighlighted:(BOOL)isHighlighted {
    self._isHighlighted = @(isHighlighted);
}

-(CGFloat)sourceHeight {
    return self._sourceHeight.floatValue;
}

-(void)setSourceHeight:(CGFloat)sourceHeight {
    self._sourceHeight = @(sourceHeight);
}

-(CGFloat)sourceWidth {
    return self._sourceWidth.floatValue;
}

-(void)setSourceWidth:(CGFloat)sourceWidth {
    self._sourceWidth = @(sourceWidth);
}

-(CGFloat)popularity {
    return self._popularity.floatValue;
}

-(void)setPopularity:(CGFloat)popularity {
    self._popularity = @(popularity);
}

-(BOOL)isLiker {
    return self.likes && self.likes.isLiker && self.likes.isLiker;
}

-(NSString *) description {
    // !jcf! note: use of UTF8String is so we can format the width of the string specifically
    return [NSString stringWithFormat:@"[Blip ID:%@ author:%-15s place:%-35s isLiker:%@ isRead:%@ likeCount:%d popularity:%.2f created:%@])",
            self.id,
            [self.author.name UTF8String],
            [self.place.name UTF8String],
            self.likes.isLiker ? @"yes" : @" no",
            self.isRead ? @"yes" : @" no",
            self.likes.likeCount,
            self.popularity,
            self.createdTime];
}

-(NSOperation *)loadPictureForAuthor:(BOOL)author place:(BOOL)place topic:(BOOL)topic completion:(void (^)(UIImage *authorPicture, UIImage *placePicture, UIImage *topicPicture))completion {
    __block UIImage *authorImage;
    __block UIImage *placeImage;
    __block UIImage *topicImage;
    NSOperation *loadAuthorPic = author ? [self.author loadPictureWithBlock:^(UIImage *image) {
        authorImage = image;
    }] : nil;
    NSOperation *loadTopicPic = topic ? [self.displayTopic loadPictureWithBlock:^(UIImage *image) {
        topicImage = image;
    }] : nil;
    NSOperation *loadPlacePic = place ? [self.place loadPictureWithBlock:^(UIImage *image) {
        placeImage = image;
    }] : nil;
    BBBlockOperation *loadPics =[BBBlockOperation blockOperationWithBlock:^{}];
    
    if (loadAuthorPic) { [loadPics addDependency:loadAuthorPic]; }
    if (loadTopicPic)  { [loadPics addDependency:loadTopicPic]; }
    if (loadPlacePic)  { [loadPics addDependency:loadPlacePic]; }
    
    [loadPics setCompletionBlock:^{
        completion(authorImage,placeImage,topicImage);
        //dispatch_async(dispatch_get_main_queue(), completion);
    }];
    [[NSOperationQueue mainQueue] addOperation:loadPics];
    return loadPics;
}

-(void)removePropertiesObserver:(id)observer {
    [self removeObserver:observer forKeyPath:@"author"];
    [self.author removeObserver:observer forKeyPath:@"_isListening"];
    [self.author removeObserver:observer forKeyPath:@"desc"];
    [self removeObserver:observer forKeyPath:@"likes"];
    [self removeObserver:observer forKeyPath:@"comments"];
    [self removeObserver:observer forKeyPath:@"_isRead"];
}

-(void)addPropertiesObserver:(id)observer {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    [self addObserver:observer forKeyPath:@"author" options:options context:nil];
    [self.author addObserver:observer forKeyPath:@"_isListening" options:options context:nil];
    [self.author addObserver:observer forKeyPath:@"desc" options:options context:nil];
    [self addObserver:observer forKeyPath:@"likes" options:options context:nil];
    [self addObserver:observer forKeyPath:@"comments" options:options context:nil];
    [self addObserver:observer forKeyPath:@"_isRead" options:options context:nil];
}

-(id<CancellableOperation>)addComment:(NSString *)text block:(void (^)(Blip *, ServerModelError *))block {
    BBLog(@"%@",text);
    [Flurry logEvent:kFlurryAPIAddComment timed:YES];
    
    NSString *path = [NSString stringWithFormat:@"/blips/%@/comments",self.id];
    __block NSString *authorId = BBAppDelegate.sharedDelegate.myAccount.id;
    __block void (^_block)(Blip *,ServerModelError *) = block;
    __weak Blip *weakSelf = self;
    
    NSDictionary *params = @{@"text":text};
    
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:params
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Comment *comment = (Comment *)[result objectForKey:@"comment"];
                                         
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"commentId", comment.id,
                                                                 @"author", authorId,
                                                                 @"place", weakSelf.place.id,
                                                                 @"blip", weakSelf.id,
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIAddComment withParameters:params];

                                         if (comment && !error) {
                                             [self.author changeServerInstancesUsingKeyValues:@{
                                              @"stats": self.author.stats}];
                                             [self _addComment:comment];
                                         }
                                         
                                         _block(weakSelf,error);
                                         
                                     }];
}

-(void)_addComment:(Comment *)comment {
    NSMutableArray *changedComments;
    if (!_comments) {
        changedComments = [NSMutableArray arrayWithObject:comment];
    }
    else {
        [_comments addObject:comment];
        changedComments = _comments;
    }
    [self changeServerInstancesUsingKeyValues:@{
     @"coments":changedComments}];
}

-(void)shareToFacebook:(void (^)(id result,NSError *error))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                   @"message":self.message,
                                   @"link":self.link,
                                   @"name":[NSString stringWithFormat:@"%@'s blip at %@",self.author.name,self.place.name],
                                   @"caption":@"blipboard.com",
                                   @"description":@"And other interesting things found nearby."}];
    if (self.place.facebookId) {
        params[@"place"] = self.place.facebookId;
    }
    
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        completion(result,error);
    }];
}

-(id<CancellableOperation>)like:(void (^)(Blip *, ServerModelError *))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPILikeBlip timed:YES];

    NSString *path = [NSString stringWithFormat:@"/blips/%@/likes",self.id];
    
    __block void (^_block)(Blip *,ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Blip* blip = nil;
                                         
                                         if (!error) {
                                             blip = (Blip*)model;
                                             [blip changeServerInstancesUsingKeyValues:@{
                                              @"likes": [result objectForKey:@"likes"]}];
                                             [blip.author changeServerInstancesUsingKeyValues:@{
                                              @"stats": blip.author.stats}];
                                             NSDictionary* params = [Flurry paramsWithError:error,
                                                                     @"author", blip.author.id,
                                                                     @"place", blip.place.id,
                                                                     @"blip", blip.id,
                                                                     @"count", @(blip.likes.likers.count),
                                                                     nil];
                                             
                                             [Flurry endTimedEvent:kFlurryAPILikeBlip withParameters:params];
                                             _block(blip,error);
                                         }
                                         else {
                                             [Flurry endTimedEvent:kFlurryAPILikeBlip withParameters:nil];
                                             _block(blip,error);
                                         }
                                     }];
}

-(id<CancellableOperation>)unlike:(void (^)(Blip *, ServerModelError *))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIUnlikeBlip timed:YES];

    NSString *path = [NSString stringWithFormat:@"/blips/%@/likes",self.id];
    
    __block void (^_block)(Blip *,ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodDELETE
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         Blip* blip = nil;
                                         if (!error) {
                                             blip = (Blip*)model;
                                             [blip changeServerInstancesUsingKeyValues:@{
                                              @"likes": [result objectForKey:@"likes"]}];
                                             [blip.author changeServerInstancesUsingKeyValues:@{
                                              @"stats": blip.author.stats}];                                             
                                         }
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"author", blip.author.id,
                                                                 @"place", blip.place.id,
                                                                 @"blip", blip.id,
                                                                 @"count", @(blip.likes.likers.count),
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIUnlikeBlip withParameters:params];
                                         _block(blip,error);
                                     }];
}

-(id<CancellableOperation>) markRead:(void (^)(ServerModelError *error))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIMarkBlipRead timed:YES];
    
    NSString *path = [NSString stringWithFormat:@"/blips/%@/received/mark-read",self.id];
    
    __block void (^_block)(ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         [self changeServerInstancesUsingKeyValues:@{@"_isRead":@(YES)}];
                                         NSDictionary* params = [Flurry paramsWithError:error,
                                                                 @"author", self.author.id,
                                                                 @"place", self.place.id,
                                                                 @"blip", self.id,
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIMarkBlipRead withParameters:params];
                                         _block(error);
                                     }];
}


#pragma mark -
#pragma mark MKMapAnnotation implementation

-(CLLocationCoordinate2D)coordinate {
    return self.place.location.coreLocation.coordinate;
}

-(NSString *)title {
    return @" "; // handled by BlipPin
}

-(NSString *)subtitle {
    return @" "; // handled by BlipPin
}

+(int) getPlaceCountWithUnreadBlips:(NSMutableArray*) blips
{
    NSMutableDictionary* unreadPlacesBlips = [[NSMutableDictionary alloc] init];
    for (Blip* blip in blips) {
        if(!blip.isRead) {
            [unreadPlacesBlips setValue:[NSNumber numberWithBool:YES]  forKey:blip.place.id];
        }
    }
    return unreadPlacesBlips.count;
}

@end

