//
//  ServerModelRequests.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerModelRequests : NSObject
+(ServerModelRequests *)sharedRequests;
-(void)rememberRequest:(RKRequest *)request;
-(void)forgetRequest:(RKRequest *)request;
@end