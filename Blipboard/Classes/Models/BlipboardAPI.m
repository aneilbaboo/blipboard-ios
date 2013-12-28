//
//  BlipboardAPI.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BlipboardAPI.h"

@implementation BlipboardAPI
+(BlipboardAPI *)sharedAPI {
    static BlipboardAPI *sharedAPI;
    if (!sharedAPI) {
        sharedAPI = [BlipboardAPI new];
    }
    return sharedAPI;
}

@end
