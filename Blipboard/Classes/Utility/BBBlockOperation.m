//
//  BBBlockOperation.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBBlockOperation.h"

@implementation BBBlockOperation
-(void)cancel {
    [super cancel];
    void (^cancellationBlock)();
    
    @synchronized (self) {
        if (self.cancellationBlock) {
            cancellationBlock = self.cancellationBlock;
            self.cancellationBlock = nil;
        }
    }
    if (cancellationBlock) {
        cancellationBlock();
    }
}

@end

