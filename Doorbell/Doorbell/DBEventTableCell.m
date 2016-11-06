//
//  DBEventTableCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/22/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventTableCell.h"
#import "Parse.h"
#import "NSDate+DateTools.h"
#import "DBLabel.h"

@implementation DBEventTableCell

- (void)setEvent:(PFObject *)event
{
    _event = event;
    
    self.eventTitle.text = event[@"eventTitle"];
    self.eventDescription.text = event[@"eventDescription"];
    
    [event[@"eventImage"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         [self.eventImage setImage:[UIImage imageWithData:data]];
     }];
    
    // TODO: configure the date labels...

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
    
    self.eventDescription.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.eventDescription.layer.borderWidth = 10.0f;
    
    self.eventDescription.edgeInsets = UIEdgeInsetsMake(10.0, 10.0+3.0, 10.0, 10.0+3.0);
    
    if ([startTime compare:[NSDate date]] == NSOrderedAscending)
    {
        self.occurredView.hidden = NO;
    }
    else
    {
        self.occurredView.hidden = YES;
    }
}

@end
