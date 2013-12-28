//
//  FilterCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UILabel *title;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIView *pictureBackground;
@property (nonatomic,weak) IBOutlet UIImageView *divider;
+(id)filterCell;
+(NSString *)reuseIdentifier;
-(void)configureWithTopic:(Topic *)topic last:(BOOL)last;
@end
