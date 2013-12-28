//
//  BlipPin.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/26/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Blip.h"
#import "BBImageView.h"

typedef enum {
    BlipPinStateDefault,
    BlipPinStateForeground,
    BlipPinStateBackground,
} BlipPinState;

typedef enum {
    // !am! if you change this, you must change the static array below
    //      _selectOrientation
    BlipPinCalloutPointOrientationLeft =0,
    BlipPinCalloutPointOrientationRight =1,
    BlipPinCalloutPointOrientationCenter =2
} BlipPinCalloutPointOrientation;

/** An MKAnnotationView which represents a blip as a pin on a map
 */
@interface BlipPin : MKAnnotationView

@property (nonatomic, weak) IBOutlet UILabel *authorNameLabel; // using "Label" to identify these as UI elements
@property (nonatomic, weak) IBOutlet UILabel *blipMessageLabel; // to avoid confusion with e.g., .blip.author.name
@property (nonatomic, weak) IBOutlet BBImageView *picture;
@property (nonatomic, strong) NSString *designDescription; // a description of the pin assets
@property (nonatomic) BlipPinCalloutPointOrientation orientation;
@property (nonatomic) BlipPinState state;

-(UIImage *)framedAuthorImage;
-(UIImage *)calloutImage;
-(void)configureWithBlip:(Blip *)blip state:(BlipPinState)state animate:(BOOL)animate delay:(NSTimeInterval)delay;
-(void)tuneInChangedAnimation:(void (^)(BlipPin *pin))completion;
-(void)appearAnimationWithDelay:(NSTimeInterval)delay completion:(void (^)(BlipPin *blipPin))completion;
-(void)disappearAnimationWithDelay:(NSTimeInterval)delay completion:(void (^)(BlipPin *blipPin))completion;
-(void)redraw;
+(NSString *)reuseIdentifier;
-(Blip *)blip;

@end
