//
//  BroadcastPlaceCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/30/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"
#import "Channel.h"



@interface BroadcastPlaceCell : UITableViewCell 

@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UILabel *name;
@property (nonatomic,weak) IBOutlet UILabel *address;
@property (nonatomic,weak) IBOutlet UILabel *tuneInCount;
@property (nonatomic,weak) IBOutlet UILabel *tuneInCountLabel;
@property (nonatomic,weak) IBOutlet UIImageView *divider;

@property (nonatomic,weak) Channel *channel;



+(id)broadcastPlaceCell;
+(NSString *)reuseIdentifier;
-(void) configureWithChannel:(Channel *)channel;
@end
