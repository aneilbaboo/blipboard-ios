//
//  KIFTestStep+BBAdditions.m
//  Blipboard
//
//  Created by Jason Fischl on 10/22/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "KIFTestStep+BBAdditions.h"

@implementation KIFTestStep (BBAdditions)

+ (id)stepToReset
{
    return [KIFTestStep stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
        BOOL successfulReset = YES;
        
        // Do the actual reset for your app. Set successfulReset = NO if it fails.
        KIFTestCondition(successfulReset, error, @"Failed to reset the application.");
        
        return KIFTestStepResultSuccess;
    }];
}

+ (NSArray *)stepsToGoToLoginPage;
{
    NSMutableArray *steps = [NSMutableArray array];
    
    // Dismiss the welcome message
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"That's awesome!"]];
    
    // Tap the "I already have an account" button
    [steps addObject:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"I already have an account."]];
    
    return steps;
}


+ (KIFTestStep*) stepToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation {
    
    NSString* orientation = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? @"Landscape" : @"Portrait";
    return [KIFTestStep stepWithDescription: [NSString stringWithFormat: @"Rotate to orientation %@", orientation]
                             executionBlock: ^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
                                 if( [UIApplication sharedApplication].statusBarOrientation != toInterfaceOrientation ) {
                                     UIDevice* device = [UIDevice currentDevice];
                                     SEL message = NSSelectorFromString(@"setOrientation:");
                                     
                                     if( [device respondsToSelector: message] ) {
                                         NSMethodSignature* signature = [UIDevice instanceMethodSignatureForSelector: message];
                                         NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
                                         [invocation setTarget: device];
                                         [invocation setSelector: message];
                                         [invocation setArgument: &toInterfaceOrientation atIndex: 2];
                                         [invocation invoke];
                                     }
                                 }
                                 
                                 return KIFTestStepResultSuccess;
                             }];
}


@end
