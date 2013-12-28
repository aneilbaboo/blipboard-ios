//
//  BBShareKitActionSheet.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 4/5/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "BBShareKitActionSheet.h"

@implementation BBShareKitActionSheet
+ (SHKActionSheet *)actionSheetForItem:(SHKItem *)item {
    SHKActionSheet *actionSheet = [super actionSheetForItem:item];
    
    actionSheet.backgroundColor = [UIColor bbGridPattern];
    return actionSheet;
}
@end
