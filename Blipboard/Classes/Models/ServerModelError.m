//
//  ServerModelError.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//
#import "Flurry+Blipboard.h"

#import "BBEnvironment.h"
#import "ServerModelError.h"
#import "ServerModelResultContext.h"
#import "ServerModel.h"
#import "BBError.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "BBLog.h"
#import "Reachability.h"
#import "BBAppDelegate.h"

NSDate *HTTPDateToNSDate(NSString *string);
NSNumber *timeIntervalFromHTTPRetryAfterData(NSString *string);

#pragma mark NSCancellableTimer
// NSTimer 
@interface NSTimer (CancellableOperation) <CancellableOperation>
@end

@implementation NSTimer (CancellableOperation)
-(void)cancelOperation { [self invalidate];  }
@end

#pragma mark -
#pragma mark ServerModelError
@implementation ServerModelError {
    UIAlertView* _retryView;
    BBError *_bberror;
}

+(id)errorWithNSError:(NSError *)error andRequest:(RKRequest *)request {
    ServerModelError *smError = [self errorWithDomain:error.domain code:error.code request:request]; // !am! reports error to Flurry
    NSArray *errors = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
    smError->_bberror = [errors objectAtIndex:0];
    smError->_bberror.statusCode = [[request response] statusCode];
    return smError;
}

+(id)errorWithDomain:(NSString *)domain code:(NSInteger)code request:(RKRequest *)request {
    NSDictionary *userInfo;
    if (request) {
        userInfo = [NSDictionary dictionaryWithObject:request forKey:@"request"];
    }

    ServerModelError* sme = [super errorWithDomain:domain code:code userInfo:userInfo];
    [Flurry logError:kFlurryServerModelError message:[sme message] error:sme];
    [Flurry logEvent:kFlurryAllErrors
               withParameters:
     @{@"error.domain:code":[NSString stringWithFormat:@"%@:%d",sme.domain,sme.code],
     @"error.type":sme.type ? sme.type : @""}];
    return sme;
}

-(BOOL)retryable {
    return (self.userInfo &&
            [(NSDictionary *)self.userInfo valueForKey:@"request"] &&
            [[(NSDictionary *)self.userInfo valueForKey:@"request"] isKindOfClass:[RKRequest class]]);
}

-(NSTimeInterval)retryAfterHeader {
    if (self.statusCode==503 && self.userInfo) {
        RKRequest *request = [self.userInfo objectForKey:@"request"];
        if (request) {
            NSNumber *retryAfterInterval = timeIntervalFromHTTPRetryAfterData([request.response.allHeaderFields objectForKey:@"RETRY-AFTER"]);
            return [retryAfterInterval floatValue];
        }
        
    }
    return -1;
}

-(void)_retryOnTimerFired:(NSTimer *)timer {
    Cancellation *cancellation = timer.userInfo;
    [cancellation addOperation:[self retry]];
}

-(BOOL)retryAfter:(NSTimeInterval)interval withCancellation:(Cancellation *)cancellation {
    if (interval>=0) {
        BBLog(@"#%X %@ %@ scheduled for %f seconds",
              (uint)self.request,
              self.request.methodName,
              self.request.resourcePath,
              interval);
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self 
                                                        selector:@selector(_retryOnTimerFired:) 
                                                        userInfo:cancellation 
                                                         repeats:NO];
        
        [cancellation addOperation:timer];
        return YES;
    }
    return NO;
}

-(RKObjectLoader *)request {
    return [self.userInfo valueForKey:@"request"];
}

-(id<CancellableOperation>)retry {
    RKObjectLoader *request = self.request;
    ServerModelResultContext *resultContext = request.userData;

    // !am! work around for Apple's TLS problems
    if ([self.domain isEqualToString:NSURLErrorDomain] &&
        self.code == NSURLErrorSecureConnectionFailed) {
        // http://stackoverflow.com/questions/13369386/how-to-cancel-a-persistent-connection-using-nsurlconnection
        // Official apple doc on the TLS session cache: http://developer.apple.com/library/ios/#qa/qa1727/_index.html
        // "There's no direct way to flush the TLS session cache (other than to terminate the process itself), nor is there a way to tell NSURLConnection not to use it (r. 8957312) ."
        // WTF!?!?!?!?!?!?!??!

        NSString *newBaseURI = [[BBEnvironment sharedEnvironment] next_apiURL];
        BBLog(@"SSL connection error detected.  Selecting a new base URI:%@",newBaseURI);
        [Flurry logError:kFlurrySSLError
                          message:[NSString stringWithFormat:@"Retrying with new baseURI:%@",newBaseURI]
                            error:self];
        
        [BBAppDelegate setBaseURI:newBaseURI];
    }
    
    BBLog(@"#%X %@ %@ %@ (retrying)",
          (uint)request,
          request.methodName,
          request.resourcePath,
          request.params);
    assert(resultContext.model);
    return [resultContext.model loadObjectsAtResourcePath:request.resourcePath 
                                               withMethod:request.method
                                                andParams:(NSDictionary *)request.params
                                      andBackgroundPolicy:request.backgroundPolicy
                                               andMapping:request.objectMapping
                                                    block:resultContext.block];
    
}

-(NSString *)explanation
{
    return BBAppDelegate.sharedDelegate.isNetworkReachable ? @"Network is disconnected" : @"Error while contacting server";
}

-(HTTPStatusCode) statusCode {
    return _bberror.statusCode;
}
-(NSString *)message {
    return _bberror.message;
}
-(NSString *)type {
    if (![BBAppDelegate.sharedDelegate isNetworkReachable]) {
        return @"NetworkUnreachable";
    }
    else if (![BBAppDelegate.sharedDelegate isNetworkReachable]) {
        return @"ServerUnreachable";
    }
    else
    return _bberror.type;
}


-(NSString *)description {
    NSString *errorDescription = [NSString stringWithFormat:@"%@%@",[super description],_bberror ? [NSString stringWithFormat:@"; %@",_bberror] : @""];
    return errorDescription;

}
@end

NSString* const BBNetworkErrorDomain = @"com.blipboard.network-error";
NSDate *HTTPDateToNSDate(NSString *string) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate *date = [dateFormatter dateFromString:string];
    return date;
}
NSNumber *timeIntervalFromHTTPRetryAfterData(NSString *string) {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *interval = [nf numberFromString:string];
    if (interval) {
        return interval;
    }
    else {
        NSDate* date = HTTPDateToNSDate(string);
        if (date) {
            return [NSNumber numberWithFloat:[date timeIntervalSinceDate:[NSDate date]]];
        }
    }
    return nil;
}


#pragma mark RKRequest helper category

@implementation RKRequest (MethodName)

-(NSString *)methodName {
    return RKRequestMethodNameFromType([self method]);
}

@end
