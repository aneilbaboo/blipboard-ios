//
//  BBError.h
//  Blipboard
//
//  Created by Jason Fischl on 4/18/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBError : NSObject

@property (nonatomic,strong) NSString* message;
@property (nonatomic,strong) NSString* type;
@property NSInteger statusCode;

+(RKObjectMapping *)mapping;

@end
