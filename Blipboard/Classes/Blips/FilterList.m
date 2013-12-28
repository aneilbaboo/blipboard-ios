//
//  FilterList.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "FilterList.h"
#import "FilterCell.h"

const CGFloat kFilterListHideTriggerDistance=40;

@implementation FilterList {
    NSArray *_channelTypeFilters;
    Topic *_selectedTopic; // !am! why is compiler not auto generating this field???
}
@dynamic hidden;

+(FilterList *)filterList {
    FilterList *filterList = [FilterList new];
    [[NSBundle mainBundle] loadNibNamed:@"FilterList" owner:filterList options:nil];
    [filterList _setupStyle];
    return filterList;
}

-(void)_setupStyle {
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.scrollsToTop = NO;
    [self.tableView bbSetShadow:BlipboardShadowOptionRight|BlipboardShadowOptionDown];
    [self.titleButton.titleLabel setFont:[UIFont bbBoldFont:20]];
    [self.titleButton setTitleColor:[UIColor bbGray4] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor bbGray2] forState:UIControlStateHighlighted];
    self.titleButton.imageView.backgroundColor = [UIColor bbGray2];
    self.titleButton.imageView.layer.cornerRadius = 4;
    self.titleButton.imageView.layer.masksToBounds = YES;
    self.titleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleButton.titleLabel.size = CGSizeZero;
    [self _updateTitleView];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = .5;
    
    UILabel *peopleLabel = [UILabel new];
    UILabel *placesLabel = [UILabel new];
    peopleLabel.text = @"People";
    placesLabel.text = @"Places";
    _channelTypeFilters = @[@[self.titleView,@"All",@""],
                            @[peopleLabel,@"People",@"user"],
                            @[placesLabel,@"Places",@"place"]];
}

-(Topic *)selectedTopic {
    return _selectedTopic;
}

-(void)setSelectedTopic:(Topic *)selectedTopic {
    NSInteger row = 0;
    if (selectedTopic) {
        for (Topic *topic in self.topics) {
            row ++;
            if ([topic.id isEqualToString:self.selectedTopic.id]) {
                _selectedTopic = topic;
                break;
            }
        }
    }
    _selectedTopic = selectedTopic;
    NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:row inSection:1];
    [self.tableView selectRowAtIndexPath:defaultIndexPath animated:YES scrollPosition:UITableViewRowAnimationTop];

    [self _updateTitleView];
}

-(void)_updateTitleView {
    BBTraceLevel(4);
    if (_selectedTopic) {
        [self.titleButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.titleButton setTitle:_selectedTopic.name forState:UIControlStateNormal];
        [self.titleButton setTitle:_selectedTopic.name forState:UIControlStateHighlighted];
        self.titleButton.size = [self.titleButton.titleLabel sizeThatFits:self.titleView.size];
        self.titleButton.rx = (self.titleView.width-self.titleButton.width)/2.0;
        
    }
    else {
        UIImage *logo = [UIImage imageNamed:@"blipboard_logo.png"];
        [self.titleButton setBackgroundImage:logo
                                    forState:UIControlStateNormal];
        [self.titleButton setImage:nil forState:UIControlStateNormal];
        [self.titleButton setTitle:nil forState:UIControlStateNormal];
        [self.titleButton setTitle:nil forState:UIControlStateHighlighted];
        BBLogLevel(4,@"titleButton.size (%@) <= logo.size (%@)",
              NSStringFromCGSize(self.titleButton.size),
              NSStringFromCGSize(logo.size)); 
        self.titleButton.size = logo.size;
        self.titleButton.rx = 47;
//        self.titleButton.rx = (self.titleView.width-self.titleButton.width)/2.0;
    }
}

-(void)addToViewController:(UIViewController *)viewController {
    viewController.navigationItem.titleView = self.titleView;
    [viewController.view addSubview:self.backgroundView];
    [viewController.view addSubview:self.tableView];
    self.tableView.height = viewController.view.height;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.tableView centerHorizontallyInSuperview];
    [self setHidden:YES];
}

-(void)refreshTopics {
    [self refreshTopics:nil];
}

-(void)refreshTopics:(void (^)())completion {
    [BBAppDelegate.sharedDelegate.myAccount getTopics:^(NSMutableArray *topics, ServerModelError *error) {
        if (!error) {
            self.topics = topics;
            [self.tableView reloadData];
            [self setSelectedTopic:_selectedTopic];
        }
        if (completion) {
            completion();
        }
    }];
}

-(BOOL)hidden {
    return self.backgroundView.hidden;
}

-(void)setHidden:(BOOL)hidden {
    [self.backgroundView setHidden:hidden];
    self.tableView.ry = hidden ? - self.tableView.height : 0;
    self.backgroundView.alpha = 0;
}

// the table appears from above
-(void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        if (hidden) {
            [UIView animateWithDuration:.2
                                  delay:0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 self.tableView.ry = -self.tableView.height -20;
                                 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                 self.backgroundView.alpha = 0;
                             } completion:^(BOOL finished) {
                                 self.backgroundView.hidden = YES;
                             }];
        }
        else {
            self.backgroundView.hidden = NO;
            [UIView animateWithDuration:.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                self.tableView.ry = 0;
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                self.backgroundView.alpha = .5;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    else {
        [self setHidden:hidden];
    }
}

-(UIView *)parentView {
    return self.tableView.superview;
}

#pragma mark -
#pragma mark Actions
-(IBAction)backgroundTapped:(id)sender {
    [self setHidden:YES animated:YES];
}

-(void)titleViewTapped:(id)sender {
    if (self.hidden) {
        if (!self.topics) {
            [self refreshTopics:^{
                [self setHidden:NO animated:YES];
            }];
        }
        else {
            [self setHidden:NO animated:YES];
        }
    }
    else {
        [self setHidden:YES animated:YES];
    }
}

#pragma mark -
#pragma mark UITableView Datasource & Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSInteger section = indexPath.section;
    FilterCell *cell = [tableView dequeueReusableCellWithIdentifier:FilterCell.reuseIdentifier];
    if (!cell) {
        cell = [FilterCell filterCell];
    }
    
    switch (section) {
        case 0:
        {
            NSArray *typeFilter = _channelTypeFilters[row];
            NSString *listText = typeFilter[1];
            
            cell.imageView.image = nil;
            [cell.title setText:listText];
            return cell;
        }
        case 1:
        {
            BOOL lastCell = (row==(self.topics.count));
            if (row==0) {
                cell.title.text = @"All";
                cell.picture.image = [UIImage imageNamed:@"icn_asterisk.png"];
            }
            else {
                Topic *topic = _topics[row-1];
                [cell configureWithTopic:topic last:lastCell];
            }
            return cell;
        }
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0; //_channelTypeFilters.count;
            
        case 1:
            return  _topics.count+1;
    
        default:
            return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
            
            break;
            
        case 1:
        {
            Topic *topic = row>0 ? _topics[row-1] : nil;
            _selectedTopic = topic;
            [self _updateTitleView];
            [self.delegate filterList:self didSelectTopic:topic];
            
            break;
        }
    }
    
    [self setHidden:YES animated:YES];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat maxYContentOffset = MAX(scrollView.contentSize.height-self.parentView.height,0) + kFilterListHideTriggerDistance;
    CGFloat yContentOffset = scrollView.contentOffset.y;
    if (yContentOffset>maxYContentOffset) {
        [self setHidden:YES animated:YES];
    }
    else if (yContentOffset<0) {
        scrollView.contentOffset=CGPointMake(scrollView.contentOffset.x,0);
    }

}
@end
