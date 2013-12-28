//
//  BBTouchableTextView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/15/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBTouchableTextView.h"

/** A UITextView that doesn't eat touch events
 *
 */
@implementation BBTouchableTextView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.superview touchesEnded:touches withEvent:event];
}
@end
