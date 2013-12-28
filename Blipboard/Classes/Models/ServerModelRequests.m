//
//  ServerModelRequests.m
//  This class replaces RKRequestQueue, which was giving us funny timeout log messages, and
//  holding onto requests long after they were finished.
//  The RestKit developers are abandoning RKRequestQueue because it's buggy (https://github.com/RestKit/RestKit/issues/896)
//
//  ServerModelRequests is not a queue, but merely keeps a reference to each outstanding request, and releases it
//  when the request is finished (this logic is in ServerModel).
//
//  Created by Aneil Mallavarapu on 9/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBLog.h"
#import "ServerModelRequests.h"

id gSharedServerModelRequests;

@implementation ServerModelRequests  {
    NSMutableDictionary *_requests;
}

+(ServerModelRequests *)sharedRequests {
    if (!gSharedServerModelRequests) {
        gSharedServerModelRequests = [ServerModelRequests new];
    }
    return gSharedServerModelRequests;
}

-(id)init {
    self = [super init];
    _requests = [NSMutableDictionary dictionaryWithCapacity:10];
    return self;
}

-(void)rememberRequest:(RKRequest *)request {
    [_requests setObject:request forKey:[ServerModelRequests keyForRequest:request]];
    [[UIApplication sharedApplication] pushNetworkActivity];
//    BBLog(@"#%X (total:%d)", (int)request,_requests.count);
}

-(void)forgetRequest:(RKRequest *)request {
    [_requests removeObjectForKey:[ServerModelRequests keyForRequest:request]];
    [[UIApplication sharedApplication] popNetworkActivity];
//    BBLog(@"#%X (total:%d)", (int)request,_requests.count);
//    for (NSString *key in _requests) {
//        RKRequest *request =[_requests objectForKey:key];
//        BBLog(@"#%X: %@",(int)request,request.URL);
//    }
}

+(NSString *)keyForRequest:(RKRequest *)request {
    return [NSString stringWithFormat:@"%X",(int)request];
}

@end