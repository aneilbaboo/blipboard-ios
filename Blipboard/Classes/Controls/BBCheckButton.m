//
//  BBCheckself.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/2/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBCheckButton.h"

@implementation BBCheckButton {
    BOOL _checked;
}
@dynamic checked;

+(instancetype)button {
    BBCheckButton *button = [super buttonWithType:UIButtonTypeCustom];
    [button _setupStyle];
    [button _setupCheck];
    [button _positionCheckButton];
    return button;
}
//-(id)init {
//    self = [super init];
//    [self _setupStyle];
//    [self _setupCheck];
//    [self _positionCheckButton];    
//    return self;
//}
//
//-(id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    [self _setupStyle];
//    [self _setupCheck];
//    [self _positionCheckButton];
//    return self;
//}
//
//-(id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    [self _setupStyle];
//    [self _setupCheck];
//    [self _positionCheckButton];
//    return self;
//}

- (void)_setupCheck {
    UIImage *check = [UIImage imageNamed:@"icn_green_check.png"];
    UIImageView *checkView = [[UIImageView alloc] initWithImage:check];
    checkView.contentMode = UIViewContentModeCenter;
    checkView.autoresizesSubviews = YES;
    checkView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    checkView.width = check.size.width;
    checkView.height = check.size.height;
    self.checkView = checkView;
    _checked = NO;
    checkView.hidden = YES;
    [self _positionCheckButton];
    [self addSubview:checkView];
}

- (void)_setupStyle {
    [self setContentMode:UIViewContentModeLeft];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = CGRectMake(0, 0, self.height, self.height);
    self.titleLabel.font = [UIFont bbBoldFont:18];
    [self setTitleColor:[UIColor bbGray4] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithRGBHex:0x3370b7 alpha:1] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor colorWithRGBHex:0x3370b7 alpha:1] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor colorWithRGBHex:0x3370b7 alpha:1] forState:UIControlStateHighlighted|UIControlStateSelected];

}
- (void)_positionCheckButton {
    BBLogLevel(4,@"buttonWidth:%f,checkViewWidth:%f,edgeInset:%f",
          self.width,self.checkView.width,self.contentEdgeInsets.right);
    CGFloat xPos = self.width-self.checkView.width - self.contentEdgeInsets.right;
    CGFloat yPos = (self.height-self.checkView.height)/2;
    self.checkView.origin = CGPointMake(xPos,yPos);
}

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    [super setContentEdgeInsets:contentEdgeInsets];
    [self _positionCheckButton];
}

-(BOOL)checked {
    return !self.checkView.hidden;
}

-(void)setChecked:(BOOL)checked {
    [self setChecked:checked animated:NO];
}

-(void)setChecked:(BOOL)checked animated:(BOOL)animated {
    if (_checked != checked) {
        NSTimeInterval duration = animated ? .25 : 0;
        CGAffineTransform small = CGAffineTransformMakeScale(.01, .01);
        CGAffineTransform normal = CGAffineTransformIdentity;
        CGAffineTransform from,to;
        BOOL hidden;
        if (checked) {
            from = small;
            to = normal;
            hidden = NO;
        }
        else {
            from = normal;
            to = small;
            hidden = YES;
        }
        self.checkView.transform = from;
        if (!hidden) {
            self.checkView.hidden = NO;
        }
        [UIView
         animateWithDuration:duration
         animations:^{
             self.checkView.transform = to;
         }
         completion:^(BOOL finished) {
             self.checkView.hidden = hidden;
         }];
    }
}
@end
