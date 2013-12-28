//
//  BBFollowersCountLabel.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "NIAttributedLabel.h"

@interface BBCountLabel : NIAttributedLabel
@property (nonatomic,strong) NSString *singular;
@property (nonatomic,strong) NSString *plural;
@property (nonatomic) NSInteger count;
@end
