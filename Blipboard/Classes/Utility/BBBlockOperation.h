//
//  BBBlockOperation.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//


#import <Foundation/Foundation.h>
// adds support for an optional cancellation block which gets called
// when operation is cancelled
@interface BBBlockOperation : NSBlockOperation
@property (nonatomic,strong) void (^cancellationBlock)();
@end

