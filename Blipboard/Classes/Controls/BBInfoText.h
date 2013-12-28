//
//  BBInfoText.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "NIAttributedLabel.h"

@interface BBInfoText : NIAttributedLabel
-(void)configureWithTime:(NSDate *)createdTime;
@end
