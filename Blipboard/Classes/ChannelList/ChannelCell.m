//
//  ChannelCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "ChannelCell.h"
#import "PlaceChannel.h"

const CGFloat kDescriptionYPos = 48;

@implementation ChannelCell {
    __weak id<ChannelCellDelegate> _delegate;
}

+(NSString *)reuseIdentifier {
    return @"ChannelCell";
}

+(id)channelCellWithDelegate:(id<ChannelCellDelegate>)delegate style:(ChannelCellStyle)style {
    
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell"
                                                    owner:nil
                                                  options:nil];
    ChannelCell *cell = [bundle objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = delegate;
    cell->_style = style;
    [cell _initStyle];
    return cell;
}

- (void)_initStyle
{
    /* 
    // !am! ??? none of these two methods set the background:
    self.backgroundColor = [UIColor blackColor]; // method 1
    self.contentView.backgroundColor = [UIColor blackColor]; // method 2
    self.backgroundView = [[UIView alloc] init];                // method 3
    self.backgroundView.backgroundColor = [UIColor blackColor];
    // instead, I'm using ChannelTableView's .backgroundColor property
    */
    
    self.name.font = [UIFont bbBoldFont:12];
    self.name.textColor = [UIColor bbWarmGray];
    self.count.textColor = [UIColor bbFadedWarmGray];
    self.count.font = [UIFont bbFont:10];
        self.desc.font = [UIFont bbBlipMessageFont];
    self.desc.textColor = [UIColor bbWarmGray];
}

+(CGFloat)textHeight:(NSString *)text {
    CGSize size = [text sizeWithFont:[UIFont bbBlipMessageFont] constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

+(CGFloat)cellHeightFromText:(NSString *)text {
    CGFloat textHeight = [self textHeight:text];
    return textHeight + kDescriptionYPos + 4;
}

//!lal! Casting the channel to PlaceChannel since we are only dealing with places
-(void) configureWithChannel:(PlaceChannel *)channel {
    //Adding the badge on the Alerts tab
    
    if (_style==ChannelCellStyleGuru) {
        self.count.singular = @"point";
        self.count.plural = @"points";
        self.count.count = channel.stats.score;
    }
    else {
        self.count.singular = @"follower";
        self.count.plural = @"followers";
        self.count.count = channel.stats.followers;
    }
    
    self.channel = channel;
    //BBLog(@"URL: %@",channel.picture);
    [self.picture setImageWithURLString:channel.picture placeholderImage:nil];
    NSString* name = [NSString stringWithFormat:@"%@", channel.name];
    self.name.text = name;
    self.tuneInButton.selected = channel.isListening;
    self.tuneInButton.hidden = [BBAppDelegate.sharedDelegate.myAccount.id isEqualToString:channel.id];
    self.desc.text = channel.desc;
    
    self.desc.height = [ChannelCell textHeight:channel.desc];
    self.divider.ry = [ChannelCell cellHeightFromText:channel.desc] - self.divider.height;
}

-(IBAction)tuneInButtonPressed:(id)sender {
    [self.delegate channelCellTuneInPressed:self];
}
@end
