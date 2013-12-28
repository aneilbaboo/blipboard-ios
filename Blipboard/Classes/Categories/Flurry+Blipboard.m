//
//  Flurry+Blipboard.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Flurry+Blipboard.h"
#import "ServerModelError.h"
#import "BILib.h"

NSString * const kFlurryAPIUpdateFacebookToken = @"api-update-facebook-token";
NSString * const kFlurryAPICreateFacebook = @"api-create-facebook";
NSString * const kFlurryAPICreateAnonymous = @"api-create-anonymous";

NSString * const kFlurryAPIFollow = @"api-follow";
NSString * const kFlurryAPIUnfollow = @"api-unfollow";
NSString * const kFlurryAPIFollowers = @"api-followers";
NSString * const kFlurryAPIFollowing = @"api-following";
NSString * const kFlurryAPIBlipStream = @"api-blip-stream";

NSString * const kFlurryAPIDeleteComment = @"api-delete-comment";

NSString * const kFlurryAPIGetPopularBlips = @"api-get-popular-blips";
NSString * const kFlurryAPIGetReceivedBlips = @"api-get-received-blips";
NSString * const kFlurryAPIGetMyBlips = @"api-get-my-blips";
NSString * const kFlurryAPIGetChannel = @"api-get-channel";
NSString * const kFlurryAPIGetBlip = @"api-get-blip";
NSString * const kFlurryAPIAddComment = @"api-add-comment";
NSString * const kFlurryAPILikeBlip = @"api-like-blip";
NSString * const kFlurryAPIUnlikeBlip = @"api-unlike-blip";
NSString * const kFlurryAPIMarkBlipRead = @"api-mark-blip-read";
NSString * const kFlurryAPIPlaceBroadcast = @"api-place-broadcast";
NSString * const kFlurryAPIMarkBlipsAtPlaceRead = @"api-mark-blips-at-place-read";

NSString * const kFlurryUserTrackingOn = @"user-tracking-on";
NSString * const kFlurryUserTrackingOff = @"user-tracking-off";
NSString * const kFlurryToggleToMap = @"toggle-to-map";
NSString * const kFlurryToggleToList =@"toggle-to-list";

NSString * const kFlurryMapZoom = @"map-zoom";
NSString * const kFlurryMapPan = @"map-pan";
NSString * const kFlurryMapTapped = @"map-tapped";

NSString * const kFlurryMapUnsupportedRegion = @"map-unsupported-region";
NSString * const kFlurryAlertBlipComment = @"alert-blip-comment";
NSString * const kFlurryAlertBlipLike = @"alert-blip-like";
NSString * const kFlurryAlertBlip = @"alert-blip";
NSString * const kFlurryAlertFollow = @"alert-follow";
NSString * const kFlurryAlertBadge = @"alert-badge";

NSString * const kFlurryStart = @"start";
NSString * const kFlurryDisabledPushNotifications = @"pushnots-disabled";
NSString * const kFlurryEnabledPushNotifications = @"pushnots-enabled";
NSString * const kFlurryWarningLocationServicesDisabled = @"warning-locsvc-disabled";
NSString * const kFlurryUserEnabledLocation = @"user-enabled-location";
NSString * const kFlurryUserDisabledLocation = @"user-disabled-location";
NSString * const kFlurryPromptUserToEnablePushNotifications = @"pushnots-user-prompted-to-enable";

NSString * const kFlurrySlideoutOpen = @"menu-open";
NSString * const kFlurrySlideoutMenuItemTapped = @"menu"; // !am! menu-map menu-about, etc.
NSString * const kFlurrySlideoutNotificationTapped = @"menu-notification-tapped";

NSString * const kFlurryNotificationInForeground = @"notif-foreground";
NSString * const kFlurryNotificationInBackground = @"notif-background";
NSString * const kFlurryNotificationStartedWithBadge = @"notif-badge-start";
NSString * const kFlurryNotificationsDisabled = @"notif-disabled";
NSString * const kFlurryNotificationsEnabled = @"notif-enabled";

NSString * const kFlurryBlipDetailHide = @"blipd-hide";
NSString * const kFlurryBlipDetailShow = @"blipd-show";
NSString * const kFlurryBlipCellLikePressed = @"blipc-like-pressed";
NSString * const kFlurryBlipCellCommentPressed = @"blipc-comment-pressed";
NSString * const kFlurryBlipDetailComment = @"blipd-comment";
NSString * const kFlurryBlipDetailAuthor = @"blipd-author";
NSString * const kFlurryBlipDetailUnfollow = @"blipd-unfollow";
NSString * const kFlurryBlipDetailFollow = @"blipd-follow";

