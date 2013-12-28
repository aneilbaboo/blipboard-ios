//
//  NotificationBar.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/26/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBNotificationBar.h"
#import "SlideoutViewController.h"

@implementation BBNotificationBar
@dynamic image;

+(id)notificationBar {
    BBNotificationBar *bar = [[[NSBundle mainBundle] loadNibNamed:@"BBNotificationBar" owner:nil options:nil]
            objectAtIndex:0];
    [bar _setupStyle];
    bar.defaultTimeout = 15;
    bar.autoUpdate = YES;
    [[NSNotificationCenter defaultCenter] addObserver:bar
                                             selector:@selector(didUpdateNotificationStream:)
                                                 name:BBRemoteNotificationManagerDidUpdateStream
                                               object:nil];
    return bar;
}

-(void)_setupStyle {
    self.backgroundColor = [UIColor bbNotificationBarColor];
    [self _ensureHidden];
    [self.title setFont:[UIFont bbBoldFont:12]];
    [self.title setTextColor:[UIColor bbWhite]];
    [self.subtitle setFont:[UIFont bbFont:12]];
    [self.subtitle setTextColor:[UIColor bbPaperWhite]];
    [self.imageViewBackground roundCorners:UIRectCornerAllCorners xRadius:3 yRadius:3];
    [self.imageViewBackground setBackgroundColor:[UIColor bbPaperWhite]];
    [self.imageView roundCorners:UIRectCornerAllCorners xRadius:3 yRadius:3];
    self.imageView.backgroundColor = [UIColor bbPaperWhite];
    [self addTarget:self action:@selector(barWasTapped:) forControlEvents:UIControlEventTouchDown];
}

-(UIImage *)image {
    return self.imageView.image;
}

-(void)setImage:(UIImage *)image {
    BOOL hidden = !image;
    self.imageViewBackground.hidden = hidden;
    self.imageView.hidden = hidden;
    
    self.imageView.image = image;
}

-(void)setImageWithURLString:(NSString *)urlString {
    BOOL hidden = !urlString;
    self.imageViewBackground.hidden = hidden;
    self.imageView.hidden = hidden;
    
    [self.imageView setImageWithURLString:urlString placeholderImage:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BBRemoteNotificationManagerDidUpdateStream
                                                  object:nil];
}

#pragma mark -
#pragma mark Methods
-(void)showNotification:(Notification *)notification {
    [self showNotification:notification timeout:self.defaultTimeout];
}

-(void)showNotification:(Notification *)notification timeout:(NSTimeInterval)timout {
    self.title.text = notification.title;
    self.subtitle.text = notification.subtitle;
    notification.isUnreadLocally = NO;
    if (notification.pictureImage) {
        self.image = notification.pictureImage;
    }
    else {
        [self setImageWithURLString:notification.picture];
    }
    [self setAction:^{
        SlideoutMenuViewController *mvc = [SlideoutViewController sharedController].menuViewController;
        [mvc showNotification:notification];
        notification.isNew = NO;
        notification.isUnreadLocally = NO;
        [[BBRemoteNotificationManager sharedManager] clearNewNotifications];
    }];
    [self show:timout];
}

-(void)show:(NSTimeInterval)timeout {
    static NSNumber *animated;
    if (!animated) { animated = @(YES); } // non-nil object pointer;
    
    if (self.hidden) {
        self.hidden = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(hide:)
                                                   object:animated];
        [UIView
         animateWithDuration:.5
         animations:^{
             self.alpha = 1;
             self.transform = CGAffineTransformIdentity;
         }
         completion:^(BOOL finished) {
             if (timeout>0) {
                 [self performSelector:@selector(hide:)
                            withObject:animated
                            afterDelay:timeout];
             }
         }];
    }
}

- (void)hide:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:.5 animations:^{
            self.alpha = 0;
            self.transform = CGAffineTransformMakeTranslation(0, -self.height);
        } completion:^(BOOL finished) {
            [self _ensureHidden];
        }];
    }
    else {
        [self _ensureHidden];
    }
}

- (void)fade {
    [UIView animateWithDuration:.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self _ensureHidden];
                     }];
}

-(void)_ensureHidden {
    self.hidden= YES;
    self.transform = CGAffineTransformMakeTranslation(0, -self.height);
}

-(void)barWasTapped:(id)sender {
    [self hide:YES];
    if (self.action) {
        self.action();
    }
}

#pragma mark -
#pragma mark NSNotificationCenter observers
-(void)didUpdateNotificationStream:(NSNotification *)nsnotification {
    Notification *notification = nsnotification.userInfo[BBRemoteNotificationManagerNotification];
    if (self.autoUpdate && notification) {
        [self showNotification:notification];
    }
}
@end
