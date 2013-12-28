//
//  UITableView+Extend.h
//  RestKit
//
//  Created by Aneil Mallavarapu on 6/13/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Extend)
-(void)extendSection:(NSUInteger)section by:(NSUInteger)count withRowAnimation:(UITableViewRowAnimation)animation;
-(void)reloadSection:(NSUInteger)section fromRow:(NSUInteger)startRow to:(NSUInteger)endRow withRowAnimation:(UITableViewRowAnimation)animation;
@end
