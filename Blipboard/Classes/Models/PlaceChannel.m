//
//  PlaceChannel.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/20/12.
//  Copyright (c) 2012 Blipboard, Inc. All rights reserved.
//

#import "Flurry+Blipboard.h"
#import "BBAppDelegate.h"
#import "BBApplication.h"
#import "PlaceChannel.h"
#import "Location.h"
#import "Blip.h"
#import "BBLog.h"

@implementation PlaceChannel

-(id<CancellableOperation>)broadcastHere:(NSString*)message topic:(Topic *)topic expiry:(NSDate*)expiry block:(void (^)(Blip *blip, ServerModelError *error))block
{ 
    BBTrace();
    __block void (^_block)(Blip *blip, ServerModelError *error) = block;
    NSString* path = [NSString stringWithFormat:@"/%@/blips", BBAppDelegate.sharedDelegate.myAccount.id];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithKeysAndObjects:
                                   @"authorid", [BBAppDelegate sharedDelegate].myAccount.id, 
                                   @"placeid", self.id,
                                   @"message", message,
                                   nil];
    
    if (topic) {
        params[@"topicids"] = @[topic.id];
    }
    
    [Flurry logEvent:kFlurryAPIPlaceBroadcast timed:YES];
    if (expiry) {
        [params setValue:expiry forKey:@"expiry"];
    }
    
    return [self
            loadObjectsAtResourcePath:path
            withMethod:RKRequestMethodPOST
            andParams:params
            block:^(ServerModel *model, NSDictionary *results, ServerModelError *error) {
                [Flurry endTimedEvent:kFlurryAPIPlaceBroadcast
                   withErrorAndParams:error,
                 @"placeid",self.id,
                 @"authorid", [BBAppDelegate sharedDelegate].myAccount.id,
                 @"topic", topic ? topic.name : @"",
                 @"messagelen", [NSString stringWithFormat:@"%d", message.length],
                 nil];
                Blip *blip = [results objectForKey:@"blip"];
                if (!error) {
                    [blip.author changeServerInstancesUsingKeyValues:@{@"stats":blip.author.stats}];
                    [blip.place changeServerInstancesUsingKeyValues:@{@"stats":blip.place.stats}];
                    [BBAppDelegate.sharedDelegate.myAccount incrementTotalBlips];
                }
                _block(blip,error);
            }];
}

-(id<CancellableOperation>) markMyReceivedBlipsRead:(void (^)(ServerModelError *error))block {
    BBTrace();
    [Flurry logEvent:kFlurryAPIMarkBlipsAtPlaceRead timed:YES];
    
    NSString *path = [NSString stringWithFormat:@"/channels/%@/received/place/%@/mark-read",BBAppDelegate.sharedDelegate.myAccount.id, self.id];
    __block void (^_block)(ServerModelError *) = block;
    return [self loadObjectsAtResourcePath:path
                                withMethod:RKRequestMethodPOST
                                 andParams:nil
                                     block:^(ServerModel *model, NSDictionary *result, ServerModelError *error) {
                                         [Flurry endTimedEvent:kFlurryAPIMarkBlipsAtPlaceRead
                                                     withErrorAndParams:error,
                                          @"place", self.id,
                                          nil];
                                         _block(error);
                                     }];
}

-(BOOL)hasDirections {
    return self.location && self.location.coreLocation;
}

-(BOOL)hasWebsite {
    return self.website && self.website.length>0;
}

-(void) showWebsite {
    NSString *fullURLString = ([self.website hasPrefix:@"http"]) ? self.website : [NSString stringWithFormat:@"http://%@",self.website];
    NSURL *url = [NSURL URLWithString:fullURLString];

    [[BBApplication sharedApplication] openURL:url];
}
-(BOOL)canCallPhone {
    return [[BBApplication sharedApplication] canOpenURL:self.phoneURL];
}

-(void) callPhone
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] && self.phoneURL) {
        BBLog(@"Call %@", self.phone);
        [[BBApplication sharedApplication] openURL:self.phoneURL forceOpenInSafari:YES];
    }
}

-(NSURL *)phoneURL {
    if (_phone && _phone.length) {
        NSCharacterSet *spaces = [NSCharacterSet whitespaceCharacterSet];

        NSString *fixPhone = [[[[[[[_phone stringByTrimmingCharactersInSet:spaces]
                                   stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                  stringByReplacingOccurrencesOfString:@")" withString:@""]
                                 stringByReplacingOccurrencesOfString:@" " withString:@""]
                                stringByReplacingOccurrencesOfString:@"-" withString:@""]
                               stringByReplacingOccurrencesOfString:@"." withString:@""]
                              stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"tel://%@", fixPhone];
        
        return [NSURL URLWithString:urlString];
    }
    return nil;
    
}

-(void) showDirections
{
    BBLog(@"Show directions %@", self.phone);

    CLLocation* current = BBAppDelegate.sharedDelegate.myLocation;
    NSString * mapUrl = SYSTEM_VERSION_LESS_THAN(@"6.0") ? @"http://maps.google.com/maps" : @"http://maps.apple.com/maps";
    NSString* lookup = [NSString stringWithFormat:@"%@?saddr=%f,%f&daddr=%@,%@",
                        mapUrl,
                        current.coordinate.latitude, current.coordinate.longitude,
                        self.location.latitude,self.location.longitude];

    [[BBApplication sharedApplication] openURL:[NSURL URLWithString:lookup] forceOpenInSafari:YES];
}

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [Channel mapping];
    mapping.objectClass = [PlaceChannel class];

    [mapping mapKeyPathsToAttributes:
     @"category",       @"category",
     @"categoryId",     @"categoryId",
     @"website",        @"website",
     @"phone",          @"phone",
     @"facebook.id",    @"facebookId",
     nil];
    [mapping mapKeyPath:@"location" toRelationship:@"location" withMapping:Location.mapping];
    [mapping mapKeyPath:@"defaultTopic" toRelationship:@"defaultTopic" withMapping:Topic.mapping];
    return mapping;
}

+(NSString*)type
{
    return @"place";
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ [PlaceChannel: topic=%@ loc=%@]",
            [super description],
            self.defaultTopic.name,
            self.location];
}

#pragma mark -
#pragma mark MKMapAnnotation implementation
-(CLLocationCoordinate2D)coordinate {
    return self.location.coreLocation.coordinate;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    assert(false);
}

-(NSString *)title {
    return self.name;
}

-(NSString *)subtitle {
    return nil;
}


@end
