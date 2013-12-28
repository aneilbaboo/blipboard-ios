//
//  SlideoutMenuNotificationCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/23/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "BBImageView.h"
#import "BBBadgeView.h"

typedef enum {
    SlideoutMenuNotificationCellFirst,
    SlideoutMenuNotificationCellMiddle,
    SlideoutMenuNotificationCellOnly,
    SlideoutMenuNotificationCellLast
} SlideoutMenuNotificationCellStyle;

@interface SlideoutMenuNotificationCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIView *background;
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UILabel *subtitle;
@property (nonatomic,weak) IBOutlet UIView *pictureBackground;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIImageView *divider;
@property (nonatomic,weak) IBOutlet BBBadgeView *statusBadge; // signifies unread state or status
@property (nonatomic,weak) IBOutlet UIImageView *checkMark;

+(SlideoutMenuNotificationCell *)cell;
+(NSString *)reuseIdentifier;
+ (CGFloat)heightFromNotification:(Notification *)notification;
- (void)configureWithNotification:(Notification *)notification style:(SlideoutMenuNotificationCellStyle)style;
@end
