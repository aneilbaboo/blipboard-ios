//
//  FlurryAnalytics+Blipboard.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Flurry.h>

NSString * const kFlurryAPIUpdateFacebookToken;
NSString * const kFlurryAPICreateFacebook;
NSString * const kFlurryAPICreateAnonymous;

NSString * const kFlurryAPIFollow;
NSString * const kFlurryAPIUnfollow;
NSString * const kFlurryAPIFollowers;
NSString * const kFlurryAPIFollowing;
NSString * const kFlurryAPIBlipStream;

NSString * const kFlurryAPIDeleteComment;

NSString * const kFlurryAPIGetPopularBlips;
NSString * const kFlurryAPIGetReceivedBlips;
NSString * const kFlurryAPIGetMyBlips;
NSString * const kFlurryAPIGetChannel;
NSString * const kFlurryAPIGetBlip;
NSString * const kFlurryAPIAddComment;
NSString * const kFlurryAPILikeBlip;
NSString * const kFlurryAPIUnlikeBlip;
NSString * const kFlurryAPIMarkBlipRead;
NSString * const kFlurryAPIPlaceBroadcast;
NSString * const kFlurryAPIMarkBlipsAtPlaceRead;

NSString * const kFlurryUserTrackingOn;
NSString * const kFlurryUserTrackingOff;
NSString * const kFlurryToggleToMap;
NSString * const kFlurryToggleToList;

NSString * const kFlurryMapZoom;
NSString * const kFlurryMapPan;
NSString * const kFlurryMapTapped;

NSString * const kFlurryMapUnsupportedRegion;
NSString * const kFlurryAlertBlipComment;
NSString * const kFlurryAlertBlipLike;
NSString * const kFlurryAlertBlip;
NSString * const kFlurryAlertFollow;
NSString * const kFlurryAlertBadge;

NSString * const kFlurryStart;
NSString * const kFlurryDisabledPushNotifications;
NSString * const kFlurryEnabledPushNotifications;
NSString * const kFlurryWarningLocationServicesDisabled;
NSString * const kFlurryUserEnabledLocation;
NSString * const kFlurryUserDisabledLocation;
NSString * const kFlurryPromptUserToEnablePushNotifications;

NSString * const kFlurrySlideoutOpen;
NSString * const kFlurrySlideoutMenuItemTapped;
NSString * const kFlurrySlideoutNotificationTapped;

NSString * const kFlurryNotificationInForeground;
NSString * const kFlurryNotificationInBackground;
NSString * const kFlurryNotificationStartedWithBadge;
NSString * const kFlurryNotificationsDisabled;
NSString * const kFlurryNotificationsEnabled;

NSString * const kFlurryBlipDetailHide;
NSString * const kFlurryBlipDetailShow;
NSString * const kFlurryBlipCellLikePressed;
NSString * const kFlurryBlipCellCommentPressed;
NSString * const kFlurryBlipDetailComment;
NSString * const kFlurryBlipDetailAuthor;
NSString * const kFlurryBlipDetailUnfollow;
NSString * const kFlurryBlipDetailFollow;

NSString * const kFlurryBlipDetailNavBar;
NSString * const kFlurryBlipDetailNoteBar;
NSString * const kFlurryBlipDetailTap;
NSString * const kFlurryBlipDetailUpswipe;
NSString * const kFlurryBlipDetailDownswipe;
NSString * const kFlurryBlipDetailUnlike;
NSString * const kFlurryBlipDetailLike;

// commenting not quite in place
NSString * const kFlurryBlipDetailCommentStart;
NSString * const kFlurryBlipDetailCommentPost;
NSString * const kFlurryBlipDetailCommentCancel;

// Blip sharing
NSString * const kFlurryBlipDetailSharingStart;
NSString * const kFlurryBlipDetailSharingAbort;
NSString * const kFlurryBlipDetailSharingComplete;

NSString * const kFlurryBroadcastPlaceCancel;
NSString * const kFlurryBroadcastPlaceSelect;
NSString * const kFlurryBroadcastPost;
NSString * const kFlurryBroadcastCancel;
NSString * const kFlurryBroadcastTextEntry;
NSString * const kFlurryBroadcastTopicButton;
NSString * const kFlurryBroadcastTopicSelected;
NSString * const kFlurryBroadcastMapButton;
NSString * const kFlurryBroadcastSharingStart;
NSString * const kFlurryBroadcastSharingAbort;
NSString * const kFlurryBroadcastSharingComplete;

NSString * const kFlurryChannelBlips;
NSString * const kFlurryChannelFollowers;
NSString * const kFlurryChannelFollowing;
NSString * const kFlurryChannelDescription;
NSString * const kFlurryChannelUnfollow;
NSString * const kFlurryChannelFollow;
NSString * const kFlurryChannelWebsite;
NSString * const kFlurryChannelCall;
NSString * const kFlurryChannelDirections;
NSString * const kFlurryChannelPullHeader;

NSString * const kFlurryChannelCellFollow;
NSString * const kFlurryChannelCellUnfollow;
NSString * const kFlurryContentFollowing;
NSString * const kFlurryContentDiscover;
NSString * const kFlurryContentMyBlips;

NSString * const kFlurryError;
NSString * const kFlurryErrorDismissed;

NSString * const kFlurryGalleryStart;
NSString * const kFlurryGalleryLogin;
NSString * const kFlurryGalleryFBLogin;
NSString * const kFlurryGalleryPageSelected;

NSString * const kFlurryProfile;
NSString * const kFlurryProfileStartedEditing;
NSString * const kFlurryProfileSaved;
NSString * const kFlurryProfilePictureTapped;

NSString * const kFlurryWarningLowMemory;
NSString * const kFlurryInfoPressed;
NSString * const kFlurryMapGurusPressed;
NSString * const kFlurryGuruList;
NSString * const kFlurryBroadcastAtPlace;
NSString * const kFlurryMapBroadcast;

NSString * const kFlurryAllErrors;
NSString * const kFlurryServerModelError;
NSString * const kFlurrySSLError;

//NSString * const kFlurryStartLocation = @"start-location";
//NSString * const kFlurryAPIReportLocation = @"reportLocation";

@interface Flurry (Blipboard)
// encodes the error (if provided) & any non-nil values into a dictionary

+(void)logEventWithParams:(NSString *)eventName,...;
+(void)logEvent:(NSString *)eventName withErrorAndParams:error,...;

+(void)endTimedEventWithParams:(NSString *)eventName,... ;
+(void)endTimedEvent:(NSString *)eventName withErrorAndParams:error,...;

+(NSMutableDictionary *)paramsWithError:(NSError *)error,...;

+(NSMutableDictionary *)paramsWithError:(NSError *)error
                            extraParams:(NSDictionary *)extraParams,...;

+(NSMutableDictionary *)paramsWithError:(NSError *)error
                            extraParams:(NSDictionary *)extraParams
                        andKeyValueList:(va_list)argp;
@end
