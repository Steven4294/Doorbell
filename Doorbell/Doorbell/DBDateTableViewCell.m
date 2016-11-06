//
//  DBDateTableViewCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/19/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBDateTableViewCell.h"
#import "BOTableViewCell+Subclass.h"

@implementation DBDateTableViewCell

- (void)setup
{
    [super setup];
    
    self.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d, hh:mm" options:kNilOptions locale:[NSLocale currentLocale]];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
}

@end
