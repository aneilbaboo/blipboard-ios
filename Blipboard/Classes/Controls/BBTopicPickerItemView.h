//
//  BBTopicPickerItemView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/15/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTopicPickerItemView : UIView
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIView *pictureBackground;

+ (id)topicPickerItem;
-(void)configureWithTopic:(Topic *)topic;
@end
