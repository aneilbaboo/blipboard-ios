//
//  WebViewController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/10/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    if (self.showSlideoutMenu) {
        [[SlideoutViewController sharedController] addSlideoutMenu:self];
        [[SlideoutViewController sharedController] addMenuButtonAndBadge:self];
    }
    [self setToolbarTintColor:[UIColor bbWarmGray]];
}
@end
