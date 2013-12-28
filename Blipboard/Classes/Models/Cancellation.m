//
//  CancellableOperation.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Cancellation.h"


@implementation CancellableOperationBlock

+(id)cancellableOperationWithBlock:(void (^)())block {
    return [[CancellableOperationBlock alloc] initWithBlock:block];
}

-(id)initWithBlock:(void (^)())block {
    _block = block;
    return [self init];
}

-(void)cancelOperation {
    if (_block) {
        _block();
    }
    _block = nil;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[CancellableOperationBlock #%X %@]",(int)self, self.name];
}

@end

@implementation Cancellation

+(id)cancellation {
    return [[Cancellation alloc] init];
}

-(id)init {
    _operations = [NSMutableArray arrayWithCapacity:1];
    return self;
}

-(id)initWithOperation:(id<CancellableOperation>)operation {
    self = [self init];
    [self addOperation:operation];
    return self;
}

-(void)addOperationNamed:(NSString *)name block:(void (^)())block {
    if (block) {
        CancellableOperationBlock *cb = [CancellableOperationBlock cancellableOperationWithBlock:block];
        cb.name = name;
        [self addOperation:cb];
    }
}

-(void)addOperationBlock:(void (^)())block {
    [self addOperationNamed:nil block:block];
}

-(void)addOperation:(id<CancellableOperation>)operation {
    if (operation) {
        if (!_operations) {
            _operations = [NSMutableArray arrayWithCapacity:1];
        }
        [_operations addObject:operation];
    }
}

-(void)removeOperation:(id<CancellableOperation>)operation {
    [_operations removeObject:operation];
}

-(void)cancel {
    if (_operations) {
        for (id<CancellableOperation> operation in _operations) {
            if (![operation isKindOfClass:[self class]]) {
                BBLog(@"cancelling %@",operation);
            }
            [operation cancelOperation];
        }
        _operations = nil;
    }
}

-(BOOL)isCancelled {
    return (_operations==nil);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Cancellation %@]",_operations];
}

#pragma mark -
#pragma mark CancellableOperation
-(void)cancelOperation {
    [self cancel];
}

@end