//
//  SlideoutMenuUserCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "BBImageView.h"

@interface SlideoutMenuUserCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UIImageView *disclosure;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIView *pictureBackdrop;

+(id)cell;
+(NSString *)reuseIdentifier;
-(void)configureWithAccount:(Account *)account;

@end    