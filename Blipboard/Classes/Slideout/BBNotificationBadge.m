//
//  NotificationBadge.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/24/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBNotificationBadge.h"

@implementation BBNotificationBadge
@dynamic badgeCount;

+(BBNotificationBadge *)badge {
    BBNotificationBadge *badge = [[BBNotificationBadge alloc] initWithFrame:CGRectMake(55, 12, 0,0)];
    badge.tintColor = [UIColor bbOrange];
    badge.textColor = [UIColor bbPaperWhite];
    badge.borderColor = [UIColor bbWhite];
    badge.borderWidth = 2.0f;
    badge.backgroundColor = [UIColor clearColor];
    badge.font = [UIFont bbCondensedBoldFont:12];
    badge.userInteractionEnabled = NO;
    badge.autoUpdate = YES;
    badge.text = @([BBRemoteNotificationManager sharedManager].notificationStream.newNotificationsCount).stringValue;
    
    BBLogLevel(4,@"observing BBRemoteNotificationManagerDidUpdateStream");
    [[NSNotificationCenter defaultCenter] addObserver:badge
                                             selector:@selector(didUpdateNotificationStream:)
                                                 name:BBRemoteNotificationManagerDidUpdateStream
                                               object:nil];
    
    return badge;
}

-(void)setBadgeCount:(NSInteger)count {
    self.text = @(count).stringValue;
}

-(NSInteger)badgeCount {
    return [self.text integerValue];
}

-(void)setText:(NSString *)text {
    CGPoint center = self.center;
    [super setText:text];
    [self sizeToFit];
    self.center = center;
}

-(void)hideByShrinking {
    BBTraceLevel(4);
    if (!self.hidden) {
        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:.25 animations:^{
            self.transform = CGAffineTransformMakeScale(.01, .01);
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

-(void)showByExpanding:(NSString *)badgeText {
    BBTraceLevel(4);
    if (self.hidden) {
        [self setText:badgeText];
        self.transform = CGAffineTransformMakeScale(.01, .01);
        self.hidden = NO;
        [UIView animateWithDuration:.25 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

// badge flips forward about the Z axis like the elements of
// a mechanical schedule board at a train station
-(void)changeTextAnimation:(NSString *)badgeText {

    if (![self.text isEqualToString:badgeText]) {
        self.layer.zPosition = self.superview.layer.zPosition + 100; // ensure that layer ends up in front of parent layer
        [CATransaction begin];
        // rotate top of badge forward to hide it at 90 degrees
        CAAnimation *hideAnimation = [self zRotationAnimationFrom:0 to:90 duration:.25 beginTime:0];
        [hideAnimation setCompletion:^(BOOL finished) {
            [self setText:badgeText];
            [self.layer addAnimation:[self zRotationAnimationFrom:-90 to:0 duration:.25 beginTime:.25] forKey:@"appear"];
        }];
        [self.layer addAnimation:hideAnimation forKey:@"hideShow"];
        [CATransaction commit];
        // rotate the top of the badge from -90 to give the impression we're rotating
        // up the back of the badge
//        CAAnimationGroup *group = [CAAnimationGroup animation];
//        group.animations = @[hideAnimation,showAnimation];
//        group.duration = hideAnimation.duration + showAnimation.duration;
//        group.removedOnCompletion = NO;
//        [self.layer addAnimation:group forKey:@"changeText"];
    }
}

-(CAAnimation *)zRotationAnimationFrom:(CGFloat)fromDegrees to:(CGFloat)toDegrees duration:(CFTimeInterval)duration beginTime:(CFTimeInterval)begin {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    NSValue *from = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(degreesToRadians(fromDegrees), 1.0, 0, 0)];
    NSValue *to =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(degreesToRadians(toDegrees),1.0, 0, 0)];
    animation.fromValue = from;
    animation.toValue = to;
    animation.duration = .25;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

-(void)dealloc {
    BBLogLevel(4,@"unobserving BBRemoteNotificationManagerDidUpdateStream");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark NSNotificationCenter observers
-(void)didUpdateNotificationStream:(NSNotification *)notification {
    BBTrace();
    if (self.autoUpdate) {
        NotificationStream *stream = notification.userInfo[BBRemoteNotificationManagerStream];
        NSInteger newBadgeNumber = stream.newNotificationsCount;
        
        // if number is 0, shrink the badge away:
        if (newBadgeNumber==0) {
            [self hideByShrinking];
        }
        else {
            NSString *badgeText = @(newBadgeNumber).stringValue;
            
            if (self.hidden) { // appear for first time or reappear
                [self showByExpanding:badgeText];
            }
            else {
                [self changeTextAnimation:badgeText];
            }
        }
    }
}

@end
