//
//  BlipPin.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/26/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <stdlib.h> // for arcrandom

#import "BlipPin.h"
#import "Blip.h"
#import "BBTuneInButton.h"
#import "BBImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"


// BlipPins always use this reuseIdentifier:
static NSString *BlipPinReuseIdentifier = @"BlipPin";
const CGPoint CalloutLeftNippleOffset = { .x = 5, .y = 45 };
const CGPoint CalloutRightNippleOffset = { .x = 40, .y = 45 };
const CGPoint CalloutCenterNippleOffset = { .x = 20, .y = 47 };
@implementation BlipPin {
    BlipPinState _state;
    __strong ASIHTTPRequest *_request;
    __strong NSURL *_url;
}
@dynamic state;

/**
 * The only reuse identifier that any BlipPin will have
 */
+ (NSString *)reuseIdentifier {
    return BlipPinReuseIdentifier;
}

- (id)init {
    self = [super initWithAnnotation:nil reuseIdentifier:[BlipPin reuseIdentifier]];
    self.canShowCallout = FALSE;
    return self;
}

/** Configures the blip, assuming that blip.author.pictureImage and blip.displayTopic.pictureImage
 *  have been loaded
 *
 * @param blip the blip which the pin should represent
 * @param state a BlipPinState
 */
- (void)_configureWithBlip:(Blip *)blip state:(BlipPinState)state {
    self.annotation = blip;
    self.state = state;
    [self _setPinImage];
    
    NSString* imageUrl = blip.author.picture;
    [self.picture setImageWithURLString:imageUrl placeholderImage:nil];
    self.blipMessageLabel.text = blip.message;
    if (blip.author.type==ChannelTypeUser) {
        self.authorNameLabel.text = [NSString stringWithFormat:@"%@ @ %@", blip.author.name, blip.place.name];
    }
    else {
        self.authorNameLabel.text = blip.author.name;
    }
}

/** Ensures the blip images are loaded, optionally animating the pin 
 *
 */
-(void)configureWithBlip:(Blip *)blip state:(BlipPinState)state animate:(BOOL)animate delay:(NSTimeInterval)delay {
    if (!blip.author.pictureImage || !blip.displayTopic.pictureImage) {
        __block NSArray *args = @[@(state),@(delay),@(animate)];
        BlipPin *Self = self;
        [blip loadPictureForAuthor:YES place:NO topic:YES completion:^(UIImage *authorPicture, UIImage *placePicture, UIImage *topicPicture) {
            
            [Self performSelectorOnMainThread:@selector(_loadComplete:)
                                   withObject:args
                                waitUntilDone:NO];
        }];
    }
    else {
        [self _configureWithBlip:blip state:state];
        if (animate) {
            [self appearAnimationWithDelay:delay completion:^(BlipPin *blipPin) {}];
        }
    }
}

-(void)_loadComplete:(NSArray *)args {
    Blip *blip = self.blip;
    BlipPinState state = [(NSNumber *)args[0] integerValue];
    CGFloat delay = [(NSNumber *)args[1] floatValue];
    BOOL animate =[(NSNumber *)args[1] boolValue];

    [self _configureWithBlip:blip state:state];
    if (animate) {
        [self appearAnimationWithDelay:delay completion:^(BlipPin *blipPin) {}];
    }
}

- (void)prepareForReuse {
    self.blip.view = nil;
    self.image = nil;
}

- (Blip *)blip {
    return (Blip *)self.annotation;
}

- (BlipPinState)state {
    return _state;
}

- (void)setState:(BlipPinState)state {
    _state = state;
    switch (state) {
        case BlipPinStateBackground:
            self.alpha = .4;
            break;
        
        case BlipPinStateForeground:
            self.alpha = 1;
            break;
            
        case BlipPinStateDefault:
            self.alpha = 1;
            break;

        default:
            assert(false);
    }
    [self redraw];
}

-(void)redraw
{
    [self _setPinImage];
}

-(UIImage *)framedAuthorImage {
    return [self _authorFrame];
}

-(UIImage *)calloutImage {
    return [self _calloutImage];
}

#pragma mark -
#pragma mark KVO stuff
-(void)setAnnotation:(id<MKAnnotation>)annotation {
    assert(!annotation || [annotation isKindOfClass:[Blip class]]);
    if (self.annotation) {
        Blip *blip = (Blip *)self.annotation;
        [blip removePropertiesObserver:self];
    }
    [super setAnnotation:annotation];
    if (annotation) {
        Blip *blip = (Blip *)annotation;
        [blip addPropertiesObserver:self];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object==self.blip.author || object==self.blip ) {
        if ([keyPath isEqualToString:@"_isListening"]) {
            NSNumber *oldValue = change[NSKeyValueChangeOldKey];
            NSNumber *newValue = change[NSKeyValueChangeNewKey];
            if (![oldValue isEqualToNumber:newValue]) {
                [self tuneInChangedAnimation:^(BlipPin *pin) {}];
            }
        }
        else {
            [self _configureWithBlip:self.blip state:self.state];
        }
    }
}

