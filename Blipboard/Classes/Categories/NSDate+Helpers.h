//
//  NSDate+Helpers.h
//  Blipboard
//
//  Created by Aneil Mallavarapu on 5/12/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helpers)
-(NSInteger)units:(NSCalendarUnit)unit relativeTo:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone;
@end
