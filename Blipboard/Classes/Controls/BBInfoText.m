//
//  BBInfoText.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBInfoText.h"

@implementation BBInfoText

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)configureWithTime:(NSDate *)createdTime {
    // setup creation time:
    if (createdTime) {
        self.text = [NSString stringWithFormat:@"Blipped %@", [createdTime bbRelativeTimeBeforeNow]];
        [self setFont:[UIFont bbFont:12]];
        [self setFont:[UIFont bbBoldFont:12] range:NSMakeRange(0, [@"Blipped" length])];
    }
    else {
        self.text = @"";
    }
}
@end
