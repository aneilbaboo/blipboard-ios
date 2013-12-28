//
//  SlideoutMenuNotificationCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/23/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SlideoutMenuNotificationCell.h"
#import "UIColor+BBSlideout.h"

NSString * const kSMNCReuseIdentifier = @"SlideoutMenuNotificationCell";


@implementation SlideoutMenuNotificationCell
+(SlideoutMenuNotificationCell *)cell {
    SlideoutMenuNotificationCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SlideoutMenuNotificationCell" owner:nil options:nil] objectAtIndex:0];
    cell.rx = 50;
    [cell _setStaticStyle];
    return cell;
}

+(NSString *)reuseIdentifier {
    return kSMNCReuseIdentifier;
}

+ (CGFloat)heightFromNotification:(Notification *)notification {
    CGFloat messageHeight = [notification.subtitle
                             sizeWithFont:[self _subtitleFont]
                             constrainedToSize:[self _subtitleMaxSize]
                             lineBreakMode:NSLineBreakByTruncatingTail].height;
    return messageHeight + [self _subtitleYPos] + [self _subtitleBottomMargin];
}

// helpers to calculate height
+ (CGFloat)_subtitleYPos {
    return 23;
}

+ (CGFloat)_subtitleBottomMargin {
    return 12;
}

+ (UIFont *)_subtitleFont {
    return [UIFont bbFont:12];
}

+ (CGSize)_subtitleMaxSize {
    return CGSizeMake(170, 170);
}

- (void)configureWithNotification:(Notification *)notification style:(SlideoutMenuNotificationCellStyle)style {
    [self.title setText:notification.title];
    [self.subtitle setText:notification.subtitle];
    CGSize fitSize = [self.subtitle sizeThatFits:[SlideoutMenuNotificationCell _subtitleMaxSize]];
    BBLogLevel(4, @"%@, fitsize:%@",notification,NSStringFromCGSize(fitSize));
    self.subtitle.height = fitSize.height;
    self.subtitle.ry = [SlideoutMenuNotificationCell _subtitleYPos];
    self.height = [SlideoutMenuNotificationCell heightFromNotification:notification];
    self.divider.ry = self.height - self.divider.height;    
    
    if (notification.pictureImage) { // local notifications may provide an image
        self.picture.image = notification.pictureImage;
    }
    else {
        [self.picture setImageWithURLString:notification.picture placeholderImage:nil];
    }
    
    self.divider.hidden = ((style==SlideoutMenuNotificationCellLast) ||
                           (style==SlideoutMenuNotificationCellOnly) );
    
    self.checkMark.hidden = YES;
    if (notification.status) {
        self.statusBadge.text = notification.status;
        if ([notification.status isEqualToString:@"done"]) {
            self.statusBadge.hidden = YES;
            self.checkMark.hidden = NO;
        }
        CGPoint badgeCenter = self.statusBadge.center;
        [self.statusBadge sizeToFit];
        self.statusBadge.center = badgeCenter;
    }
    else {
        self.statusBadge.text = @" ";
        self.statusBadge.hidden = !notification.isUnreadLocally;
        CGPoint badgeCenter = self.statusBadge.center;
        self.statusBadge.size = CGSizeMake(28, 28);
        self.statusBadge.center = badgeCenter;
    }
    
    switch (style) {
        case SlideoutMenuNotificationCellFirst:
            [self.background roundCorners:UIRectCornerTopLeft|UIRectCornerTopRight xRadius:4 yRadius:4];
            break;

        case SlideoutMenuNotificationCellLast:
            [self.background roundCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight xRadius:4 yRadius:4];
            break;
            
        case SlideoutMenuNotificationCellOnly:
            [self.background roundCorners:UIRectCornerAllCorners xRadius:4 yRadius:4];
            break;
            
        default:
            [self.background roundCorners:0 xRadius:0 yRadius:0];
            break;
    }
}

- (void)_setStaticStyle {
    [self.title setFont:[UIFont bbBoldFont:12]];
    [self.title setTextColor:[UIColor bbSlideoutNotificationTitleColor]];
    [self.subtitle setFont:[SlideoutMenuNotificationCell _subtitleFont]];
    [self.subtitle setTextColor:[UIColor bbSlideoutNotificationSubtitleColor]];
    [self.subtitle setNumberOfLines:0];
    [self.subtitle setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.background setBackgroundColor:[UIColor bbSlideoutNotificationBackground]];
    [self.pictureBackground roundCorners:UIRectCornerAllCorners xRadius:3 yRadius:3];
    [self.pictureBackground setBackgroundColor:[UIColor bbSlideoutNotificationPictureBackground]];

    [self.picture roundCorners:UIRectCornerAllCorners xRadius:3 yRadius:3];
    self.picture.layer.backgroundColor = [UIColor bbSlideoutNotificationsTableBackground].CGColor;
    
    self.selectedBackgroundView = [[UIView alloc] init];
    [self.selectedBackgroundView setBackgroundColor:[UIColor bbSlideoutNotificationBackground]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.statusBadge.textColor = [UIColor bbGray1];
    self.statusBadge.tintColor = [UIColor bbOrange];
    self.statusBadge.font = [UIFont bbCondensedBoldFont:14];
    self.statusBadge.borderWidth = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.background setBackgroundColor:[UIColor bbSlideoutNotificationSelectedBackground]];
    }
    else {
        [self.background setBackgroundColor:[UIColor bbSlideoutNotificationBackground]];
    }
}

@end
