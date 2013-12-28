//
//  BBTopicPickerItemView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/15/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBTopicPickerItemView.h"

@implementation BBTopicPickerItemView

+ (id)topicPickerItem {
    BBTopicPickerItemView *tpItem = (BBTopicPickerItemView *)[[NSBundle mainBundle] loadNibNamed:@"BBTopicPickerItemView" owner:nil options:nil][0];
    [tpItem _setupStyle];
    return tpItem;
}

-(void)configureWithTopic:(Topic *)topic {
    [self.picture setImageWithURLString:topic.picture2x placeholderImage:nil];
    self.name.text = topic.name;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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
    self.name.font = [UIFont bbBoldFont:20];
    self.name.textColor = [UIColor bbWarmGray];
    self.pictureBackground.layer.masksToBounds = YES;
    self.pictureBackground.layer.cornerRadius = 4;
    self.pictureBackground.backgroundColor = [UIColor bbOrange];
}

@end
