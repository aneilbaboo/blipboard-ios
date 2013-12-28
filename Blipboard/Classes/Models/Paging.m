//
//  Paging.m
//  Blipboard
//
//  Created by Vladimir Darmin on 5/2/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Paging.h"
#import "BBLog.h"

@implementation Paging

-(id)initWithNext:(NSString *)nextURI andPrev:(NSString *)prevURI
{
    self = [super init];
    
    self.next = nextURI;
    self.prev = prevURI;
    
    return self;
}

+(RKObjectMapping *)mapping { 
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"next", @"next",
     @"prev", @"prev",
     nil];
    return mapping;
}

-(id<CancellableOperation>)loadNextPage:(void (^)(NSMutableArray *data,Paging *newPaging,ServerModelError *error))block;
{
    BBLog(@"%@", self.next);
    if (self.next && self.next.length > 0) {
        __block void (^_block)(NSMutableArray *data,Paging *newPaging,ServerModelError *error) = block;
        return [self loadObjectsAtResourcePath: [self encodePipes:self.next]
                                         block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                             NSMutableArray *data;
                                             Paging         *newPaging;
                                             if (!error) {
                                                 data = [result objectForKey:self.dataKey];
                                                 newPaging = [result objectForKey:self.pagingKey];
                                                 newPaging.dataKey = self.dataKey;
                                                 newPaging.pagingKey = self.pagingKey;
                                             }
                                             _block(data,newPaging,error);
                                         } ];
        
    }
    else {
        return nil;
    }
}

-(id<CancellableOperation>)loadPrevPage:(void (^)(NSMutableArray *data,Paging *newPaging,ServerModelError *error))block;
{
    BBLog(@"%@", self.prev);
    if (self.prev && self.prev.length > 0) {
        __block void (^_block)(NSMutableArray *data,Paging *newPaging,ServerModelError *error) = block;
        return [self loadObjectsAtResourcePath: [self encodePipes:self.prev]
                                         block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                             NSMutableArray *data;
                                             Paging         *newPaging;
                                             if (!error) {
                                                 data = [result objectForKey:self.dataKey];
                                                 newPaging = [result objectForKey:self.pagingKey];
                                                 newPaging.dataKey = self.dataKey;
                                                 newPaging.pagingKey = self.pagingKey;
                                             }
                                             _block(data,newPaging,error);
                                         } ];
    }
    else {
        return nil;
    }
}

-(NSString *)encodePipes:(NSString *)uri
{
    return [[uri componentsSeparatedByString:@"|"] componentsJoinedByString:@"%7C"];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Paging next:'%@' prev:'%@'",
            self.next,self.prev];
}
@end
