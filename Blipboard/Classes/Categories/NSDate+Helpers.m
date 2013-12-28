//
//  NSDate+Helpers.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 5/12/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "NSDate+Helpers.h"
@implementation NSDate(Helpers)

/** Correctly calculates how many years, months or days to another date,
 *  respecting the timezone (e.g., Tuesday 11:59p and Wednesday 12:01a are 1 day
 *  apart in one timezone, but represent the same day in another timezone
 *
 *  Returns positive values if date is before self, negative values otherwise.
 */
-(NSInteger)units:(NSCalendarUnit)unit relativeTo:(NSDate *)date inTimeZone:(NSTimeZone *)timeZone  {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:timeZone ? timeZone : [NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    date = date ? date : [NSDate date];
    
    NSDateComponents *selfC = [gregorian components:unit fromDate:self];
    NSDateComponents *dateC = [gregorian components:unit fromDate:date];
    
    switch (unit) {
        case NSDayCalendarUnit:
            return [selfC day] - [dateC day];
            
        case NSYearCalendarUnit:
            return  [selfC year] - [dateC year];
            
        case NSMonthCalendarUnit:
            return [selfC month] - [dateC month];
            
        case NSWeekCalendarUnit:
            return [selfC week] - [dateC week];
            
        case NSWeekdayCalendarUnit:
            return [selfC weekday] - [dateC weekday];
            
            // !am! these don't do anything more than a simple calculation
            //      of the epochal time difference, but are provided for completeness
        case NSHourCalendarUnit:
            return [selfC hour] - [dateC hour];
            
        case NSMinuteCalendarUnit:
            return [selfC minute] - [dateC minute];
            
        case NSSecondCalendarUnit:
            return [selfC second] - [dateC second];
            
        default:
            NSAssert(false, @"Expecting a single NSCalendarUnit enum value for unit");
            return 0;
    }
}

@end
//
//static const NSUInteger Minute=60;
//static const NSUInteger Hour=Minute*60;
//static const NSUInteger Day=Hour*24;
//static const NSUInteger Week=Day*7;
//static const NSUInteger Month=Day*30;
//static const NSUInteger Year=Day*365;
//
//NSString *pluralize(NSString *singular,NSString *plural,CGFloat seconds,CGFloat interval,NSInteger precision);
//NSString *phrase(NSString *pastFormat,NSString *futureFormat, NSString *singular,NSString *plural,CGFloat seconds,CGFloat interval,NSInteger precision);
//
//NSString *phrase(NSString *pastFormat,NSString *futureFormat, NSString *singular,NSString *plural,CGFloat seconds,CGFloat interval,NSInteger precision) {
//    NSString *pluralized = pluralize(singular, plural, abs(seconds), interval, precision);
//    if (pluralized) {
//        if (seconds<0) {
//            // in the past
//            return [NSString stringWithFormat:pastFormat,pluralized];
//        }
//        else {
//            return [NSString stringWithFormat:futureFormat,pluralized];
//        }
//    }
//    else {
//        return nil;
//    }
//}
//
//NSString *pluralize(NSString *singular,NSString *plural,CGFloat seconds,CGFloat interval,NSInteger precision) {
//    CGFloat units = seconds/interval;
//    NSInteger roundedUnits = (NSInteger)(units+.5);
//    if (roundedUnits>1) {
//        NSString *formatStr = [NSString stringWithFormat:@"%%.%df %%@",precision];
//        return [NSString stringWithFormat:formatStr,units,plural];
//    }
//    else if (roundedUnits==1) {
//        return [NSString stringWithFormat:@"%d %@",(NSInteger)units,singular];
//    }
//    else {
//        return nil;
//    }
//}
//
//@implementation NSDate (Helpers)
//
///** Displays the "time ago" up until it is more than a threshold number of seconds from the current time (in future or past)
// *
// */
//-(NSString *)roundedTimeSinceNowThreshold:(NSTimeInterval)threshold format:(NSDateFormatter *)formatter withPrecision:(NSInteger)precision {
//    if (abs(self.timeIntervalSinceNow)>threshold) {
//        return [formatter stringFromDate:self]; 
//    }
//    else {
//        return [self roundedTimeSinceNowWithPrecision:precision];
//    }
//}
//
//-(NSString *)roundedTimeSinceNow {
//    return [self roundedTimeSinceNowWithPrecision:0];
//}
//
//-(NSString *)roundedTimeSinceNowWithPrecision:(NSInteger)precision {
//    NSTimeInterval seconds = [self timeIntervalSinceNow];
//    NSString *pastFormat = @"%@ ago";
//    NSString *futureFormat = @"in %@";
//    
//    NSString *result;
//    
//    result = phrase(pastFormat, futureFormat, @"year", @"years", seconds, Year,precision);
//    if (result) {
//        return result;
//    }
//    
//    result = phrase(pastFormat, futureFormat, @"month", @"months", seconds, Month,precision);
//    if (result) {
//        return result;
//    }
//    
//    result = phrase(pastFormat, futureFormat, @"week", @"weeks", seconds, Week,precision);
//    if (result) {
//        return result;
//    }
//    
//    result = phrase(pastFormat, futureFormat, @"day", @"days", seconds, Day,precision);
//    if (result) {
//        return result;
//    }
//    
//
//    result = phrase(pastFormat, futureFormat, @"hour", @"hours", seconds, Hour,precision);
//    if (result) {
//        return result;
//    }
//    
//    result = phrase(pastFormat, futureFormat, @"minute", @"minutes", seconds, Minute, precision);
//    if (result) {
//        return result;
//    }
//    
//    result = phrase(pastFormat, futureFormat, @"second", @"seconds", seconds, 1, precision);
//    if (result) {
//        return result;
//    }
//    else {
//        return @"now";
//    }
//}
//@end
