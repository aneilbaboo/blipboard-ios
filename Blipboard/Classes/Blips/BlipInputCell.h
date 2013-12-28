//
//  BlipInputCell.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBImageView.h"

@class BlipInputCell;

@protocol BlipInputCellDelegate <NSObject> 
@required
- (void)blipInputCell:(BlipInputCell *)cell enteredBlip:(NSString *)message;
@end

@interface BlipInputCell : UITableViewCell <UITextViewDelegate> {
    @private
    UITableView __weak *_blipTableView;
}
@property (nonatomic,weak) IBOutlet UIImageView *cellBackdrop;
@property (nonatomic,weak) IBOutlet BBImageView *picture;
@property (nonatomic,weak) IBOutlet UIImageView *separator;
@property (nonatomic,weak) IBOutlet UILabel *placeholderText;

@property (nonatomic,readonly, copy) NSString *reuseIdentifier;
@property (nonatomic,weak) id<BlipInputCellDelegate> delegate;
@property (nonatomic,weak) IBOutlet UIImageView *textInputEdge;
@property (nonatomic,weak) IBOutlet UITextView *textView;

@property (nonatomic) BOOL isEditing;

+(id)cellWithOwner:(id<BlipInputCellDelegate>)owner tableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier andPictureURL:(NSString *)pictureURL ;
+ (CGFloat)defaultCellHeight;
- (CGFloat)cellHeight;
- (void)enterEditMode;
- (void)exitEditMode;
- (void)reset;
@end
