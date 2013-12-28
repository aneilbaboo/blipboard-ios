//
//  BlipsSegmentControl.m
//  CustomSegmentedControls
//
//  Created by Jake Foster on 8/23/12.
//
//

#import "ContentSegmentControl.h"

const NSInteger ContentSegmentControlHeight = 55;
@implementation ContentSegmentControl {
    BOOL _isPulsing;
}

@dynamic selectedSegmentIndex;

+(ContentSegmentControl *)contentSegmentControlOnSuperview:(UIView *)view withDelegate:(id<ContentSegmentControlDelegate>)delegate {
    ContentSegmentControl *csc = [ContentSegmentControl _loadControl];
    [csc _initControl];
    
    csc.frame = CGRectMake(0, view.height-ContentSegmentControlHeight,
                           view.width, ContentSegmentControlHeight);
    [view addSubview:csc];
    csc.delegate = delegate;
    return csc;
}

+(ContentSegmentControl *)_loadControl
{
    ContentSegmentControl *newObj = [[[NSBundle mainBundle] loadNibNamed:@"ContentSegmentControl" owner:nil options:nil] objectAtIndex:0];
    return newObj;
}

-(void)_initControl {
    [self _showSelected:self.discoverButton];
    self.selectedSegmentIndex = ContentSegmentNotSelected;
    
    // style the alerts badge
    [_alertsBadge.titleLabel setFont:[UIFont bbCondensedBoldFont:11]];
    _alertsBadge.hidden = YES;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
}

- (CGFloat)barHeight {
    return self.followingButton.height;
}

- (void) startPulsingButton {
    @synchronized (self) {
        if (!_isPulsing) {
            _isPulsing = YES;
            CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform"];
            pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pulse.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            pulse.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1)];
            pulse.duration = 1.5;
            pulse.removedOnCompletion = YES;
            pulse.repeatCount = 9999999999;
            pulse.autoreverses =YES;
            [self.plusButton.layer addAnimation:pulse forKey:@"pulse"];
        }
    }
}

-(void)stopPulsingButton {
    @synchronized (self) {
        if (_isPulsing) {
            _isPulsing = NO;
            [self.plusButton.layer removeAnimationForKey:@"pulse"];
        }
    }
}
- (ContentSegment)selectedSegmentIndex
{
    return _selectedSegmentIndex;
}

- (void)setSelectedSegmentIndex:(ContentSegment)index
{
    if (index != _selectedSegmentIndex) {
        if ( index == ContentSegmentFollowing) {
            [self _showSelected:self.followingButton];
        }
        else if ( index == ContentSegmentDiscover) {
            [self _showSelected:self.discoverButton];
        }
        else if ( index == ContentSegmentMyBlips) {
            [self _showSelected:self.myBlipsButton];
        }
    }
}

- (NSInteger)alertsCount {
    return  [self.alertsBadge.titleLabel.text integerValue];
}

- (void)setAlertsCount:(NSInteger)count {
    if(count) {
        self.alertsBadge.hidden = NO;
        [self.alertsBadge setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateDisabled];
//        [_alertsBadge sizeToFit];
    }
    else {
        self.alertsBadge.hidden = YES;
    }
}

- (IBAction)onSegmentButtonPressed:(id)sender
{
    // !JKF! TODO: Not sure why the delegate call got commented out and moved into the
    //  styling method.
    if( self.delegate != nil )
    {
        if( sender == self.followingButton )
        {
            [Flurry logEvent:kFlurryContentFollowing];
            self.selectedSegmentIndex = ContentSegmentFollowing;
            //[self.delegate contentSegmentControl:self touchDown:BlipsSegmentedControlDelegate_TouchDown_All];
        }
        else if( sender == self.discoverButton )
        {
            [Flurry logEvent:kFlurryContentDiscover];
            self.selectedSegmentIndex = ContentSegmentDiscover;
            //[self.delegate contentSegmentControl:self touchDown:BlipsSegmentedControlDelegate_TouchDown_Popular];
        }
        else if( sender == self.myBlipsButton )
        {
            [Flurry logEvent:kFlurryContentMyBlips];
            self.selectedSegmentIndex = ContentSegmentMyBlips;
            //[self.delegate contentSegmentControl:self touchDown:BlipsSegmentedControlDelegate_TouchDown_Me];
        }
    }
}

- (IBAction)onPlusPressed:(id)sender {
    if (self.delegate != nil) {
        [self.delegate contentSegmentControlPlusPressed:self];
    }
}

-(void)_showSelected:(UIButton*)button
{
    self.followingButton.selected = button ==self.followingButton;
    self.discoverButton.selected = button==self.discoverButton;
    self.myBlipsButton.selected = button==self.myBlipsButton;
    
    if( button == self.followingButton )
    {
        _selectedSegmentIndex = ContentSegmentFollowing;
        [self.controlImage setImage:[UIImage imageNamed:@"tabBar_following.png"]];
    }
    else if( button == self.discoverButton )
    {
        _selectedSegmentIndex = ContentSegmentDiscover;
        [self.controlImage setImage:[UIImage imageNamed:@"tabBar_discover.png"]];
    }
    else if( button == self.myBlipsButton )
    {
        _selectedSegmentIndex = ContentSegmentMyBlips;
        [self.controlImage setImage:[UIImage imageNamed:@"tabBar_me.png"]];
    }
    
    BBLog(@"Content Segment selected: %u", _selectedSegmentIndex);
    
    // !JKF! TODO: Not sure why this control logic is in a method dedicated to
    //  styling.
    if (self.delegate) {
        [self.delegate contentSegmentControl:self didSelectIndex:_selectedSegmentIndex];
    }
}
@end
