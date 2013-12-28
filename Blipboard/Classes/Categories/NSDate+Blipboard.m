//
//  NSDate+Blipboard.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 11/28/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "NSDate+Blipboard.h"
#import "NSDate+Helpers.h"

const NSTimeInterval kRelativeDateThreshold = 60*60*24*5;
@implementation NSDate (Blipboard)

-(NSString *)bbRelativeTimeBeforeNow {
    return [self bbRelativeTimeBefore:[NSDate date] timezone:[NSTimeZone localTimeZone]];
}

-(NSString *)bbRelativeTimeBefore:(NSDate *)date timezone:(NSTimeZone *)timezone {
    date = date ? date : [NSDate date];
    NSInteger yearsAgo = -[self units:NSYearCalendarUnit relativeTo:date inTimeZone:timezone];
    NSInteger daysAgo = -[self units:NSDayCalendarUnit relativeTo:date inTimeZone:timezone];
    NSInteger monthsAgo = -[self units:NSMonthCalendarUnit relativeTo:date inTimeZone:timezone];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeZone:timezone];
    
    if (abs(yearsAgo)>0) {
        [formatter setDateFormat:@"MMM d, yyyy"]; // e.g., Nov 17, 2012
        return [formatter stringFromDate:self];
    }
    else if (abs(daysAgo)>6 || abs(monthsAgo)>0) {
        [formatter setDateFormat:@"MMM d"]; // e.g., Nov 17 or Nov 5
        return [formatter stringFromDate:self];
    }
    else if (daysAgo>1) {
        [formatter setDateFormat:@"EEEE"]; // e.g., "Tuesday"
        return [formatter stringFromDate:self];
    }
    else if (daysAgo==1) {
        return @"yesterday";
    }
    else {
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                              fromDate:self toDate:date
                                               options:0];
        NSInteger hoursAgo = [components hour];
        NSInteger minutesAgo = [components minute];
        NSInteger secondsAgo = [components second];
        
        if (hoursAgo>1) {
            return [NSString stringWithFormat:@"%d hours ago", hoursAgo];
        }
        else if (hoursAgo==1) {
            return [NSString stringWithFormat:@"%d hour%@ %dm ago",
                    hoursAgo,hoursAgo==1 ? @"" : @"s", minutesAgo];
        }
        else if (minutesAgo) {
            return [NSString stringWithFormat:@"%d minute%@ ago",
                    minutesAgo,minutesAgo==1 ? @"" : @"s"];
        }
        else {
            return [NSString stringWithFormat:@"%d seconds ago", secondsAgo];
        }
    }
}@end
