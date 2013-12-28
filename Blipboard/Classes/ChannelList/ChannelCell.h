//
//  BroadcastTableViewCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"
#import "Channel.h"
#import "BBTuneInButton.h"
#import "BBCountLabel.h"

@class ChannelCell;


typedef enum {
    ChannelCellStyleGuru=0,
    ChannelCellStyleFollower=1
} ChannelCellStyle;

@protocol ChannelCellDelegate <NSObject>
@required
-(void)channelCellTuneInPressed:(ChannelCell *)cell;
@end


@interface ChannelCell : UITableViewCell
@property (nonatomic,weak) id<ChannelCellDelegate> delegate;
@property (nonatomic,weak) Channel *channel;

@property (nonatomic, weak) IBOutlet BBImageView *picture;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet BBCountLabel *count;
@property (nonatomic, weak) IBOutlet BBTuneInButton *tuneInButton;
@property (nonatomic, weak) IBOutlet UILabel *desc;
@property (nonatomic, weak) IBOutlet UIImageView *divider;
@property (nonatomic, readonly) ChannelCellStyle style;

+(NSString *)reuseIdentifier;
+(CGFloat)cellHeightFromText:(NSString *)text;
+(id)channelCellWithDelegate:(id<ChannelCellDelegate>)delegate style:(ChannelCellStyle)style;

-(void) configureWithChannel:(Channel *)channel;

@end
