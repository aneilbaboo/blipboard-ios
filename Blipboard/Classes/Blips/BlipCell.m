//
//  BlipCell.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//


#import "BlipCell.h"
#import "Blip.h"

@implementation BlipCell

static const NSInteger ActionBarHeight = 30;
static const NSInteger MessageWidth = 310;
//static const NSInteger MessageHeightMax = 2500;
static const NSInteger PhotoHeight = 150;
static const NSInteger PhotoWidth = 290;
static const NSInteger UnadjustedHeight = 174-55-30; // position of separator - height of text - height of image
static const NSInteger SmallPadding = 5;
static const NSInteger MediumPadding = 10;
static const NSInteger OutsidePadding = 15;

+(NSString *)reuseIdentifier {
    return @"BlipCell";
}

+(id)blipCellWithDelegate:(id<BlipCellDelegate>)delegate {

    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"BlipCell"
                                                    owner:nil
                                                  options:nil];
    BlipCell *cell = [bundle objectAtIndex:0];
    cell.delegate = delegate;
    [cell _setupStyle];
    return cell;
}


- (void)_setupStyle {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // message style
    self.message.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress | UIDataDetectorTypePhoneNumber;
    self.message.font = [UIFont bbBlipMessageFont];
    self.message.textColor = [UIColor bbWarmGray];
    self.message.scrollsToTop = NO;
    self.message.backgroundColor = [UIColor whiteColor];
    self.message.textAlignment = NSTextAlignmentLeft;
//    self.message.contentInset = UIEdgeInsetsMake(0,0,0,0);
//    self.message.contentOffset = CGPointMake(0,0);
//    
    [self.actionBar setBackgroundColor:[UIColor bbFadedWarmGray]];
    
    self.time.textColor = [UIColor bbWarmGray];
    self.likeButton.countColor = [UIColor bbWarmGray];
    self.commentButton.countColor = [UIColor bbWarmGray];
    
    // place
    [self.placeName setFont:[UIFont bbFont:12]];
    [self.placeName setTextColor:[UIColor bbWarmGray]];
    [self.placeFrame roundCorners:UIRectCornerAllCorners xRadius:2 yRadius:2];
    self.placeFrame.backgroundColor = [UIColor bbGray3];
    
    // author
    [self.authorName setFont:[UIFont bbBlipAuthorFont]];
    [self.authorName setTextColor:[UIColor bbWarmGray]];
    self.authorFrame.backgroundColor = [UIColor whiteColor];
    [self.authorFrame bbSetShadow:BlipboardShadowOptionDown
                             size:1 radius:1 opacity:.5];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)heightOfText:(NSString*)text
{
    NSString* message = text.length ? text : @" ";
    UIFont* font = [UIFont bbBlipMessageFont];
    
    return [UITextView heightWithText:message font:font width:MessageWidth];
}

+(CGFloat)heightFromBlip:(Blip *)blip {
    CGFloat imageHeight = 0;
    if (blip.sourcePhoto && blip.sourceWidth && blip.sourceHeight) {
        imageHeight = PhotoWidth * blip.sourceHeight / blip.sourceWidth;
    }
    else if (blip.photo) {
        imageHeight = PhotoHeight;
    }
    else {
        imageHeight = -MediumPadding; // adjust for no picture (removing padding)
    }
    CGFloat textHeight = [self heightOfText:blip.message];
    CGFloat height = UnadjustedHeight + imageHeight + textHeight + ActionBarHeight ;

    //BBLog(@"blipid (%@) heightFromBlip: %.0f imageHeight=%.0f textHeight=%.0f", blip.id, height, imageHeight, textHeight);
    return height ;
}


