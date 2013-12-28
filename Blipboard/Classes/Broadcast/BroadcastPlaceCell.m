//
//  BroadcastPlaceCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BroadcastPlaceCell.h"
#import "PlaceChannel.h"

@implementation BroadcastPlaceCell
+(NSString *)reuseIdentifier {
    return @"BTVC";
}

+(id)broadcastPlaceCell {
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"BroadcastPlaceCell" 
                                                    owner:nil
                                                  options:nil];
    BroadcastPlaceCell *cell = [bundle objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell _initStyle];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _initStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _initStyle];
    return self;
}

- (void)_initStyle 
{
    self.picture.layer.borderColor = [UIColor bbGray1].CGColor;
    self.picture.layer.borderWidth = 1;
    self.picture.layer.cornerRadius = 3;
    self.picture.backgroundColor = [UIColor clearColor];
    self.picture.layer.masksToBounds = YES;
    
    self.name.font = [UIFont bbBoldFont:12];
    
    self.tuneInCount.textAlignment = NSTextAlignmentCenter;
    self.tuneInCount.font = [UIFont bbBoldFont:17];
    self.tuneInCountLabel.font = [UIFont bbCondensedFont:10];

    self.address.font = [UIFont bbCondensedFont:10];

    self.divider.image = [UIImage imageNamed:@"divider_dotted.png"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//!lal! Casting the channel to PlaceChannel since we are only dealing with places
-(void) configureWithChannel:(PlaceChannel *)channel
{    
    //Adding the badge on the Alerts tab
    _tuneInCount.text = channel.stats._followers.stringValue;
    
    self.channel = channel;
    //BBLog(@"URL: %@",channel.picture);
    [self.picture setImageWithURLString:channel.picture placeholderImage:nil];
    NSString* name = [NSString stringWithFormat:@"%@", channel.name];
    self.name.text = name;
    if(channel.location.street) {
        NSString* location = [NSString stringWithFormat:@"%@", channel.location.street];
        self.address.text = location;
    } else {
        self.address.text = @"";
    }
    self.divider.ry = self.height - self.divider.height;
}

@end
