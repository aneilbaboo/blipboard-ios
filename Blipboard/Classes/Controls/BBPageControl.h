//
//  BBPageControl.h
//  Blipboard
//
//  Created by Jake Foster on 12/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BBPageControl;


@protocol BBPageControlDelegate<NSObject>
@optional
- (void)pageControlPageDidChange:(BBPageControl *)pageControl;
@end


@interface BBPageControl : UIView
{
    __weak id<BBPageControlDelegate> _delegate;
}

// Set these to control the PageControl.
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger numberOfPages;

@property (nonatomic, strong) UIColor *dotColorCurrentPage;
@property (nonatomic, strong) UIColor *dotColorOtherPage;

@property (nonatomic, weak) NSObject<BBPageControlDelegate> *delegate;

@end

