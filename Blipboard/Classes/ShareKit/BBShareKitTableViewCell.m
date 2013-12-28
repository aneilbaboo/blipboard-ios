//
//  BBShareKitTableViewCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBShareKitTableViewCell.h"

@implementation BBShareKitTableViewCell

- (void)_setupStyle {
    self.textLabel.font = [UIFont bbFont:18];
    self.detailTextLabel.font = [UIFont bbFont:10];
    self.textLabel.textColor = [UIColor bbWarmGray];
    self.detailTextLabel.textColor = [UIColor bbWarmGray];
    self.contentView.backgroundColor = [UIColor bbPaperWhite];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
