//
//  NSDate+Blipboard.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Blipboard)
-(NSString *)bbRelativeTimeBeforeNow;
-(NSString *)bbRelativeTimeBefore:(NSDate *)date timezone:(NSTimeZone *)timezone; 
@end
