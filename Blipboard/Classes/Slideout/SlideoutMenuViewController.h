//
//  SlideoutMenuViewController.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationStream.h"
#import "Notification.h"
typedef enum {
    SlideoutMenuItemUnknown = -1,
    SlideoutMenuItemAccount = 0,
    SlideoutMenuItemBlips,
    SlideoutMenuItemGuruList,
    SlideoutMenuItemInfo,
    SlideoutMenuItemLast,
    SlideoutMenuItemTemporary=SlideoutMenuItemLast,
    SlideoutMenuItemLastWithTemporary
} SlideoutMenuItem;

@interface SlideoutMenuViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NotificationActions>
@property (nonatomic,strong) NotificationStream *notificationStream;

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) IBOutlet UIView *notificationsHeader;
@property (nonatomic,weak) IBOutlet UILabel *notificationsHeaderLabel;

+ (SlideoutMenuViewController *)sharedController;
-(void)showNotification:(Notification *)notification;
@end
