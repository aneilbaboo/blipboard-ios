//
//  BlipTableView.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 7/27/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

// models
#import "Blip.h"

// UI components
#import "BlipCell.h"
#import "BlipInputCell.h"
#import "BBTableProtocol.h"
@class BlipTableView;

// protocol
@protocol BlipTableViewDelegate <NSObject>

-(void)blipTableView:(BlipTableView*)blipTable didSelectChannel:(Channel*)channel;
-(void)blipTableView:(BlipTableView*)blipTable didSelectBlip:(Blip*)blip;
-(void)blipTableView:(BlipTableView*)blipTable didTapBlipComment:(Blip*)blip;

@optional
-(void)blipTableViewDidScroll:(BlipTableView *)blipTable;
@end

// main interface
@interface BlipTableView : UIView <UITableViewDataSource,UITableViewDelegate,BlipCellDelegate,BBTableProtocol> {
    UITableView *_tableView;
    NSMutableArray *_blips;
    PlaceChannel *_placeChannel;
}

@property (nonatomic,weak) id<BlipTableViewDelegate> delegate;
@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat contentOffset;
@property (nonatomic) BlipCellDisplayMode blipCellDisplayMode;
@property (nonatomic) BOOL scrollsToTop;

- (id) initWithFrame:(CGRect)frame;

- (NSArray *) blips;
- (void) setBlips:(NSArray *)blips;
- (void) updateBlip:(Blip*)blip;
- (void) reloadData;
- (void) reloadCellForBlip:(Blip *)blip;
- (void) showBlip:(Blip*)blip;
@end
