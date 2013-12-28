//
//  AccountCaps.h
//  Blipboard
//
//  Created by Jason Fischl on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountCaps : NSObject

@property (nonatomic,strong) NSNumber* _disableSharing;
@property (nonatomic) BOOL disableSharing;
@property (nonatomic,strong) NSNumber *_disableStartupNotifications;
@property (nonatomic) BOOL disableStartupNotifications;
@end
