//
//  BBCountLabel.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBCountLabel.h"


// Label that displays e.g., "5 likes" or "1 like", depending on count.
// Shows the number in bold
@implementation BBCountLabel {
    NSInteger _count;
}
@dynamic count;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setCount:(NSInteger)count {
    NSString *countStr = [NSString stringWithFormat:@"%d",count];
    self.text = [NSString stringWithFormat:@"%@ %@",countStr,count==1 ? self.singular : self.plural];

    self.font = [UIFont bbFont:12];
    self.textColor = [UIColor bbWarmGray];
    [self setFont:[UIFont bbBoldFont:12]
            range:NSMakeRange(0, countStr.length)];
    _count = count;
}

-(NSInteger)count {
    return _count;
}

@end
