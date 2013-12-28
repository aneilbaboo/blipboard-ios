//
//  KIFTestScenario+BBAdditions.m
//  Blipboard
//
//  Created by Jason Fischl on 10/21/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "KIFTestScenario+BBAdditions.h"
#import "KIFTestStep+BBAdditions.h"


@implementation KIFTestScenario (BBAdditions)


+ (id)scenarioToLogIn
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Test that a user can successfully log in."];
    [scenario addStep:[KIFTestStep stepToReset]];

    /*
    // Respond to "Would Like to Use Your Current Location"
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"OK"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Don't Allow"]];


    // Skip for now.  Facebook Auth won't work since it hands off to Safari.  This test would block on Safari input and time out.
    // Facebook Authentication + Login creditials
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"faceBook up"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Okay"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"joe.blipper@gmail.com" intoViewWithAccessibilityLabel:@"Email or Phone"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"b1ipb0ard" intoViewWithAccessibilityLabel:@"Password"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Log In"]];

    // Blipboard confirm
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Okay"]];

    // Verify that the login succeeded
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Welcome"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Okay"]];

    // Dismiss the welcome message
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Blipboard SF"]];
    */
    
    return scenario;
}

+ (id)scenarioToClickThroughButtons
{
    KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"Click through buttons"];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Popular"]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Me"]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Alerts"]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"blip add up"]];

    // [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"locate up"]];
    // [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"info button up"]];
    
    return scenario;
}



@end
