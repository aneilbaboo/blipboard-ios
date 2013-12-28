//
//  ContentSegmentControl.h
//  CustomSegmentedControls
//
//  Created by Jake Foster on 8/23/12.
//
//

#import <UIKit/UIKit.h>
#import "NIBadgeView.h"

typedef enum {
    ContentSegmentDiscover = 1,
    ContentSegmentFollowing = 2,
    ContentSegmentMyBlips = 3,
    ContentSegmentNotSelected = 4
} ContentSegment;

@class ContentSegmentControl;

@protocol ContentSegmentControlDelegate <NSObject>
- (void)contentSegmentControl:(ContentSegmentControl*)control didSelectIndex:(ContentSegment)index;
- (void)contentSegmentControlPlusPressed:(ContentSegmentControl *)control;
@end


@interface ContentSegmentControl : UIView
{
    ContentSegment _selectedSegmentIndex;
}
+(ContentSegmentControl *)contentSegmentControlOnSuperview:(UIView *)view withDelegate:(id<ContentSegmentControlDelegate>)delegate;
@property (nonatomic, weak) id<ContentSegmentControlDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *plusButton;
@property (nonatomic, weak) IBOutlet UIButton *alertsBadge;
@property (nonatomic, weak) IBOutlet UIImageView *controlImage;
@property (nonatomic, weak) IBOutlet UIButton *followingButton;
@property (nonatomic, weak) IBOutlet UIButton *discoverButton;
@property (nonatomic, weak) IBOutlet UIButton *myBlipsButton;

@property (nonatomic, readonly) CGFloat barHeight; // the bar height, excluding the transparent area
@property (nonatomic) ContentSegment selectedSegmentIndex;

- (void)startPulsingButton;
- (void)stopPulsingButton;
- (void)setAlertsCount:(NSInteger)count;
- (NSInteger)alertsCount;

- (IBAction)onSegmentButtonPressed:(id)sender;
- (IBAction)onPlusPressed:(id)sender;
@end
