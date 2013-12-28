//
//  ServerModelError.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cancellation.h"


extern NSString* const BBNetworkErrorDomain;
typedef enum {
    BBNetworkErrorTypeUnexpectedResponse = 1
} BBNetworkErrorType;

typedef enum {
    HTTPStatusCodeContinue=100,
    HTTPStatusCodeSwitchingProtocols=101,
    HTTPStatusCodeProcessing=102,
    HTTPStatusCodeOK=200,
    HTTPStatusCodeCreated=201,
    HTTPStatusCodeAccepted=202,
    HTTPStatusCodeNonAuthoritativeInformation=203,
    HTTPStatusCodeNoContent=204,
    HTTPStatusCodeResetContent=205,
    HTTPStatusCodePartialContent=206,
    HTTPStatusCodeMultiStatus=207,
    HTTPStatusCodeAlreadyReported=208,
    HTTPStatusCodeIMUsed=209,
    HTTPStatusCodeCallBackLater=210,
    HTTPStatusCodeMultipleChoices=300,
    HTTPStatusCodeMovedPermanently=301,
    HTTPStatusCodeFound=302,
    HTTPStatusCodeSeeOther=303,
    HTTPStatusCodeNotModified=304,
    HTTPStatusCodeUseProxy=305,
    HTTPStatusCodeSwitchProxy=306,
    HTTPStatusCodeTemporaryRedirect=307,
    HTTPStatusCodePermanentRedirect=308,
    HTTPStatusCodeBadRequest=400,
    HTTPStatusCodeUnauthorized=401,
    HTTPStatusCodePaymentRequired=402,
    HTTPStatusCodeForbidden=403,
    HTTPStatusCodeNotFound=404,
    HTTPStatusCodeMethodNotAllowed=405,
    HTTPStatusCodeNotAcceptable=406,
    HTTPStatusCodeProxyAuthenticationRequired=407,
    HTTPStatusCodeRequestTimeout=408,
    HTTPStatusCodeConflict=409,
    HTTPStatusCodeGone=410,
    HTTPStatusCodeLengthRequired=411,
    HTTPStatusCodePreconditionFailed=412,
    HTTPStatusCodeRequestEntityTooLarge=413,
    HTTPStatusCodeRequestURITooLong=414,
    HTTPStatusCodeUnsupportedMediaType=415,
    HTTPStatusCodeRequestedRangeNotSatisfiable=416,
    HTTPStatusCodeExpectationFailed=417,
    HTTPStatusCodeImATeapot=418,
    HTTPStatusCodeEnhanceYourCalm=420,
    HTTPStatusCodeUnprocessableEntity=422,
    HTTPStatusCodeLocked=423,
    HTTPStatusCodeFailedDependency=424,
    HTTPStatusCodeUnorderedCollection=425,
    HTTPStatusCodeUpgradeRequired=426,
    HTTPStatusCodePreconditionRequired=427,
    HTTPStatusCodeTooManyRequests=429,
    HTTPStatusCodeRequestHeaderFieldsTooLarge=431,
    HTTPStatusCodeNoResponse=444,
    HTTPStatusCodeRetryWith=449,
    HTTPStatusCodeBlockedbyWindowsParentalControls=450,
    HTTPStatusCodeUnavailableForLegalReasons=451,
    HTTPStatusCodeRequestHeaderTooLarge=494,
    HTTPStatusCodeCertError=495,
    HTTPStatusCodeNoCert=496,
    HTTPStatusCodeHTTPtoHTTPS=497,
    HTTPStatusCodeClientClosedRequest=499,
    HTTPStatusCodeInternalServerError=500,
    HTTPStatusCodeNotImplemented=501,
    HTTPStatusCodeBadGateway=502,
    HTTPStatusCodeServiceUnavailable=503,
    HTTPStatusCodeGatewayTimeout=504,
    HTTPStatusCodeHTTPVersionNotSupported=505,
    HTTPStatusCodeVariantAlsoNegotiates=506,
    HTTPStatusCodeInsufficientStorage=507,
    HTTPStatusCodeLoopDetected=508,
    HTTPStatusCodeBandwidthLimitExceeded=509,
    HTTPStatusCodeNotExtended=510,
    HTTPStatusCodeNetworkAuthenticationRequired=511,
    HTTPStatusCodeNetworkReadTimeoutError=598,
    HTTPStatusCodeNetworkConnectTimeoutError=599
} HTTPStatusCode;

@class ServerModel;
@class ServerModelError;
typedef void (^ServerModelBlock)(ServerModel *model, NSDictionary *result,ServerModelError *error);

/** Encapsulates errors returned by ServerModel requests */
@interface ServerModelError : NSError <UIAlertViewDelegate>

+(id)errorWithDomain:(NSString *)domain code:(NSInteger)code request:(RKRequest *)request;
+(id)errorWithNSError:(NSError *)error andRequest:(RKRequest *)request;

-(NSTimeInterval)retryAfterHeader;
/// returns a time in seconds, or -1 if no retryAfterHeader is provided

-(id<CancellableOperation>)retry;
-(BOOL)retryable;
//-(void) retryAlert;
//-(void) retryAlert:(Cancellation *)cancellation;
-(BOOL)retryAfter:(NSTimeInterval)timeInterval withCancellation:(Cancellation *)cancellation;
-(NSString*)explanation;

-(HTTPStatusCode) statusCode;
-(NSString*) message;
-(NSString*) type; 
@end


@interface RKRequest (MethodName) 
-(NSString *)methodName;
@end
