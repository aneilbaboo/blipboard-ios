//
//  WebNotification.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/8/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "WebNotification.h"

@implementation WebNotification
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [super mapping];
    mapping.objectClass = [self class];
    [mapping mapKeyPath:@"url" toAttribute:@"url"];
    return mapping;
}

-(void)takeAction:(id<NotificationActions>)responder {
    [responder showWebViewWithURL:self.url andTitle:self.title];
}

-(NSString *)title {
    return super.title ? super.title : @"Blipboard";
}

-(BOOL)resolveBlips:(NSDictionary *)blips andChannels:(NSDictionary *)channels {
    return YES;
}

@end
