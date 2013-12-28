//
//  NotificationBar.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/26/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"
#import "Notification.h"

@interface BBNotificationBar : UIButton

+(id)notificationBar;

// directly set any of these properties to configure the notificationBar
// before calling show:
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subtitle;
@property (nonatomic,weak) IBOutlet UIView *imageViewBackground;
@property (nonatomic,weak) IBOutlet BBImageView *imageView;
@property (nonatomic) BOOL autoUpdate;  // If TRUE, handles BBRemoteNotificationManager stream updates
                                        // default: TRUE
@property (nonatomic) NSTimeInterval defaultTimeout; // timeout in seconds for showNotification
                                                     // and for autoUpdate notifications
                                                     // default: 15 seconds

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) void (^action)();

//
// If timeout>0, bar automatically hides (by retracting upwards)
//
-(void)show:(NSTimeInterval)timeout;

// convenience method which sets title, subtitle, imageview and action
// then calls show:
-(void)showNotification:(Notification *)notification timeout:(NSTimeInterval)timout;
-(void)showNotification:(Notification *)notification;

// retracts the bar upward & fades
-(void)hide:(BOOL)animated;

// alternate method of hiding the bar (only fades)
-(void)fade;
@end
