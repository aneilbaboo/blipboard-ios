//
//  BBTopicPicker.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/17/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Topic.h"

@class BBTopicPicker;

@protocol BBTopicPickerDelegate <NSObject>

-(void)topicPicker:(BBTopicPicker *)topicPicker selectedTopic:(Topic *)topic;

@end

@interface BBTopicPicker : UIView <UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic,strong) NSMutableArray *topics;
@property (nonatomic,weak) IBOutlet id<BBTopicPickerDelegate>delegate;
@property (nonatomic) BOOL showsSelectionIndicator;

-(Topic *)selectedTopic;
-(NSInteger)selectedRow;
-(void)selectRow:(NSInteger)row animated:(BOOL)animated;
-(void)selectTopic:(Topic *)topic animated:(BOOL)animated;

@end
