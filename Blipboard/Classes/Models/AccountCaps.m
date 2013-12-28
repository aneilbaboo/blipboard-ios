//
//  AccountCaps.m
//  Blipboard
//
//  Created by Jason Fischl on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "AccountCaps.h"

@implementation AccountCaps
@dynamic disableSharing;
@dynamic disableStartupNotifications;

-(BOOL)disableSharing {
    return self._disableSharing.boolValue;
}

-(void)setDisableSharing:(BOOL)value {
    self._disableSharing = @(value);
}

-(BOOL)disableStartupNotifications {
    return self._disableStartupNotifications.boolValue;
}

-(void)disableStartupNotifications:(BOOL)value {
    self._disableStartupNotifications = @(value);
}


+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping mapKeyPathsToAttributes:
     @"disableSharing", @"_disableSharing",
     @"disableStartupNotifications", @"_disableStartupNotifications",     
     nil];
    
    return mapping;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"[AccountCaps disableSharing:%d, disableStartupNotifications:%d]",
            self.disableSharing,
            self.disableStartupNotifications];
}

@end
