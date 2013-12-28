//
//  Topic.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Topic.h"
#import "ASIDownloadCache.h"
#import "SystemVersion.h"

@implementation Topic

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id",             @"id",
     @"name",           @"name",
     @"description",    @"desc",
     @"picture",        @"picture",
     @"picture2x",      @"picture2x",
     nil];
    return mapping;
}

+(RKObjectMapping *)sequenceMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [mapping mapKeyPath:@"data" toRelationship:@"data" withMapping:[self mapping]];
    [mapping mapKeyPath:@"paging" toRelationship:@"paging" withMapping:Paging.mapping];
    return mapping;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Topic %@ (%@)]",self.id,self.name];
}

-(NSOperation *)loadPictureWithBlock:(void (^)(UIImage *image))block {
    
    if (self.pictureImage) {
        block(self.pictureImage);
        return nil;
    }
    else {
        // see http://stackoverflow.com/a/4641481/305149
        // we don't need to check for iOS version because we require at least 5.1:
        BOOL hasRetinaDisplay = ([UIScreen mainScreen].scale == 2.0);
        NSString *picture = hasRetinaDisplay ? self.picture2x : self.picture;
        __block CGFloat scale = hasRetinaDisplay ? 2.0 : 1.0;
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:picture]
                                                      usingCache:[ASIDownloadCache sharedCache]
                                                  andCachePolicy:ASICacheForSessionDurationCacheStoragePolicy];
        
        __unsafe_unretained ASIHTTPRequest *weakRequest = request;
        [request setShouldRedirect:YES];
          
        [request setCompletionBlock:^{
            self.pictureImage = [UIImage imageWithData:weakRequest.responseData scale:scale];
            [[UIApplication sharedApplication] popNetworkActivity];
            block(self.pictureImage);
        }];
        [request setFailedBlock:^{
            self.pictureImage = nil;
            [[UIApplication sharedApplication] popNetworkActivity];
            block(nil);
        }];
        [request startAsynchronous];
        
        [[UIApplication sharedApplication] pushNetworkActivity];
        return request;
    }
    
}


//-(NSOperation *)loadPicturesWithBlock:(void (^)())block {
//    if (self.pictureImage && self.pictureImage2x) {
//        block();
//        return nil;
//    }
//    else {
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.picture]
//                                                      usingCache:[ASIDownloadCache sharedCache]
//                                                  andCachePolicy:ASICacheForSessionDurationCacheStoragePolicy];
//        
//        ASIHTTPRequest *request2x = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.picture2x]
//                                                      usingCache:[ASIDownloadCache sharedCache]
//                                                  andCachePolicy:ASICacheForSessionDurationCacheStoragePolicy];
//        
//        __unsafe_unretained ASIHTTPRequest *weakRequest = request;
//        __unsafe_unretained ASIHTTPRequest *weakRequest2x = request2x;
//        [request setShouldRedirect:YES];
//        [request2x setShouldRedirect:YES];
//        
//        [request setCompletionBlock:^{
//            self.pictureImage = [UIImage imageWithData:weakRequest.responseData];
//        }];
//        [request2x setCompletionBlock:^{
//            self.pictureImage2x = [UIImage imageWithData:weakRequest2x.responseData];
//        }];
//
//        [request setFailedBlock:^{
//            self.pictureImage = nil;
//        }];
//        [request2x setFailedBlock:^{
//            self.pictureImage2x = nil;
//        }];
//        [request startAsynchronous];
//        [request2x startAsynchronous];
//        
//        [[UIApplication sharedApplication] pushNetworkActivity];
//        BBBlockOperation *combinedOperation = [BBBlockOperation blockOperationWithBlock:^{
//            [[UIApplication sharedApplication] popNetworkActivity];
//            block();
//        }];
//        [combinedOperation addDependency:request];
//        [combinedOperation addDependency:request2x];
//        
//        [[NSOperationQueue mainQueue] addOperation:combinedOperation];
//        
//        return combinedOperation;
//    }
//    
//}

@end
