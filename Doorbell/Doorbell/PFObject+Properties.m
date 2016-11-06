//
//  PFObject+Properties.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/26/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "PFObject+Properties.h"

@implementation PFObject (Properties)

- (NSDate *)openingTimeAsDate
{
    if ([[self parseClassName] isEqualToString:@"Deal"])
    {
        NSString *timeAsString = [self openingTimeAsString];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm a"];
        NSDate * date = [dateFormatter dateFromString:timeAsString];
        return date;
    }
    else
    {
        return nil;
    }
}

- (NSDate *)closingTimeAsDate
{
    if ([[self parseClassName] isEqualToString:@"Deal"])
    {
        NSCalendar *calendar=[NSCalendar currentCalendar];
        NSDateComponents *componentsDate = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
        
        NSString *timeAsString = [self closingTimeAsString];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm a"];
        NSDate *date= [dateFormatter dateFromString:timeAsString];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
        [componentsDate setHour:components.hour];
        [componentsDate setMinute:components.minute];
        
        NSDate *finalDate = [calendar dateFromComponents:componentsDate];

        return finalDate;
    }
    else
    {
        return nil;
    }
}

- (NSString *)openingTimeAsString
{
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents* comp = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSUInteger index = [comp weekday] - 1;
    NSArray *timesArray = self[@"startTimes"];
    NSString *timeAsString = [timesArray objectAtIndex:index];
    return timeAsString;
}

- (NSString *)closingTimeAsString
{
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents* comp = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSUInteger index = [comp weekday] - 1;
    NSArray *timesArray = self[@"endTimes"];
    NSString *timeAsString = [timesArray objectAtIndex:index];
    return timeAsString;
}

- (BOOL)isBusinessOpen
{
    NSDate *currentDate = [NSDate date];
    NSDate *closingDate = [self closingTimeAsDate];
    
    NSLog(@"%@ vs %@", currentDate, closingDate);
        return NO;
}

@end
