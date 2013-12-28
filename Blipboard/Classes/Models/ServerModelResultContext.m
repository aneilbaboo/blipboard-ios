//
//  ServerModelServerModelResultContext.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ServerModelResultContext.h"
#import "ServerModelRequests.h"
#import "BBLog.h"

@implementation ServerModelResultContext

-(id)initWithModel:(ServerModel *)model andBlock:(ServerModelBlock)block {
    self.model = model;
    self.block = block;
    _result = nil;
    _error = nil;
    return self;
}

-(void)informDelegate {
    if (self.request) {
        ServerModelBlock block = self.block;
        block(self.model, self.result,self.error);
        self.request = nil;
    }
}

-(BOOL)isCancelled {
    return _request==nil;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[ServerModelResultContext %@ #%X %@ %@ %@]",
            self.model,
            (uint)self.request,
            [self.request methodName],
            [self.request resourcePath],
            [self.request params]];
}

#pragma mark CancellableOperation
-(void)cancelOperation {
    if (self.request) {
        logRKRequest(self.request);
        [self.request cancel];
        [[ServerModelRequests sharedRequests] forgetRequest:self.request];
        self.request = nil;
    }
}

@end
