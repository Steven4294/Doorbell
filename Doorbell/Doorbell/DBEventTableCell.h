//
//  DBEventTableCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/22/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject, DBLabel;

@interface DBEventTableCell : UITableViewCell

@property (nonatomic, strong) PFObject *event;

// IBOutlets

@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UILabel *dayLabel;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) IBOutlet UILabel *eventTitle;
@property (nonatomic, strong) IBOutlet DBLabel *eventDescription;

@property (nonatomic, strong) IBOutlet UIImageView *eventImage;


@end
