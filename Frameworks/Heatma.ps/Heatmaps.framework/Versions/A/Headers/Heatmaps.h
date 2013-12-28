//
//  Heatmaps.h
//  Heatmaps
//
//  Created by Kamil Szwaba on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Heatmaps : NSObject

// Show debugger messages in the console.
// The default is NO.
@property(nonatomic,readwrite)BOOL showDebug;

// Show "Take a screen shot button" on all elements that you track.
// The default is NO.
@property(nonatomic,readwrite)BOOL showScreenshotButtons;

// Disable data upload over WWAN (Edge, 3G, 4G). By default
// all interaction data is send over WiFi and WWAN.
// The default is NO.
@property(nonatomic,readwrite)BOOL disableWWAN;

+(Heatmaps*)instance;
-(void)start;

+(void)track:(UIView*)element withKey:(NSString*)key;
+(void)trackNavigationBarInNavigationController:(UINavigationController *)navigationController withKey:(NSString *)key;

+(void)stopTrackingElementWithKey:(NSString*)key;
+(void)stopTrackingNavigationBarWithKey:(NSString*)key;

+(void)createABTestWithKey:(NSString *)key variantsNames:(NSArray*)variants andVariantsBlocks:(void (^)(void))firstBlock, ... NS_REQUIRES_NIL_TERMINATION;
+(void)goalReachedForTestWithKey:(NSString*)key;

@end