NSString * const kFlurryBlipDetailNavBar = @"blipd-navbar";
NSString * const kFlurryBlipDetailNoteBar = @"blipd-notebar";
NSString * const kFlurryBlipDetailTap = @"blipd-tap";
NSString * const kFlurryBlipDetailUpswipe = @"blipd-upswipe";
NSString * const kFlurryBlipDetailDownswipe = @"blipd-downswipe";
NSString * const kFlurryBlipDetailUnlike = @"blipd-unlike";
NSString * const kFlurryBlipDetailLike = @"blipd-like";
// commenting not quite in place
NSString * const kFlurryBlipDetailCommentStart = @"blipd-comment-start";
NSString * const kFlurryBlipDetailCommentPost = @"blipd-comment-post";
NSString * const kFlurryBlipDetailCommentCancel = @"blipd-comment-cancel";

NSString * const kFlurryBlipDetailSharingStart = @"blipd-sharing-start";
NSString * const kFlurryBlipDetailSharingAbort = @"blipd-sharing-abort";
NSString * const kFlurryBlipDetailSharingComplete = @"blipd-sharing-complete";

NSString * const kFlurryBroadcastPlaceCancel = @"broadcast-place-cancel";
NSString * const kFlurryBroadcastPlaceSelect = @"broadcast-place-select";
NSString * const kFlurryBroadcastPost = @"broadcast";
NSString * const kFlurryBroadcastCancel = @"broadcast-cancel";
NSString * const kFlurryBroadcastTextEntry = @"broadcast-text-entry";
NSString * const kFlurryBroadcastTopicButton = @"broadcast-topic-button";
NSString * const kFlurryBroadcastTopicSelected = @"broadcast-topic-select";
NSString * const kFlurryBroadcastMapButton = @"broadcast-map-button";
NSString * const kFlurryBroadcastSharingStart = @"broadcast-sharing-start";
NSString * const kFlurryBroadcastSharingAbort =  @"broadcast-sharing-abort";
NSString * const kFlurryBroadcastSharingComplete = @"broadcast-sharing-complete";

NSString * const kFlurryChannelBlips = @"channel-blips";
NSString * const kFlurryChannelFollowers = @"channel-followers";
NSString * const kFlurryChannelFollowing = @"channel-following";
NSString * const kFlurryChannelDescription = @"channel-description";
NSString * const kFlurryChannelUnfollow = @"channel-unfollow";
NSString * const kFlurryChannelFollow = @"channel-follow";
NSString * const kFlurryChannelWebsite = @"channel-website";
NSString * const kFlurryChannelCall = @"channel-call";
NSString * const kFlurryChannelDirections = @"channel-directions";
NSString * const kFlurryChannelPullHeader = @"channel-header-pull";

NSString * const kFlurryChannelCellFollow = @"channel-cell-follow";
NSString * const kFlurryChannelCellUnfollow = @"channel-cell-unfollow";
NSString * const kFlurryContentFollowing = @"content-following";
NSString * const kFlurryContentDiscover = @"content-discover";
NSString * const kFlurryContentMyBlips = @"content-myblips";

NSString * const kFlurryError = @"error";
NSString * const kFlurryErrorDismissed = @"error-dismissed";

NSString * const kFlurryGalleryStart = @"gallery-start";
NSString * const kFlurryGalleryLogin = @"gallery-login";
NSString * const kFlurryGalleryFBLogin= @"gallery-fblogin";
NSString * const kFlurryGalleryPageSelected = @"gallery-page-selected";

NSString * const kFlurryProfile = @"profile-start";
NSString * const kFlurryProfileEditDescription =  @"profile-description";
NSString * const kFlurryProfileSaved = @"profile-saved";
NSString * const kFlurryProfilePictureTapped = @"profile-picture";

NSString * const kFlurryWarningLowMemory = @"warning-low-memory";
NSString * const kFlurryInfoPressed = @"info-pressed";
NSString * const kFlurryMapGurusPressed = @"map-gurus-pressed";
NSString * const kFlurryBroadcastAtPlace = @"map-broadcast-at-place";
NSString * const kFlurryMapBroadcast = @"map-broadcast";
NSString * const kFlurryGuruList = @"guru-list";

NSString * const kFlurryAllErrors = @"all-errors";
NSString * const kFlurryServerModelError = @"server-model-error";
NSString * const kFlurrySSLError = @"SSL failure";

@implementation Flurry (Blipboard)

