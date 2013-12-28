//
//  Paging.h
//  Blipboard
//
//  Created by Vladimir Darmin on 5/2/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ServerModel.h"

@interface Paging : ServerModel

@property (nonatomic, strong) NSString *next;
@property (nonatomic, strong) NSString *prev;
@property (nonatomic, strong) NSString *dataKey;
@property (nonatomic, strong) NSString *pagingKey;

+(RKObjectMapping *)mapping;

-(id<CancellableOperation>)loadNextPage:(void (^)(NSMutableArray *data,Paging *newPaging,ServerModelError *error))block;
-(id<CancellableOperation>)loadPrevPage:(void (^)(NSMutableArray *data,Paging *newPaging,ServerModelError *error))block;

-(id)initWithNext:(NSString *)next andPrev:(NSString *)prev;

@end