-(void)dealloc {
    self.annotation = nil; // remove property observers
}
#pragma mark -
#pragma mark Animations
-(void)appearAnimationWithDelay:(NSTimeInterval)delay completion:(void (^)(BlipPin *))completion {
    [self _appearAnimationWithDuration:1. delay:delay completion:completion];
}

-(void)disappearAnimationWithDelay:(NSTimeInterval)delay completion:(void (^)(BlipPin *))completion {
    [self _disappearAnimationWithDuration:.5 delay:delay completion:completion];
}

-(void)_appearAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BlipPin *))completion {
    assert([NSThread currentThread]==[NSThread mainThread]);
    
//    self.layer.transform = [self _shrinkGrowCATransform3D:.01];
//    [UIView animateWithDuration:((CGFloat)duration)*1./3.
//                          delay:delay
//                        options:UIViewAnimationCurveEaseIn
//                     animations:^{
//                         self.layer.transform = [self _shrinkGrowCATransform3D:1.1];
//                     } completion:^(BOOL finished) {


    CABasicAnimation *appearAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    appearAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    appearAnimation.fromValue = [self _shrinkGrowCATransform3DValue:.01];
    appearAnimation.toValue = [self _shrinkGrowCATransform3DValue:1.1];
    appearAnimation.beginTime = delay;
    appearAnimation.duration = ((CGFloat)duration)*1./3.;
    appearAnimation.removedOnCompletion = NO;
    appearAnimation.fillMode = kCAFillModeBoth;
    [appearAnimation setCompletion:^(BOOL finished) {
        self.layer.transform = [self _shrinkGrowCATransform3D:1.1];
    }];

    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [self _shrinkGrowCATransform3DValue:1.1],
                              [self _shrinkGrowCATransform3DValue:.91],
                              [self _shrinkGrowCATransform3DValue:1.05],
                              [self _shrinkGrowCATransform3DValue:.96],
                              [self _shrinkGrowCATransform3DValue:1.0],
                              nil];
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    bounceAnimation.beginTime = appearAnimation.beginTime + appearAnimation.duration;
    bounceAnimation.duration = duration*2./3.;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;
    if (completion) {
        [bounceAnimation setCompletion:^(BOOL finished) {
            completion(self);
        }];
    }
    //[self.layer addAnimation:bounceAnimation forKey:@"bounce"];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = bounceAnimation.beginTime + bounceAnimation.duration;
    group.animations = @[appearAnimation,bounceAnimation];
    [group setCompletion:^(BOOL finished) {
        self.layer.transform = CATransform3DIdentity;
        [self.layer removeAllAnimations];
    }];
    [self.layer addAnimation:group forKey:@"appear"];
}

