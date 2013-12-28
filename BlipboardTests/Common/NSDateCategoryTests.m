//
//  NSDateCategoryTests.m
//  Blipboard
//
//  Created by Aneil Mallavarapu on 1/4/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import "NSDateCategoryTests.h"
#import "NSDate+Blipboard.h"
@implementation NSDateCategoryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

-(NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMM y hh:mm a zzz"]; // eg, "8 Jun 2011 11:58 pm EDT"
    return [dateFormatter dateFromString:string];
}

-(NSTimeZone *)PST {
    return [NSTimeZone timeZoneWithAbbreviation:@"PST"];
}

-(NSTimeZone *)GMT {
    return [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
}

-(NSTimeZone *)MST {
    return [NSTimeZone timeZoneWithAbbreviation:@"MST"];
}

- (void)testbbRelativeTimeJustBeforeMidnite {
    NSDate *d1 = [self dateFromString:@"4 Jan 2013 11:58 pm PST"];
    NSDate *d2 = [self dateFromString:@"5 Jan 2013 12:00 am PST"];
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self PST]],
                         @"yesterday",
                         @"2 minutes before midnite in PST is consider yesterday compared to midnite the next day");
    
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self GMT]],
                         @"2 minutes ago",
                         @"2 dates straddling midnite with 2 minute interval is the same day in GMT.");
}

- (void)testbbRelativeTimeWithinTheLastWeek {
    NSDate *d1 = [self dateFromString:@"3 Jan 2013 11:58 pm PST"]; // a Thursday
    NSDate *d2 = [self dateFromString:@"5 Jan 2013 12:00 am PST"]; // Saturday morning

    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self PST]],
                         @"Thursday",
                         @"Just before midnite on Thursday is 2 days before Saturday at midnite, so 'Thursday' should be returned.");
    
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self MST]],
                         @"yesterday",
                         @"In MST, '3 Jan 2013 11:58 pm PST' should be 'yesterday' with respect to '5 Jun 2013 12:00 am PST'");

}

- (void)testbbRelativeTime7DaysBefore {
    NSDate *d1 = [self dateFromString:@"3 Jan 2013 11:58 pm PST"]; // a Thursday in January
    NSDate *d2 = [self dateFromString:@"11 Jan 2013 12:00 am PST"]; // Friday more than 6 days later
    
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self PST]],
                         @"Jan 3",
                         @"> 6 days before the second date (in the same year) should by 'Jan 3'.");
    
    // in MST, these dates are Friday Jan 4 and Friday Jan 11th
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self MST]],
                         @"Jan 4",
                         @"In MST, '3 Jan 2013 11:58 pm PST' is Jan 2 MST");
    
}


- (void)testbbRelativeTimeLastYear {
    NSDate *d1 = [self dateFromString:@"31 Dec 2012 11:58 pm PST"]; // 2 minutes before New Years Eve
    NSDate *d2 = [self dateFromString:@"1 Jan 2013 12:00 am PST"]; // The new year
    
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self PST]],
                         @"Dec 31, 2012",
                         @"In the previous year should be written as full date month, year");
    
    // in MST, these dates are Friday Jan 3 and Friday Jan 11th
    STAssertEqualObjects([d1 bbRelativeTimeBefore:d2 timezone:[self MST]],
                         @"2 minutes ago",
                         @"In MST 31 Dec 2012, 11:58 PST and 1 Jan 2013 12:00am PST are both in the new year");
    
}

@end
