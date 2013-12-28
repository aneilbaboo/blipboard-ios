//
//  Topic.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "ServerModel.h"

@interface Topic : ServerModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString *picture2x;
@property (nonatomic,strong) UIImage *pictureImage;

+(RKObjectMapping *)mapping;
+(RKObjectMapping *)sequenceMapping;


-(NSOperation *)loadPictureWithBlock:(void (^)(UIImage *image))block;

@end