-(void)_disappearAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BlipPin *))completion {
    CABasicAnimation *disappearAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
//    [self.layer setValue:[NSValue valueWithCATransform3D:[self _shrinkGrowCATransform3D:.01]]
//                  forKey:@"transform"];
    
    [disappearAnimation setBeginTime:CACurrentMediaTime() + delay];
    
    [disappearAnimation setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [disappearAnimation setToValue:[NSValue valueWithCATransform3D:[self _shrinkGrowCATransform3D:.01]]];
    [disappearAnimation setDuration:duration];
    [disappearAnimation setRemovedOnCompletion:NO];
    [disappearAnimation setFillMode:kCAFillModeForwards];
    [disappearAnimation setCompletion:^(BOOL finished) {
//        [self.layer setValue:[NSValue valueWithCATransform3D:[self _shrinkGrowCATransform3D:.01]]
//                      forKey:@"transform"];
        
        if (completion) {
            self.layer.transform = [self _shrinkGrowCATransform3D:.01];
            [self.layer removeAnimationForKey:@"disappear"];
            completion(self);
        }
    }];
    [self.layer addAnimation:disappearAnimation forKey:@"disappear"];
    
}

-(CGAffineTransform)_shrinkGrowCGAffineTransform:(CGFloat)scale {
    // a transform that shrinks vertically to the bottom of the image, but horizontally to the middle
    return CGAffineTransformConcat(CGAffineTransformMakeScale(scale, scale),
                                   CGAffineTransformMakeTranslation(0, self.image.size.height/(2.-scale)));
}

-(CATransform3D)_shrinkGrowCATransform3D:(CGFloat)scale {
    CGFloat height = self.image.size.height;
    return CATransform3DConcat(CATransform3DMakeScale(scale, scale, 1.0),
                               CATransform3DMakeTranslation(0,height - height/(2.0-scale),0));
}

-(NSValue *)_shrinkGrowCATransform3DValue:(CGFloat)scale {
    // a transform that shrinks vertically to the bottom of the image, but horizontally to the middle
    CATransform3D t = [self _shrinkGrowCATransform3D:scale];
    return [NSValue valueWithCATransform3D:t];
}

-(void)tuneInChangedAnimation:(void (^)(BlipPin *pin))completion {
    
    BBTraceLevel(4);
    [self _disappearAnimationWithDuration:.5 delay:0 completion:^(BlipPin *blipPin) {
        [blipPin configureWithBlip:blipPin.blip state:BlipPinStateDefault animate:YES delay:0];
    }];
}

-(BOOL)shouldShowAuthorInPin {
    return self.blip.place.isListening || self.blip.author.isListening ||
            [self.blip.author.id isEqualToString:BBAppDelegate.sharedDelegate.myAccount.id];
}

-(void)_setPinImage {
    self.designDescription = @"";
    Channel *author = self.blip.author;
    BOOL shouldShowAuthorImage = author.isListening || [BBAppDelegate.sharedDelegate.myAccount.id isEqualToString:author.id];

    [self _selectOrientation];
    
    UIImage *calloutImage = [self _calloutImage];
    UIImage *pinImage;
    if (shouldShowAuthorImage && author.pictureImage) {
        pinImage = [self _authorFrameWithCallout:calloutImage orientation:self.orientation];
    }
    else {
        pinImage = [self _anonymousIconWithCallout:calloutImage orientation:self.orientation];
    }
    
    
    // add * to indicate Unread
    if (self.blip.isRead && !self.selected) {
        pinImage = [pinImage saturatedImage:.35 brightness:1.5];
        assert(pinImage);
    }
    
    self.image = pinImage;
    
}

-(UIImage *)_anonymousIconWithCallout:(UIImage *)callout orientation:(BlipPinCalloutPointOrientation)orientation {
    NSString *iconName = self.blip.author.type==ChannelTypeUser ? @"blipper_person.png" : @"blipper_place.png";
    UIImage *icon = [UIImage imageNamed:iconName];
    
    self.designDescription = [NSString stringWithFormat:@"%@; %@", iconName,self.designDescription];
    
    CGPoint origin;

    switch (orientation) {
        case BlipPinCalloutPointOrientationCenter:
            origin = CGPointMake((icon.size.width-callout.size.width)/2, 7-callout.size.height);
            break;
            
        case BlipPinCalloutPointOrientationLeft:
            origin = CGPointMake(callout.size.width/2-icon.size.width/2, 20-callout.size.height);
            break;
            
        case BlipPinCalloutPointOrientationRight:
            origin = CGPointMake(icon.size.width/2-callout.size.width, 20-callout.size.height);
            break;
    }
    UIImage *result = [icon overlayWith:callout at:origin];
    
    [self _setPinOffset:result baseImage:icon orientation:orientation];
    
    return result;
}

-(UIImage *)_authorFrame {
    UIImage *frame = [UIImage imageNamed:@"blipper_frame.png"];
    UIImage *author = self.blip.author.pictureImage;
    CGFloat heightMargin = (author.size.height - author.size.width)/2.0;
    UIImage *authorCropped;
    
    if (heightMargin>0) {
        authorCropped = [author croppedImage:CGRectMake(0, heightMargin,
                                                        author.size.width, author.size.height-heightMargin*2.0) ];
    }
    else if (heightMargin<0) {
        CGFloat widthMargin = -heightMargin;
        authorCropped = [author croppedImage:CGRectMake(widthMargin, 0,
                                                        author.size.width-widthMargin*2.0, author.size.height)];
    }
    else {
        authorCropped = author;
    }
    
    // handle non-square images by doing an aspect fill:
    // 
    UIImage *framedAuthor = [frame resize:CGRectMake(0, 0, frame.size.width, frame.size.height)
                           andOverlayWith:authorCropped
                                       at:CGRectMake(2, 2, frame.size.width-4, frame.size.width-4)];
    return framedAuthor;
}

-(UIImage *)_authorFrameWithCallout:(UIImage *)callout orientation:(BlipPinCalloutPointOrientation)orientation {
    UIImage *framedAuthor = [self _authorFrame];
    self.designDescription = [NSString stringWithFormat:@"blipper_frame; %@",self.designDescription];
    CGPoint origin;
    switch (orientation) {
        case BlipPinCalloutPointOrientationCenter:
            origin = CGPointMake((framedAuthor.size.width-callout.size.width)/2, 10-callout.size.height);
            break;
            
        case BlipPinCalloutPointOrientationLeft:
            origin = CGPointMake(callout.size.width-framedAuthor.size.width, framedAuthor.size.height/3-(callout.size.height*3/4));
            break;
            
        case BlipPinCalloutPointOrientationRight:
            origin = CGPointMake(framedAuthor.size.width/2-callout.size.width, framedAuthor.size.height/3-(callout.size.height*3/4));
            break;
    }
    
    UIImage *result = [framedAuthor overlayWith:callout at:origin];

    [self _setPinOffset:result baseImage:framedAuthor orientation:orientation];
    
    return result;
}

-(void)_setPinOffset:(UIImage *)pinImage baseImage:(UIImage *)baseImage orientation:(BlipPinCalloutPointOrientation)orientation {
    self.centerOffset = CGPointZero;
    // calculate the offset of the pin from the center
    switch (orientation) {
        case BlipPinCalloutPointOrientationCenter:
            self.centerOffset = CGPointMake(pinImage.size.width/2, -pinImage.size.height/2);
            break;

        case BlipPinCalloutPointOrientationLeft:
            self.centerOffset = CGPointMake((pinImage.size.width - baseImage.size.width)/2, -pinImage.size.height/2);
            break;

        case BlipPinCalloutPointOrientationRight:
            self.centerOffset = CGPointMake(-(pinImage.size.width - baseImage.size.width)/2, -pinImage.size.height/2);
            break;
    }
}

-(void)_selectOrientation {
    // Pin orientation:
    BOOL isUser = (self.blip.author.type==ChannelTypeUser);
    unichar idLastChar = [self.blip.id characterAtIndex:self.blip.id.length-1];
    if (isUser) {
        if (idLastChar & 1) {
            self.orientation = BlipPinCalloutPointOrientationLeft;
        }
        else {
            self.orientation = BlipPinCalloutPointOrientationRight;
        }
    }
    else {
        _orientation = BlipPinCalloutPointOrientationCenter;
    }
}

-(UIImage *)_calloutImage {
    Blip *blip = self.blip;
    const NSArray *CalloutOrientations = @[@"left",@"right",@"center"];
    
    NSString *orientation = CalloutOrientations[self.orientation];
    
    // Timeliness
    BOOL isTimely = blip.effectiveTime && blip.effectiveTime.timeIntervalSinceNow>0;
    NSString *color = isTimely ? @"blue" : @"orange";
    
    
    // Selected state
    NSString *selectedness = _state==BlipPinStateForeground ? @"_selected" : @"";
    
    // Get the pin asset
    NSString *calloutAssetName = [NSString stringWithFormat:@"icn_blip_%@_%@%@.png",orientation,color,selectedness];
    self.designDescription = [NSString stringWithFormat:@"%@; %@",calloutAssetName, self.designDescription];
    
    UIImage *callout = [UIImage imageNamed:calloutAssetName];
    
    // add the category
    UIImage* topicImage = blip.topics.count ? [(Topic *)blip.topics[0] pictureImage] : nil;
    CGPoint origin = CGPointMake((callout.size.width - topicImage.size.width)/2,
                                 (callout.size.height - topicImage.size.height)/2-5);// - 3);
    callout = [callout overlayWith:topicImage at:origin];
    
    return callout;
}

//-(UIImage *)_calloutImage {
//    Blip *blip = self.blip;
//    const NSArray *CalloutOrientations = @[@"left",@"right",@"center"];
//
//    NSString *orientation = CalloutOrientations[self.orientation];
//    
//    // Timeliness
//    BOOL isTimely = blip.effectiveTime && blip.effectiveTime.timeIntervalSinceNow>0;
//    NSString *color = isTimely ? @"blue" : @"orange";
//    
//    
//    // Selected state
//    NSString *selectedness = _state==BlipPinStateForeground ? @"_selected" : @"";
//    
//    // Get the pin asset
//    NSString *calloutAssetName = [NSString stringWithFormat:@"icn_blip_%@_%@%@.png",orientation,color,selectedness];
//    self.designDescription = [NSString stringWithFormat:@"%@; %@",calloutAssetName, self.designDescription];
//
//    UIImage *callout = [UIImage imageNamed:calloutAssetName];
//
//    // add the category
//    UIImage* categoryImage = [BBPinCategory imageFromString:blip.place.category];
//    CGPoint origin = CGPointMake((callout.size.width - categoryImage.size.width)/2,
//                                 (callout.size.height - categoryImage.size.height)/2-5);// - 3);
//    callout = [callout overlayWith:categoryImage at:origin];
//    
//    // add * to indicate Unread
//    UIImage *unreadIcon = [UIImage imageNamed:@"icn_new.png"];
//    if (!blip.isRead) {
//        self.designDescription = [NSString stringWithFormat:@"%@; %@", unreadIcon,self.designDescription];
//        callout= [callout overlayWith:unreadIcon at:CGPointMake(0,3)];
//    }
//
//    return callout;
//}

@end
