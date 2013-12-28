//
//  UITableView+Extend.m
//  RestKit
//
//  Created by Aneil Mallavarapu on 6/13/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "UITableView+Extend.h"

@implementation UITableView (Extend)

-(void)extendSection:(NSUInteger)section by:(NSUInteger)count withRowAnimation:(UITableViewRowAnimation)animation {
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger currentLength = [self numberOfRowsInSection:section];
    for (NSUInteger row=currentLength; row<currentLength+count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:indexPath];
    }
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];    
}

-(void)reloadSection:(NSUInteger)section fromRow:(NSUInteger)startRow to:(NSUInteger)endRow withRowAnimation:(UITableViewRowAnimation)animation 
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger row=startRow; row<=endRow; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [indexPaths addObject:indexPath];
    }
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

@end
