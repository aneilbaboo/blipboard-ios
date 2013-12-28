//
//  Notification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/12/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ServerModel.h"
#import "Blip.h"
#import "Comment.h"
#import "Liker.h"
#import "Channel.h"
#import "Paging.h"
#import "PlaceChannel.h"


// !am! Note: this enum must be kept in sync with the
//            ChannelDetailTab enum !!
typedef enum {
    ChannelNotificationDisplayBlips = 0, // = ChannelDetailTabBlips
    ChannelNotificationDisplayFollowers = 1, // = = ChannelDetailTabFollowers
    ChannelNotificationDisplayFollowing = 2, // etc
    ChannelNotificationDisplayUnknown
} ChannelNotificationDisplay;

@protocol NotificationActions <NSObject>
-(void)showChannel:(Channel *)channel andDisplay:(ChannelNotificationDisplay)display;
-(void)showGuruList;
-(void)showBlip:(Blip *)blip withLiker:(Channel *)liker;
-(void)showBlip:(Blip *)blip withComment:(NSString *)commentId;
-(void)showBlip:(Blip *)blip;
-(void)showProfileEditor;
-(void)showCreateBlip:(PlaceChannel *)place;
-(void)showWebViewWithURL:(NSString *)url andTitle:(NSString *)title;
@end


@interface Notification : ServerModel
@property (nonatomic, strong)   NSString *type; // !am! server should rename to "action"
@property (nonatomic, strong)   NSNumber *_isNew; // sent from the server
@property (nonatomic)           BOOL isNew; // convenience
@property (nonatomic)           BOOL isUnreadLocally; // true if item has not been tapped locally
@property (nonatomic,strong)    NSDate *time;
@property (nonatomic,strong)    NSString *status; // optional status (e.g., TODO, done, etc.)
@property (nonatomic, strong)   NSString *id;
@property (nonatomic, strong)   NSString *title;
@property (nonatomic, strong)   NSString *subtitle;
@property (nonatomic, strong)   NSString *picture;
@property (nonatomic, strong)   UIImage *pictureImage;
@property (nonatomic, strong)   BOOL ((^isNewBlock)()); // dynamically calculate the isNew value

+(RKDynamicObjectMapping *)dynamicMapping;
+(RKObjectMapping *)mapping;

// used be getNotifications to resolve the blipId,listenerId,likerId values to Blip or Channel objects
-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels;
-(void)takeAction:(id<NotificationActions>)responder;
@end
