//
//  BBShareKitFormController.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBShareKitFormController.h"

@interface BBShareKitFormController ()

@end

@implementation BBShareKitFormController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.backgroundColor = [UIColor bbPaperWhite];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
