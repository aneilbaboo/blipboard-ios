//
//  ChannelTableView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelCell.h"
#import "BBTableProtocol.h"

@class ChannelTableView;
@protocol ChannelTableViewDelegate <NSObject>
-(void)channelTableView:(ChannelTableView *)channelTable didSelectChannel:(Channel *)channel;
@optional
-(void)channelTableViewDidScroll:(ChannelTableView *)channelTable;

@end

@interface ChannelTableView : UIView <UITableViewDelegate,UITableViewDataSource,ChannelCellDelegate,BBTableProtocol>

@property (nonatomic,weak) IBOutlet id<ChannelTableViewDelegate> delegate;
@property (nonatomic,strong) NSArray *channels;
@property (nonatomic) BOOL hideDescription;
@property (nonatomic) ChannelCellStyle cellStyle;
@property (nonatomic,strong) UIView *header;

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) NSString *listName;    // !am! for reporting to analytics
                                                    // e.g., "followers", "following", "gurus"
@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat contentOffset;
@property (nonatomic) BOOL scrollsToTop;

@end
