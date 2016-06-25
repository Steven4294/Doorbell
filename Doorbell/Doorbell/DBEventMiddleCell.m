//
//  DBEventMiddleCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventMiddleCell.h"
#import "Parse.h"
#import "DBLabel.h"

@implementation DBEventMiddleCell

-(void)setEvent:(PFObject *)event
{
    _event = event;
    
    self.eventDescription.text = event[@"eventDescription"];
    self.eventDescription.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.eventDescription.layer.borderWidth = 10.0f;
    self.eventDescription.edgeInsets = UIEdgeInsetsMake(10.0, 10.0+3.0, 10.0, 10.0+3.0);
    
    [event[@"eventImage"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         [self.eventImage setImage:[UIImage imageWithData:data]];
     }];
}

@end
