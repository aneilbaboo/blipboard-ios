//
//  BBTableProtocol.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBTableProtocol <NSObject>
-(BOOL)scrollsToTop;
-(void)setScrollsToTop:(BOOL)scrollsToTop;
-(CGFloat)topInset;
-(void)setTopInset:(CGFloat)topInset;
-(CGFloat)bottomInset;
-(void)setBottomInset:(CGFloat)bottomInset;
-(CGFloat)contentOffset;
-(void)setContentOffset:(CGFloat)contentOffset;
-(void)scrollToRow:(NSUInteger)row atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@end