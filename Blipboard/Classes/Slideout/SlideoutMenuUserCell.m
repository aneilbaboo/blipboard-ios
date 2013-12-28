//
//  SlideoutMenuUserCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SlideoutMenuUserCell.h"
#import "Channel.h"
#import "UIColor+BBSlideout.h"

NSString * const kSMUCReuseIdentifier = @"SlideoutMenuUserCell";
@implementation SlideoutMenuUserCell {
    Account *_account;
}


+(NSString *)reuseIdentifier {
    return kSMUCReuseIdentifier;
}

-(NSString *)reuseIdentifier {
    return kSMUCReuseIdentifier;
}

+(id)cell {
    static SlideoutMenuUserCell *cell;
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SlideoutMenuUserCell" owner:nil options:nil] objectAtIndex:0];
    
        [cell _setStaticStyle];
    }
    return cell;
}

-(void)_setStaticStyle {
    [self.name setFont:[UIFont bbBoldFont:20]];
    [self.picture.layer setBackgroundColor:[UIColor bbSlideoutNotificationsTableBackground].CGColor];

    self.selected = NO;
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.backgroundView setBackgroundColor:[UIColor bbSlideoutMenuUnselectedColor]];

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.selectedBackgroundView setBackgroundColor:[UIColor bbSlideoutMenuSelectedColor]];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.name setTextColor:[UIColor bbSlideoutMenuSelectedTextColor]];
        [self.disclosure setImage:[UIImage imageNamed:@"btn_arrow_on.png"]];
        self.pictureBackdrop.backgroundColor = [UIColor bbWhite];
        self.pictureBackdrop.opaque = YES;
    }
    else {
        [self.name setTextColor:[UIColor bbSlideoutMenuUnselectedTextColor]];
        [self.disclosure setImage:[UIImage imageNamed:@"btn_arrow_off.png"]];
        self.pictureBackdrop.backgroundColor = [UIColor bbWhite];
        self.pictureBackdrop.opaque = YES;
    }
}
-(void)configureWithAccount:(Account *)account {
    [self.name setText:account.name];

    [self.picture setImageWithURLString:account.picture placeholderImage:nil];
    

}
@end