- (void)configureWithBlip:(Blip *)blip location:(CLLocation *)location mode:(BlipCellDisplayMode)mode {
    self.blip = blip;
    
    BOOL showAuthor = (mode & BlipCellDisplayModeAuthor);
    self.authorFrame.hidden = !showAuthor;
    self.authorName.hidden = !showAuthor;
    if (showAuthor) {
        [self.authorPicture setImageWithURLString:blip.author.picture placeholderImage:NULL];
        self.authorName.text = blip.author.name;
    }
    
    BOOL showPlace = (mode & BlipCellDisplayModePlace) && blip.author.type!=ChannelTypePlace;
    self.placeFrame.hidden = !showPlace;
    self.placeName.hidden = !showPlace;
    if (showPlace) {
        [self.placePicture setImageWithURLString:blip.place.picture placeholderImage:NULL];
        self.placeName.text = [NSString stringWithFormat:@"@ %@", blip.place.name];
    }
    
    [self.likeButton configureWithLikes:blip.likes];
    [self.commentButton setCount:blip.comments.count];
    
    CGFloat adjustedPhotoHeight = 0;
    if (blip.sourcePhoto) {
        self.blipPhoto.hidden = FALSE;

        if (blip.sourceHeight && blip.sourceWidth) {
            self.blipPhoto.contentMode = UIViewContentModeScaleAspectFit; 
            adjustedPhotoHeight = PhotoWidth * blip.sourceHeight/ blip.sourceWidth;
            self.blipPhoto.height = adjustedPhotoHeight;
        }
        else {
            self.blipPhoto.contentMode = UIViewContentModeScaleAspectFill;
            self.blipPhoto.clipsToBounds = YES;
        }
    
        [self.blipPhoto setImageWithURLString:blip.sourcePhoto placeholderImage:NULL];
        self.message.ry = self.blipPhoto.bottom + SmallPadding;
        ;
    }
    else if (blip.photo) {
        self.blipPhoto.hidden = FALSE;
        adjustedPhotoHeight = PhotoHeight;
        self.blipPhoto.height = adjustedPhotoHeight;
        
        self.blipPhoto.contentMode = UIViewContentModeScaleAspectFill;
        self.blipPhoto.clipsToBounds = YES;
        [self.blipPhoto setImageWithURLString:blip.photo placeholderImage:NULL];
        self.message.ry = self.blipPhoto.bottom + SmallPadding;
    }
    else {
        self.blipPhoto.hidden = TRUE;
        self.message.ry = self.authorFrame.bottom + SmallPadding;
        adjustedPhotoHeight = -MediumPadding; // offset the UITextView padding
    }

    self.message.text = blip.message;
    //self.message.height = self.message.contentSize.height; //[BlipCell heightOfText:blip.message];
    self.message.height = [BlipCell heightOfText:blip.message];
    
    // Assert, but not in Release
#if !defined CONFIGURATION_Release
    CGFloat actualHeight = [self.message sizeThatFits:CGSizeMake(MessageWidth, CGFLOAT_MAX)].height;    
    if (self.message.height != actualHeight) {
        TFLog(@"blip message height (%f) doesn't match calculated height (%f)",self.message.height,actualHeight);
        BBLog(@"blip message height (%f) doesn't match calculated height (%f)",self.message.height,actualHeight);
        assert(false);
    }
#endif
    
    // setup creation time:
    [self.time configureWithTime:blip.createdTime];
    
    self.height = UnadjustedHeight + self.message.height + adjustedPhotoHeight + ActionBarHeight;
    self.backdrop.height = self.height - self.backdrop.ry - SmallPadding;

    [self.backdrop roundCorners:UIRectCornerAllCorners xRadius:5 yRadius:5];
    [self.actionBar roundCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight xRadius:5 yRadius:5];
        
    self.actionBar.ry = self.backdrop.height - self.actionBar.height;

}

-(void)updateWithBlip:(Blip *)blip {
    // for now this method updates blip likes only, but should be able to update the contents of the whole blip without flicker and it should be used by configure with blip
    self.blip.likes = blip.likes;
    
    [self.likeButton configureWithLikes:blip.likes];
}

#pragma mark -
#pragma mark KVO
-(void)setBlip:(Blip *)blip {
    if (_blip) {
        [_blip removePropertiesObserver:self];
    }
    [self willChangeValueForKey:@"blip"];
    _blip = blip;
    [self didChangeValueForKey:@"blip"];
    if (blip) {
        [blip addPropertiesObserver:self];
    }
}

-(void)dealloc {
    self.blip = nil; // remove KVO
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object==self.blip && [keyPath isEqualToString:@"likes"]) {
        [self.likeButton configureWithLikes:self.blip.likes];
    }
    if (object==self.blip && [keyPath isEqualToString:@"comments"]) {
        [self.commentButton setCount:self.blip.comments.count];
    }
}

#pragma mark - 
#pragma mark Actions
-(IBAction)likePressed:(id)sender {
    [Flurry logEvent:kFlurryBlipCellLikePressed
               withParameters:[NSDictionary dictionaryWithObject:self.blip.id forKey:@"id"]];

    [self.delegate blipCellLikePressed:self];
}

-(IBAction)CommentPressed:(id)sender {
    [Flurry logEvent:kFlurryBlipCellCommentPressed
               withParameters:[NSDictionary dictionaryWithObject:self.blip.id forKey:@"id"]];
    [self.delegate blipCellCommentPressed:self];
}
@end
