//
//  ReturnedOperation.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/25/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ServerModel.h"

@interface ReturnedOperation : ServerModel
@property (nonatomic,strong) NSString *uri;
@property (nonatomic,strong) NSString *method;
@property (nonatomic,strong) NSDictionary *params;

+(RKObjectMapping *)mapping;
-(id<CancellableOperation>)makeCallWithBlock:(void (^)(NSDictionary *result,ServerModelError *error))block;

@end
