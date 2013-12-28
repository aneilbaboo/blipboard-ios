//
//  Comment.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Comment.h"
#import "BBLog.h"
#import "Flurry+Blipboard.h"

@implementation Comment
-(NSString *) description {
    return [NSString stringWithFormat:@"[Comment:%@ author:%@ text:%@ createdTime:%@]",
            self.id, self.author, self.text, self.createdTime ];
}

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id", @"id",
     @"text", @"text",
     @"createdTime", @"createdTime",
     nil];
    [mapping mapRelationship:@"author" withMapping:Channel.dynamicMapping];
    return mapping;
}

-(NSString *)blipIdPart {
    return [[self.id componentsSeparatedByString:@"_"] objectAtIndex:0];
}

-(NSString *)commentIdPart {
    return [[self.id componentsSeparatedByString:@"_"] objectAtIndex:1];
}

-(id<CancellableOperation>)delete:(void (^)(ServerModelError *))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIDeleteComment timed:YES];

    NSString *path = [NSString stringWithFormat:@"/blips/comments/%@",self.id];
    
    __block void (^_block)(ServerModelError *) = block;
    __weak Comment *weakSelf = self;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodDELETE
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         
                                         NSDictionary* params = [Flurry paramsWithError:error,     @"blipId", weakSelf.blipIdPart,
                                                                 @"commentId", weakSelf.id,
                                                                 @"authorid", weakSelf.author.id,
                                                                 nil];
                                         [Flurry endTimedEvent:kFlurryAPIDeleteComment withParameters:params];
                                         _block(error);
                                         
                                     }];
}

@end
