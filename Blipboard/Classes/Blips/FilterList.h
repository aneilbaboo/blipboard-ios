//
//  FilterList.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "Topic.h"

@class FilterList;

@protocol FilterListDelegate <NSObject>

-(void)filterList:(FilterList *)filterList didSelectTopic:(Topic *)topic;

@end

#pragma mark -
#pragma mark FilterList
@interface FilterList : NSObject <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray *topics;
@property (nonatomic,strong) Topic *selectedTopic;
@property (nonatomic)        BOOL hidden;
@property (nonatomic,weak) id<FilterListDelegate> delegate;

#pragma mark IBOutlets
@property (nonatomic,strong) IBOutlet   UIView *titleView;
@property (nonatomic,weak) IBOutlet     UIButton *titleButton;
@property (nonatomic,strong) IBOutlet   UIView *backgroundView;
@property (nonatomic,weak) IBOutlet     UITableView *tableView;

#pragma mark constructor
+(FilterList *)filterList;

#pragma mark methods
-(void)setHidden:(BOOL)hidden animated:(BOOL)animated;
-(void)refreshTopics;
-(void)refreshTopics:(void (^)())completion;
-(void)addToViewController:(UIViewController *)viewController;
-(IBAction)backgroundTapped:(id)sender;
-(IBAction)titleViewTapped:(id)sender;
@end
