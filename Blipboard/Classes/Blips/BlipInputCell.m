//
//  BlipInputCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 6/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BlipInputCell.h"
#import "BBLog.h"

static const CGFloat kVerticalPadding = 25;
static const CGFloat kTextInputWidth = 228;

@implementation BlipInputCell

+(CGFloat)textInputHeight:(NSString *)text ifEditing:(BOOL)editing {
    CGFloat height = 26;
    if (editing) {
        text = text.length>0 ? text : @"x"; // if no text, calculate height of 1 letter
        CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:15]
                       constrainedToSize:CGSizeMake(kTextInputWidth, 9999) 
                           lineBreakMode:UILineBreakModeWordWrap];

        height += size.height;
    }
    return height;
}

+(CGFloat)cellHeightWithText:(NSString *)text ifEditing:(BOOL)editing {
        
    return [BlipInputCell textInputHeight:text ifEditing:editing]+kVerticalPadding;
    
}

+(CGFloat)defaultCellHeight {
    return [BlipInputCell cellHeightWithText:@"x" ifEditing:NO];
}

-(CGFloat)cellHeight {
    CGFloat height = [BlipInputCell cellHeightWithText:self.textView.text ifEditing:self.isEditing];
    return  height;
}

-(void)updateHeight {
    [_blipTableView beginUpdates];
    NSString *text = self.textView.text;
    CGFloat height = [BlipInputCell cellHeightWithText:text ifEditing:self.isEditing];
    CGFloat textInputHeight = [BlipInputCell textInputHeight:text ifEditing:self.isEditing];
    self.textInputEdge.frame = CGRectMake(52, 17, 243, textInputHeight);
    self.textView.frame = self.textInputEdge.frame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            320,
                            height);
    self.cellBackdrop.frame = CGRectMake(0, 0, 320, height);
    self.separator.frame = CGRectMake(5,height-3,320,2);
    
    [_blipTableView endUpdates];
}

-(void)enterEditMode {
    self.isEditing = YES;
    self.placeholderText.hidden = YES;
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
    [self updateHeight];
}

-(void)exitEditMode {
    self.isEditing = NO;
    self.placeholderText.hidden = NO;
    self.textView.hidden = YES;
    [self.textView resignFirstResponder];
    [self updateHeight];
}

-(void)reset {
    self.textView.text = @"";
    [self exitEditMode];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(id)cellWithOwner:(id<BlipInputCellDelegate>)owner tableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier andPictureURL:(NSString *)pictureURL  
{
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"BlipInputCell" 
                                                    owner:owner 
                                                  options:nil];
    BlipInputCell *cell = [bundle objectAtIndex:0];
    cell->_customReuseIdentifier = reuseIdentifier;
    cell.delegate = owner;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImage *textEdgeImage = [[UIImage imageNamed:@"textField.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    cell.textInputEdge.image = textEdgeImage;
    [cell styleAs:reuseIdentifier];
    [cell updateHeight];
    cell->_blipTableView = tableView;
    [cell.picture setImageWithURLString:pictureURL placeholderImage:nil];
    cell.textView.delegate = cell;
    cell.textView.scrollsToTop = NO;

    return cell;
}

- (void)styleAs:(NSString *)reuseIdentifier {
    UIImage *backgroundImage;
    CGRect  frame;
    if ([reuseIdentifier isEqualToString:@"InputFirst"]) {
        backgroundImage = [[UIImage imageNamed:@"whiteCellTop.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        frame = CGRectMake(0, -5, 
                           self.frame.size.width,
                           self.frame.size.height+5);
    }
    else if ([reuseIdentifier isEqualToString:@"InputOnly"]) {
        backgroundImage = [[UIImage imageNamed:@"whiteCellOnly.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        frame = CGRectMake(0, 0, 
                           self.frame.size.width, 
                           self.frame.size.height);
        self.separator.hidden = YES;
    }
    else {
        NSAssert(false,@"BlipInputCell reuseIdentifier must be one of InputFirst, InputOnly");
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = backgroundImage;
    self.cellBackdrop = imageView;
    [self insertSubview:imageView atIndex:0];
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self enterEditMode];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateHeight];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.delegate blipInputCell:self enteredBlip:self.textView.text];
        [self exitEditMode];
        return NO;
    }
    else {
        return YES;
    }
}

@end
