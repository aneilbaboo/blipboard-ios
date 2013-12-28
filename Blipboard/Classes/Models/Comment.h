//
//  Comment.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ServerModel.h"
#import "Channel.h"

@interface Comment : ServerModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) Channel  *author;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) NSDate   *createdTime;

+(RKObjectMapping *)mapping;
-(id<CancellableOperation>)delete:(void (^)(ServerModelError *))block;
-(NSString *)blipIdPart;
-(NSString *)commentIdPart;
@end
