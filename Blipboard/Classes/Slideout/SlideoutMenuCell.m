//
//  SlideoutMenuCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 2/22/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "SlideoutMenuCell.h"
#import "UIColor+BBSlideout.h"

NSString * const kSMCReuseIdentifier = @"SlideoutMenuCell";

@implementation SlideoutMenuCell

+(NSString *)reuseIdentifier {
    return kSMCReuseIdentifier;
}

-(NSString *)reuseIdentifier {
    return kSMCReuseIdentifier;
}

+(id)cell {
    SlideoutMenuCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SlideoutMenuCell" owner:nil options:nil] objectAtIndex:0];
    [cell _setStaticStyle];
    return cell;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.title setTextColor:[UIColor bbSlideoutMenuSelectedTextColor]];
        [self.disclosure setImage:[UIImage imageNamed:@"btn_arrow_on.png"]];
        [self.divider setHidden:YES];
;
    }
    else {
        [self.title setTextColor:[UIColor bbSlideoutMenuUnselectedTextColor]];
        [self.disclosure setImage:[UIImage imageNamed:@"btn_arrow_off.png"]];
        [self.divider setHidden:NO];
    }
}

-(void)_setStaticStyle {
    [self.title setFont:[UIFont bbBoldFont:16]];
    self.selected = NO;
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.backgroundView setBackgroundColor:[UIColor bbSlideoutMenuUnselectedColor]];

    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.selectedBackgroundView setBackgroundColor:[UIColor bbSlideoutMenuSelectedColor]];
    
}

-(void)configureWithName:(NSString *)name {
    [self.title setText:name];
}


@end
