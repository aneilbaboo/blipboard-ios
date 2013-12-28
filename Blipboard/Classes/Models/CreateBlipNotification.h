//
//  CreateBlipNotification.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/10/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Notification.h"

@interface CreateBlipNotification : Notification
@property (nonatomic,strong) NSString *placeId;
@property (nonatomic,strong) PlaceChannel *place;
@end
