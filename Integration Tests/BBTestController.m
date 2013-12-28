//
//  BBTestController.m
//  Blipboard
//
//  Created by Jason Fischl on 10/21/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBTestController.h"
#import "KIFTestScenario+BBAdditions.h"
#import <dlfcn.h>

@implementation BBTestController

- (void)initializeScenarios;
{
    // Unable to test Facebook auth since it goes through safari.
    // [self addScenario:[KIFTestScenario scenarioToLogIn]];
    
    [self addScenario:[KIFTestScenario scenarioToClickThroughButtons]];
    // Add additional scenarios you want to test here

}

@end
