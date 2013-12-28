//
//  BBDropDownToastView.h
//  Blipboard
//
//  Created by Jake Foster on 2/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ToastViewDisplayStateVisible = 0,
    ToastViewDisplayStateHidden = 1
} ToastViewDisplayState;

@interface BBDropDownToastView : UIView

@property (weak,nonatomic) IBOutlet UILabel* toastLabel;
@property (weak,nonatomic) IBOutlet UIButton* toastButton;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView* activityIndicator;

+(BBDropDownToastView*)toastWithFrame:(CGRect)frame;
-(void)showText:(NSString *)text forSeconds:(NSTimeInterval)seconds;
-(void)dismiss;

@end
