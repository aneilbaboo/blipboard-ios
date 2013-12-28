//
//  BBDropDownToastView.m
//  Blipboard
//
//  Created by Jake Foster on 2/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BBLog.h"
#import "BBDropDownToastView.h"
#import "UIView+position.h"
#import "UIColor+BBColors.h"
#import "UIView+Blipboard.h"

@implementation BBDropDownToastView

#pragma mark - Class Methods
+(BBDropDownToastView *)toastWithFrame:(CGRect)frame
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BBDropDownToastView" owner:nil options:nil];
    BBDropDownToastView* toast = [nib objectAtIndex:0];
    toast.frame = frame;
    toast.toastButton.size = frame.size;
    
    // NOTE: Default values.  JF
    [toast setBackgroundColor:[[UIColor bbWarmGray] colorWithAlphaComponent:.8]];
    [toast roundCorners:UIRectCornerAllCorners xRadius:5 yRadius:5];
    toast.activityIndicator.hidesWhenStopped = YES;
    toast.activityIndicator.hidden = YES;
    toast.hidden = YES;
    return toast;
}


#pragma mark - Public Methods

-(void)showText:(NSString *)text forSeconds:(NSTimeInterval)seconds
{
    static NSTimeInterval lastTextTime = 0;
    static const NSTimeInterval suppressNewMessageInterval = 10;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval secondsAgo = now - lastTextTime;

    // do not show the same toast message over and over for multiple requests
    if (![text isEqualToString:self.toastLabel.text] ||
        secondsAgo>suppressNewMessageInterval)
    {
        self.toastLabel.text = text;
        [self.toastButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
        
        [self fadeIn:.4];
        if (seconds > 0) {
            [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:seconds];
        }
        lastTextTime = now;
    }
}

-(void)dismiss {
    if (!self.hidden) {
        [self fadeOut:.25];
    }
}

#pragma mark - Private Methods

-(void)_fadedOutState {
    CGFloat yoffset = - self.frame.size.height *1.5; // !am! toast drops in from above
    self.transform = CGAffineTransformMakeTranslation(0,yoffset);
    self.alpha = 0;
}
-(void)_fadedInState {
    self.alpha = 1;
    self.transform = CGAffineTransformIdentity;
}

-(void)fadeOut:(NSTimeInterval)time {
    [UIView animateWithDuration:time animations:^{
        BBLogLevel(4,@"Fading out");
        [self _fadedOutState];
    } completion:^(BOOL finished) {
        BBLogLevel(4,@"hiding");
        self.hidden = YES;
    }];
}

-(void)fadeIn:(NSTimeInterval)time {
    static BOOL isAnimating; // don't start another fade-in if we're already in the middle of one
    self.hidden = NO;
    if (!isAnimating) {
        isAnimating = YES;
        [self _fadedOutState];
        [UIView animateWithDuration:time animations:^{
            [self _fadedInState];
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }
}
@end
