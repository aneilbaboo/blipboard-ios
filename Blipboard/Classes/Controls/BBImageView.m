//
//  BBImageView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu 1/30/12
//  Copyright 2011 Blipboard. All rights reserved.
//

#import "BBImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import <QuartzCore/QuartzCore.h>
#import "BBLog.h"
#import "UIImage+Resize.h"
#import "NSTimer+Blocks.h"

const CGFloat kBBImageViewInitialRetryInterval = .5;
const CGFloat kBBImageViewMaxRetryInterval = 33.0;
const CGFloat kBBImageViewBackoffFactor = 2.0;

@implementation BBImageView {
    __strong ASIHTTPRequest *_request;
    __strong NSURL *_url;
    NSTimeInterval _retryInterval;

}

+(void)load {
    [[ASIDownloadCache sharedCache] setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    [[ASIDownloadCache sharedCache] setShouldRespectCacheControlHeaders:NO];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _retryInterval = kBBImageViewInitialRetryInterval ;
    return [super initWithCoder:aDecoder];
}

- (id)initWithFrame:(CGRect)frame {
    _retryInterval = kBBImageViewInitialRetryInterval ;
    return [super initWithFrame:frame];
}

- (id)init {
    _retryInterval = kBBImageViewInitialRetryInterval ;
    return [super init];
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    _retryInterval = kBBImageViewInitialRetryInterval ;
    return [super initWithImage:image highlightedImage:highlightedImage];
}

- (id)initWithImage:(UIImage *)image  {
    _retryInterval = kBBImageViewInitialRetryInterval ;
    return [super initWithImage:image];
}
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    // if url is different than the current one
    //  or we haven't set the image yet...
    if (url && (![url isEqual:_url] || !self.image)) {
        self.image = nil;
        [self cancel];
        _url = url;
        assert(url);
        _request = [ASIHTTPRequest requestWithURL:url];
        _request.downloadCache = [ASIDownloadCache sharedCache];
        _request.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
        _request.secondsToCache = 0; //60*60*24*5; // cache for 5 days
        _request.shouldRedirect = YES;
        _request.delegate = self;
//        BBLog(@"setImage: %@", url)

        [_request startAsynchronous];
        [[UIApplication sharedApplication] pushNetworkActivity];
        
        if (placeholder)
            self.image = placeholder;
    }
    else {
//        BBLog(@"setImage (dup): %@", url)
    }
}

NSString const *BlipboardResourceURN = @"urn:blipboard:";

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder
{
    if ([[urlString lowercaseString] hasPrefix:(NSString *)BlipboardResourceURN]) {
        self.image = [UIImage imageNamed:[urlString substringFromIndex:BlipboardResourceURN.length]];
    }
    else {
        NSURL *url = urlString && urlString.length>0 ? [NSURL URLWithString:urlString] : nil;
        [self setImageWithURL:url placeholderImage:placeholder];
    }
}

- (void)cancel {
    if (_request) {
//        BBLog(@"cancel: %@ (%@)", _request.url, _request.requestID);
        [_request setDelegate:nil];
        [_request cancel];
        [[UIApplication sharedApplication] popNetworkActivity];
    }

}

- (void)dealloc {
    [self cancel];
    self.image = nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
//    BBLog(@"Failed retrieving image: %@ (%@)",request.url, request.requestID);
    self.image = nil;
    _url = nil;
    _retryInterval = kBBImageViewInitialRetryInterval;
    [[UIApplication sharedApplication] popNetworkActivity];
}

// we handle redirects in this code due to a bug in ASIHttpRequest
// ASI has a bug where it calls the requestFinished delegate if a
// second call for the same exact url is made while it is processing the redirect.
// The solution is to exponentially backoff when the redirect is received
// so that the next time it tries the original request should have completed.
- (void)requestFinished:(ASIHTTPRequest *)req {
    BBLogLevel(4, @"Loaded image: %@ (%@)",req.url, req.requestID);
    NSUInteger status = req.responseStatusCode;
    if (!req.didUseCachedResponse) {
        self.alpha = 0;
        
        [UIView animateWithDuration:.5 animations:^{
            self.alpha = 1;
        }];
    }
    _request = nil;

    if (status==200) {
        assert(req.responseData);
        self.image = [UIImage imageWithData:req.responseData];
        _retryInterval = kBBImageViewInitialRetryInterval;
    }

    // ASI has a bug that returns a 302 response from the cache if
    // a second call to url is made before the redirect is received.
    // This problem resolves as soon as the redirect response is received.
    // So - this is a work-around that retries (a limited # of times)
    // whenever
    if (status==302) {
        BBLog(@"cached redirect - retry in %f for %@",_retryInterval, req.requestID);
        if (_retryInterval<=kBBImageViewMaxRetryInterval) {
            _retryInterval *= kBBImageViewBackoffFactor;
            [self performSelector:@selector(_retry:)
                       withObject:_url
                       afterDelay:_retryInterval];
        }
    }
    [[UIApplication sharedApplication] popNetworkActivity];
}

-(void)_retry:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}
@end
