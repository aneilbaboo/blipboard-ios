//
//  ReturnedOperation.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/25/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ReturnedOperation.h"

@implementation ReturnedOperation
+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"uri",        @"uri",
     @"method",     @"method",
     @"params",     @"params",
     nil];
    return mapping;
}

-(id<CancellableOperation>)makeCallWithBlock:(void (^)(NSDictionary *result,ServerModelError *error))block {
    __block void (^blockBlock)(NSDictionary *,ServerModelError *) = block;
    RKRequestMethod method = RKRequestMethodTypeFromName([self.method uppercaseString]);
    return [self loadObjectsAtResourcePath:self.uri
                                withMethod:method
                                 andParams:self.params
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         blockBlock(result,error);
                                     }];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[ReturnedOperation %@ %@ %@]",
            self.method,self.uri,self.params];
}
@end
