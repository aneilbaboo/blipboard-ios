//
//  BlipCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"
#import "Blip.h"
#import "Channel.h"
#import "BBLikeButton.h"
#import "BBCommentButton.h"
#import "BBInfoText.h"

@class BlipCell;

typedef enum {
    BlipCellDisplayModeAuthor = 1<<0, // only show author
    BlipCellDisplayModePlace = 1<<1, // only show place
    BlipCellDisplayModeBoth = BlipCellDisplayModeAuthor | BlipCellDisplayModePlace
} BlipCellDisplayMode;

@protocol BlipCellDelegate <NSObject>

@required
-(void)blipCell:(BlipCell *)cell channelPressed:(Channel *)channel;
-(void)blipCellLikePressed:(BlipCell *)cell;
-(void)blipCellCommentPressed:(BlipCell *)cell;
@end

@interface BlipCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *backdrop;
@property (nonatomic,weak) IBOutlet UILabel *authorName;
@property (nonatomic,weak) IBOutlet UIView *authorFrame;
@property (nonatomic,weak) IBOutlet BBImageView *authorPicture;
@property (nonatomic,weak) IBOutlet UILabel *placeName;
@property (nonatomic,weak) IBOutlet UIView *placeFrame;
@property (nonatomic,weak) IBOutlet BBImageView *placePicture;
@property (nonatomic,weak) IBOutlet UITextView *message;
@property (nonatomic,weak) IBOutlet BBImageView *blipPhoto;

// actionbar
@property (nonatomic,weak) IBOutlet UIView *actionBar;
@property (nonatomic,weak) IBOutlet BBInfoText *time;
@property (nonatomic,weak) IBOutlet BBLikeButton *likeButton;
@property (nonatomic,weak) IBOutlet BBCommentButton *commentButton;
    
@property (nonatomic,weak) Blip *blip;
@property (nonatomic,weak) id<BlipCellDelegate> delegate;
@property (nonatomic,readonly, copy) NSString *reuseIdentifier;

- (void)configureWithBlip:(Blip *)blip location:(CLLocation *)location mode:(BlipCellDisplayMode)mode;
- (void)updateWithBlip:(Blip *)blip;

+(CGFloat)heightFromBlip:(Blip *)blip;
+(NSString *)reuseIdentifier;
+(id)blipCellWithDelegate:(id<BlipCellDelegate>)delegate;
-(IBAction)likePressed:(id)sender;
@end
