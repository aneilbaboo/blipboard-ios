//
//  ChannelTableView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 12/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ChannelTableView.h"
#import "ChannelCell.h"
#import "Flurry+Blipboard.h"
#import "BBAppDelegate.h"
#import "UIColor+BBColors.h"

@implementation ChannelTableView {
    NSMutableArray *_channels;
}

@dynamic channels;
@dynamic topInset;
@dynamic bottomInset;
@dynamic contentOffset;
@dynamic scrollsToTop;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setupTable:self.frame];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupTable:frame];
    }
    return self;
}

- (void)_setupTable:(CGRect) frame {
    self.backgroundColor = [UIColor clearColor];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _tableView = table;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.scrollsToTop = YES;
    _tableView.backgroundColor = [UIColor bbGridPattern];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.opaque = YES;
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:table];

}
- (NSArray *)channels {
    return _channels;
}

- (void)setChannels:(NSArray *)channels {
    _channels = [NSMutableArray arrayWithArray:channels];

    // !am! simple way to ignore place channel descriptions
    for (Channel *channel in _channels) {
        if (channel.type==ChannelTypePlace) {
            channel.desc = @"";
        }
    }
    
    [_tableView reloadData];
}


-(void)setBottomInset:(CGFloat)tableBottomInset {
    _tableView.contentInset = UIEdgeInsetsMake(_tableView.contentInset.top, 0, tableBottomInset, 0);
}

-(CGFloat)bottomInset {
    return _tableView.contentInset.bottom;
}

-(void)setTopInset:(CGFloat)tableTopInset {
    _tableView.contentInset = UIEdgeInsetsMake(tableTopInset, 0, _tableView.contentInset.bottom, 0);
}

-(CGFloat)topInset {
    return _tableView.contentInset.top;
}

-(CGFloat)contentOffset {
    return _tableView.contentOffset.y;
}

-(void)setContentOffset:(CGFloat)y {
    _tableView.contentOffset = CGPointMake(0,y);
}

-(BOOL)scrollsToTop {
    return _tableView.scrollsToTop;
}

-(void)setScrollsToTop:(BOOL)scrollsToTop {
    [_tableView setScrollsToTop:scrollsToTop];
}

-(void)scrollToRow:(NSUInteger)row atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    if (_channels.count > row) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                          atScrollPosition:scrollPosition
                                  animated:animated];
    }
}
#pragma mark -
#pragma mark ChannelCellDelegate
- (void)channelCellTuneInPressed:(ChannelCell *)cell {
    
    [[BBRemoteNotificationManager sharedManager] promptUserToEnablePushNotificationsIfNeeded];
    
    // !am! not happy with this code being placed here
    UIButton* button = cell.tuneInButton;
    Channel *channel = cell.channel;
    button.selected = !button.selected;
    if (!button.selected) {
        [channel tuneOut:^(Channel *channel, ServerModelError *error) {
            [Flurry logEvent:kFlurryChannelCellUnfollow withErrorAndParams:error,
             @"id",channel.id,
             @"type",channel._typeString,
             @"listName",self.listName,
             nil];
            if (!error) {
                [cell configureWithChannel:channel];
            }
            else {
                button.selected = !button.selected;
            }
        }];
    }
    else {
        [channel tuneIn:^(Channel *channel, ServerModelError *error) {
            [Flurry logEvent:kFlurryChannelCellFollow withErrorAndParams:error,
             @"id",channel.id,
             @"type",channel._typeString,
             @"listName",self.listName,
             nil];
            if (!error) {
                [cell configureWithChannel:channel];
            }
            else {
                button.selected = !button.selected;
            }
        }];
    }
}

#pragma mark -
#pragma mark UITableView methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    Channel *channel = [self.channels objectAtIndex:row];
    return [ChannelCell cellHeightFromText:channel.desc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Channel *channel = [self.channels objectAtIndex:[indexPath row]];
    [self.delegate channelTableView:self didSelectChannel:channel];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChannelCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ChannelCell.reuseIdentifier];
    if (!cell) {
        cell = [ChannelCell channelCellWithDelegate:self style:self.cellStyle];
    }
    
    NSUInteger row = [indexPath row];
    [cell configureWithChannel:[self.channels objectAtIndex:row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_channels count];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(channelTableViewDidScroll:)]) {
        [self.delegate channelTableViewDidScroll:self];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.header;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.header.height;
}
@end