#if !defined CONFIGURATION_Release
+(void)load {
    Class flurry = [Flurry class];
    [BILib injectToClass:flurry selector:@selector(startSession:) postprocess:^(Class flurryClass, NSString *apiKey) {
        BBLog(@"[Flurry startSession:{apiKeyNotLogged}]");
    }];
    
    [BILib injectToClass:flurry selector:@selector(logEvent:) postprocess:^(Class flurryClass, NSString *event) {
        BBLog(@"[Flurry logEvent:%@]",event);
    }];
    
    [BILib injectToClass:flurry selector:@selector(logEvent:withParameters:) postprocess:^(Class flurryClass, NSString *event, NSDictionary *parameters) {
        BBLog(@"[Flurry logEvent:%@ withParameters:%@]",event,parameters);
    }];
    
    [BILib injectToClass:flurry selector:@selector(logEvent:timed:) postprocess:^(Class flurryClass, NSString *event, BOOL timed) {
        BBLog(@"[Flurry logEvent:%@ timed:%X]",event,timed);
    }];

    [BILib injectToClass:flurry selector:@selector(logEvent:withParameters:timed:) postprocess:^(Class flurryClass, NSString *event, NSDictionary *parameters, BOOL timed) {
        BBLog(@"[Flurry logEvent:%@ withParameters:%@ timed:%X]",event,parameters,timed);
    }];

    [BILib injectToClass:flurry selector:@selector(endTimedEvent:withParameters:) postprocess:^(Class flurryClass, NSString *event, NSDictionary *parameters) {
        BBLog(@"[Flurry endTimedEvent:%@ withParameters:%@]",event,parameters);
    }];
    
    [BILib injectToClass:flurry selector:@selector(logError:message:exception:) postprocess:^(Class flurryClass, NSString *errorID, NSString *message, NSException *exception) {
        BBLog(@"[Flurry logError:%@ message:%@ exception:%@]",errorID,message,exception);
    }];
    
    [BILib injectToClass:flurry selector:@selector(logError:message:error:) postprocess:^(Class flurryClass, NSString *errorID, NSString *message, NSError *error) {
        BBLog(@"[Flurry logError:%@ message:%@ error:%@]",errorID,message,error);
    }];
    
    
}
#endif

+(void)logEventWithParams:(NSString *)eventName,... {
    
    va_list argp;
    va_start(argp, eventName);
    
    NSMutableDictionary *params = [self paramsWithError:nil extraParams:nil andKeyValueList:argp];
    [Flurry logEvent:eventName withParameters:params];
    
    va_end(argp);
    
    
}

+(void)endTimedEventWithParams:(NSString *)eventName,... {
    va_list argp;
    va_start(argp,eventName);
    
    NSMutableDictionary *params = [self paramsWithError:nil extraParams:nil andKeyValueList:argp];
    [Flurry endTimedEvent:eventName withParameters:params];
    
    va_end(argp);
}
+(void)endTimedEvent:(NSString *)eventName withErrorAndParams:error,... {
    va_list argp;
    va_start(argp,error);
    
    NSMutableDictionary *params = [self paramsWithError:error extraParams:nil andKeyValueList:argp];
    [Flurry endTimedEvent:eventName withParameters:params];

    va_end(argp);
}

+(void)logEvent:(NSString *)eventName withErrorAndParams:(id)error, ... {
    va_list argp;
    va_start(argp, error);
    
    NSMutableDictionary *params = [self paramsWithError:error
                                            extraParams:nil
                                        andKeyValueList:argp];
    [Flurry logEvent:eventName withParameters:params];
    
    va_end(argp);
    
}

+(NSMutableDictionary *)paramsWithError:(NSError *)error,  ... {

    va_list argp;
    va_start(argp, error);
    
    NSMutableDictionary *result = [self paramsWithError:error extraParams:nil andKeyValueList:argp];
    va_end(argp);
    
    return result;
}

+(NSMutableDictionary *)paramsWithError:(NSError *)error
                            extraParams:(NSDictionary *)extraParams,... {
    
    va_list argp;
    va_start(argp, extraParams);
    
    NSMutableDictionary *result = [self paramsWithError:error
                                            extraParams:extraParams
                                        andKeyValueList:argp];
    va_end(argp);
    
    return result;
}

+(NSMutableDictionary *)paramsWithError:(NSError *)error
                            extraParams:(NSDictionary *)extraParams
                        andKeyValueList:(va_list)argp {
    
    NSMutableDictionary *params = extraParams ? [NSMutableDictionary dictionaryWithDictionary:extraParams] : [NSMutableDictionary dictionaryWithCapacity:10];

    if (error) {
        [params setValue:error.description forKey:@"error"];
        [params setValue:[NSString stringWithFormat:@"%@:%d",error.domain,error.code] forKey:@"error.domain:code"];
        if ([error isKindOfClass:[ServerModelError class]]) {
            ServerModelError *smError = (ServerModelError *)error;
            [params setValue:[NSString stringWithFormat:@"%d",[smError statusCode]] forKey:@"error.statusCode"];
            if (smError.type) {
                [params setValue:smError.type forKey:@"error.type"];
            }
        }
    }
    
    NSString *key = va_arg(argp, NSString *);
    while (key) {
        NSString *value = va_arg(argp, NSString *);
        
        // only copy the values if they're non-nil
        if (value) {
            [params setValue:value forKey:key];
        }
        
        key = va_arg(argp, NSString *);
    }
    va_end(argp);
    return params;
}

@end
