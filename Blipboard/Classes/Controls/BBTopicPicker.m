//
//  BBTopicPicker.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/17/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBTopicPicker.h"
#import "BBTopicPickerItemView.h"
#import "BBPickerView.h"

@implementation BBTopicPicker {
    UIPickerView *_pickerView;
}
@dynamic showsSelectionIndicator;

-(id)init {
    self = [super init];
    if (self) {
        [self _addPickerView:self.frame.size];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _addPickerView:frame.size];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _addPickerView:self.frame.size];
    }
    return self;
}

-(void)_addPickerView:(CGSize)size {
    self.backgroundColor = [UIColor bbHeaderPattern];
    self.autoresizesSubviews = YES;
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    _pickerView = [[BBPickerView alloc] initWithFrame:frame];
    _pickerView.showsSelectionIndicator = YES;
    [_pickerView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    _pickerView.delegate = self;
    [self addSubview:_pickerView];
}

#pragma mark -
#pragma mark Properties and Methods
-(BOOL)showsSelectionIndicator {
    return _pickerView.showsSelectionIndicator;
}

-(void)setShowsSelectionIndicator:(BOOL)showsSelectionIndicator {
    [_pickerView setShowsSelectionIndicator:showsSelectionIndicator];
}

-(void)selectRow:(NSInteger)row animated:(BOOL)animated {
    [_pickerView selectRow:row inComponent:0 animated:animated];
}

-(void)selectTopic:(Topic *)topic animated:(BOOL)animated {
    NSInteger row = 0;
    for (Topic *t in self.topics) {
        if ([topic.id isEqualToString:t.id]) {
            [_pickerView selectRow:row inComponent:0 animated:YES];
            break;
        }
        row++;
    }
}

// sets the topics, reloads the pickerView, sets it to the place's topic
-(void)setTopics:(NSMutableArray *)topics {
    _topics = topics;
    [_pickerView reloadAllComponents];
}

-(NSInteger)selectedRow {
    return [_pickerView selectedRowInComponent:0];
}

-(Topic *)selectedTopic {
    NSInteger row =[_pickerView selectedRowInComponent:0];
    return (row>0) ? self.topics[row] :0;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.topics.count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    Topic *topic = self.topics[row];
    BBTopicPickerItemView *tpiView = (BBTopicPickerItemView *)[BBTopicPickerItemView topicPickerItem];
    [tpiView configureWithTopic:topic];
    return tpiView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Topic *topic = self.topics[row];
    
    [self.delegate topicPicker:self selectedTopic:topic];
}

@end
