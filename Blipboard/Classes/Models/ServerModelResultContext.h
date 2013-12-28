//
//  ServerModelResultContext.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ServerModelError.h"

@class ServerModel;
@class ServerModelError;


@interface ServerModelResultContext : NSObject <CancellableOperation>

@property (nonatomic,strong) ServerModelBlock block;
@property (nonatomic,strong) ServerModel *model;
@property (nonatomic,strong) NSDictionary *result;
@property (nonatomic,strong) ServerModelError *error;
@property (nonatomic,weak)   RKRequest *request;

-(id)initWithModel:(ServerModel *)model andBlock:(ServerModelBlock)block;
-(void)informDelegate;
-(BOOL)isCancelled;
@end