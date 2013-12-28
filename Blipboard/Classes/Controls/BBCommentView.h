//
//  BlipCommentView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//
#import "BBImageView.h"
#import "Comment.h"

@class BBCommentView;

@protocol BlipCommentDelegate <NSObject>
-(void)blipCommentViewDeletePressed:(BBCommentView *)blipCommentView;
-(void)blipCommentViewAuthorPressed:(BBCommentView *)blipCommentView;
@end

@interface BBCommentView : UIView
@property (nonatomic,strong) Comment *comment;
@property (nonatomic,weak) id<BlipCommentDelegate> delegate;

@property (nonatomic,weak) IBOutlet BBImageView *authorPicture;
@property (nonatomic,weak) IBOutlet UILabel *authorName;
@property (nonatomic,weak) IBOutlet UITextView *text;
@property (nonatomic,weak) IBOutlet UILabel *createdTime;
@property (nonatomic,weak) IBOutlet UIButton *deleteButton;

+(BBCommentView *)commentViewWithComment:(Comment *)comment;

-(IBAction)authorPressed:(id)sender;
-(IBAction)leftSwipe:(id)sender;
-(IBAction)rightSwipe:(id)sender;
-(IBAction)deletePressed:(id)sender;
@end
