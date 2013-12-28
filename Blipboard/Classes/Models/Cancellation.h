//
//  CancellableOperation.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

// protocol for anything that needs to be cancelled at a later time
@protocol CancellableOperation <NSObject>
-(void)cancelOperation;
@end

// An easy way to create CancellableOperations without creating a class & implementing the protocol:
// Or just use [Cancellation addOperationBlock:], which creates a CancellableOperationBlock on your behalf.
@interface CancellableOperationBlock : NSObject <CancellableOperation> {
    void (^_block)();
}
@property (nonatomic,strong) NSString *name;

+(id)cancellableOperationWithBlock:(void (^)())block;
-(id)initWithBlock:(void (^)())block;
-(void)cancelOperation;
@end


// Cancellation holds 0 or more CancellableOperations.  
// Calling cancel cancels all of the CancellableOperations.
// (This allows chaining together a number of cancellable
@interface Cancellation : NSObject <CancellableOperation> {
    NSMutableArray *_operations;
}

-(id)init;
+(id)cancellation;
-(void)cancel;
-(BOOL)isCancelled;

// adds an operation to the list of things to cancel
-(void)addOperationNamed:(NSString *)name block:(void (^)())block;
-(void)addOperationBlock:(void (^)())block;
-(void)addOperation:(id<CancellableOperation>)operation;
-(void)removeOperation:(id<CancellableOperation>)operation;
@end

