//
//  BlipTableView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//



#import "BBAppDelegate.h"
#import "BBLog.h"
#import "BlipTableView.h"
#import "UITableView+Extend.h"

@implementation BlipTableView

@dynamic topInset;
@dynamic bottomInset;
@dynamic scrollsToTop;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // create UITableView
        CGRect tableFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tableView = [[UITableView alloc] initWithFrame:tableFrame];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.opaque = NO;
        _tableView.backgroundColor = [UIColor bbGridPattern];
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = YES;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.opaque = YES;
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tableView];
        
        _blipCellDisplayMode = BlipCellDisplayModeBoth;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithFrame:self.frame];
}

#pragma mark -
#pragma mark Operations
-(void)reloadData
{
    [_tableView reloadData];
}

-(void)scrollToRow:(NSUInteger)row atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    if (_blips.count) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                          atScrollPosition:scrollPosition
                                  animated:animated];
    }
}

#pragma mark -
#pragma mark Properties
-(NSArray *)blips {
    return _blips;
}

-(BOOL)scrollsToTop {
    return _tableView.scrollsToTop;
}

-(void)setScrollsToTop:(BOOL)scrollsToTop {
    [_tableView setScrollsToTop:scrollsToTop];
}

-(void)setBlips:(NSArray *)blips {
    NSMutableArray *mutableBlips = [blips isKindOfClass:[NSMutableArray class]] ? blips : [NSMutableArray arrayWithArray:blips];
    _blips = mutableBlips;
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

#pragma mark -
#pragma mark UIView override
// !am! attempting to get default iOS behavior where tap on navbar scrolls the table to top:
//      but this doesn't fix it.
-(void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        [_tableView setScrollsToTop:YES];
    }
    else {
        [_tableView setScrollsToTop:NO];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BlipCell heightFromBlip:[_blips objectAtIndex:[self dataIndexFromIndexPath:indexPath]]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlipCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:[BlipCell reuseIdentifier]];
    if (cell==nil) {
        cell = [BlipCell blipCellWithDelegate:self];
    }
    
    Blip *blip = [_blips objectAtIndex:[self dataIndexFromIndexPath:indexPath]] ;
    
    [cell configureWithBlip:blip
                   location:nil
                       mode:_blipCellDisplayMode];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _blips.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Blip *blip = [_blips objectAtIndex:[self dataIndexFromIndexPath:indexPath]];
    [self.delegate blipTableView:self didSelectBlip:blip];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(blipTableViewDidScroll:)]) {
        [self.delegate blipTableViewDidScroll:self];
    }
}


#pragma mark -
#pragma mark BlipCellDelegate methods
-(void)blipCell:(BlipCell *)cell channelPressed:(Channel *)channel {
    [self.delegate blipTableView:self didSelectChannel:channel];
}

-(void)blipCellCommentPressed:(BlipCell *)cell {
    [self.delegate blipTableView:self didTapBlipComment:(Blip *)cell.blip];
}

-(void)blipCellLikePressed:(BlipCell *)cell {
    cell.likeButton.selected = !cell.likeButton.selected;
    if (cell.likeButton.selected) {
        [cell.blip like:^(Blip *blip, ServerModelError *error) {}];
    }
    else {
        [cell.blip unlike:^(Blip *blip, ServerModelError *error) {}];
    }
}

#pragma mark Misc Helper methods
- (NSInteger) dataIndexFromIndexPath:(NSIndexPath *)path {
    return [path row];
}

- (NSIndexPath*) indexPathFromDataIndex:(NSInteger)index {
    return[NSIndexPath indexPathForRow:index inSection:0];
}

- (BOOL) isLastRow:(NSIndexPath *)indexPath {
    if (_blips) {
        return [self dataIndexFromIndexPath:indexPath] == (_blips.count-1 );
    }
    else {
        return YES; // !am! just in case we get here
    }
}

-(void) reloadCellForBlip:(Blip *)blip {
    for (BlipCell *cell in [_tableView visibleCells]) {
        if ([cell isKindOfClass:[BlipCell class]] &&
            [cell.blip.id isEqualToString:blip.id]) {
            [cell configureWithBlip:blip
                           location:nil
                               mode:_blipCellDisplayMode];
        }
    }
}

-(void) updateCellForBlip:(Blip *)blip {
    for (BlipCell *cell in [_tableView visibleCells]) {
        if([cell isKindOfClass:[BlipCell class]] &&
           [cell.blip.id isEqualToString:blip.id]) {
            [cell updateWithBlip:blip];
        }
    }
}

- (void) updateBlip:(Blip*)blip
{
    for (int i=0; i<_blips.count; ++i) {
        Blip* b = (Blip*)[_blips objectAtIndex:i];
        if ([b.id isEqualToString:blip.id]) {
            [_blips replaceObjectAtIndex:i withObject:blip];
            NSIndexPath* indexPath = [self indexPathFromDataIndex:i];
            
            // don't move the position if the cell is already visible in the table. 
            NSArray* visibleIndexPaths = [_tableView indexPathsForVisibleRows];
            if (![visibleIndexPaths containsObject:indexPath]) {
                [_tableView reloadSection:0 fromRow:indexPath.row to:indexPath.row withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}


- (void) showBlip:(Blip*)blip
{
    BBTraceLevel(4);
    NSUInteger row=0;
    for (Blip* cell in _blips) {
        if ([cell.id isEqualToString:blip.id]) {
            NSIndexPath* indexPath = [self indexPathFromDataIndex:row];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
        row++;
    }
}


@end
