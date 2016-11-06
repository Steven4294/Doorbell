//
//  DBEventTopCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventTopCell.h"
#import "Parse.h"
#import "NSDate+DateTools.h"

@implementation DBEventTopCell

- (void)setEvent:(PFObject *)event
{
    _event = event;
    
    // configure the view
    self.titleLabel.text = event[@"eventTitle"];
    self.titleLabel.userInteractionEnabled = YES;
   // self.creatorLabel.text = [NSString stringWithFormat:@"Created by %@", event[@"creator"][@"facebookName"]];
    
    PFUser *creator = event[@"creator"];
    
    self.locationLabel.text = event[@"locationString"];
    
    NSDate *startTime = event[@"startTime"];
    NSDate *endTime = event[@"endTime"];
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateStyle:NSDateFormatterMediumStyle];
    [monthFormatter setDateFormat:@"MMM"];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEEE"];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterShortStyle];
    [timeFormatter setDateFormat:@"h:mm a"];
    [timeFormatter setAMSymbol:@"am"];
    [timeFormatter setPMSymbol:@"pm"];
    
    NSString *month = [monthFormatter stringFromDate:startTime];
    NSString *dayOfTheWeek = [dayFormatter stringFromDate:startTime];
    NSInteger day = [startTime day];
    NSString *startHour = [timeFormatter stringFromDate:startTime];
    NSString *endHour = [timeFormatter stringFromDate:endTime];
    
    self.monthLabel.text = [month uppercaseString];
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@ %ld\n%@ to %@", dayOfTheWeek, month, (long) day, startHour, endHour];

}

@end
