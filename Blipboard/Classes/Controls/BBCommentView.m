//
//  BlipCommentView.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/25/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBCommentView.h"

static const CGFloat MessageWidth=240;
static const CGFloat MessageHeightMax=500;

@implementation BBCommentView

+(BBCommentView *)commentViewWithComment:(Comment *)comment {
    BBCommentView *commentView = [[[NSBundle mainBundle] loadNibNamed:@"BBCommentView" owner:nil options:nil] objectAtIndex:0];
    [commentView _configureWithComment:comment];
    [commentView _setupStyle];
    return commentView;
}

-(void)_setupStyle {
    self.authorName.font = [UIFont bbBoldFont:12];

    self.authorPicture.layer.borderColor = [UIColor bbWarmGray].CGColor;
    self.authorPicture.layer.borderWidth = 1;
    self.authorPicture.layer.cornerRadius = 3;
    self.authorPicture.backgroundColor = [UIColor clearColor];
    self.authorPicture.layer.masksToBounds = YES;
    self.text.font = [UIFont bbBlipMessageFont];
    self.text.textColor = [UIColor bbWarmGray];
    self.createdTime.font = [UIFont bbMessageFont:8];
    self.createdTime.textColor = [UIColor bbGray3];
}
                            
+(CGFloat)heightOfText:(NSString*)text {
    NSString* message = text.length ? text : @" ";
    UIFont* font = [UIFont bbBlipMessageFont];
    
    return [UITextView heightWithText:message font:font width:MessageWidth];
}

-(void)_configureWithComment:(Comment *)comment {
    _comment = comment;
    CGFloat recommendedHeight = [BBCommentView heightOfText:self.comment.text];
    self.text.height = recommendedHeight;
    self.text.text = comment.text;
    
#if !defined CONFIGURATION_Release
    assert(recommendedHeight == self.text.height);
#endif
    
    [self.authorPicture setImageWithURLString:comment.author.picture placeholderImage:nil];
    self.authorName.text = comment.author.name;
    [self.authorName sizeToFit];

    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.createdTime.text = [comment.createdTime bbRelativeTimeBeforeNow];
    self.createdTime.rx = self.authorName.right + 5;
    
    self.height = self.text.bottom + 5;


}

-(IBAction)deletePressed:(id)sender {
    [self.delegate blipCommentViewDeletePressed:self];
}

-(IBAction)leftSwipe:(id)sender {
    self.deleteButton.hidden = NO;
}

-(IBAction)rightSwipe:(id)sender {
    self.deleteButton.hidden = YES;
}

-(IBAction)authorPressed:(id)sender {
    [self.delegate blipCommentViewAuthorPressed:self];
}
@end
