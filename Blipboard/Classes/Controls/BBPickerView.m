//
//  BBPickerView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/17/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBPickerView.h"

@implementation BBPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupStyle];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _setupStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setupStyle];
    }
    return self;
}

-(void)_setupStyle {
    CALayer* mask = [[CALayer alloc] init];
    [mask setBackgroundColor: [UIColor bbGridPattern].CGColor];
    [mask setFrame: CGRectMake(10, 10, 320-20, 216-20)];
    [mask setCornerRadius: 5.0f];
    [self.layer setMask: mask];
}

@end
