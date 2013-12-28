//
//  SlideoutMenuCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"

@interface SlideoutMenuCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet UIImageView *disclosure;
@property (nonatomic,weak) IBOutlet UIImageView *divider;

+(id)cell;
+(NSString *)reuseIdentifier;
-(void)configureWithName:(NSString *)name ;

@end
