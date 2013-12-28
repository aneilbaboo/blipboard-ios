//
//  FilterCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 3/3/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "FilterCell.h"

@implementation FilterCell

+(id)filterCell {
    FilterCell *cell = [[[NSBundle mainBundle]
                         loadNibNamed:@"FilterCell" owner:nil options:nil]
                        objectAtIndex:0];
    [cell _setupStyle];
    return cell;
}

-(void)_setupStyle {
    self.picture.layer.cornerRadius = 3;
    self.pictureBackground.backgroundColor = [UIColor bbGray2];
    self.pictureBackground.layer.cornerRadius = 6;
    self.pictureBackground.layer.borderColor = [UIColor bbWhite].CGColor;
    self.pictureBackground.layer.borderWidth = 2;
    self.pictureBackground.layer.masksToBounds = YES;
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    self.title.font = [UIFont bbBoldFont:16];
    self.title.textAlignment = UITextAlignmentCenter;
    self.title.textColor = [UIColor bbGray3];
}

+(NSString *)reuseIdentifier {
    return @"FilterCell"; // !am! must match FilterCell.xib
}

-(void)configureWithTopic:(Topic *)topic last:(BOOL)last {
    [self.picture setImageWithURLString:topic.picture2x placeholderImage:nil];
    
    self.title.text = topic.name;
    [self.title sizeToFit];
    [self.title centerHorizontallyInSuperview];
    
    UIRectCorner corners = last ? UIRectCornerBottomLeft|UIRectCornerBottomRight : 0;
    [self roundCorners:corners xRadius:5 yRadius:5];
    
    self.divider.hidden = last;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundView.backgroundColor = selected ? [UIColor bbSlideoutMenuSelectedColor] : [UIColor bbWhite];
    self.title.textColor = selected ? [UIColor bbWhite] : [UIColor bbGray3];
    self.divider.hidden = selected;
}

@end
