//
//  DBBuildingCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/27/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBuildingCell.h"
#import "Parse.h"

@implementation DBBuildingCell

-(void)setBuildingObject:(PFObject *)buildingObject
{
    _buildingObject = buildingObject;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.name.text = buildingObject[@"name"];
    self.phoneNumber.text = buildingObject[@"phoneNumber"];
    self.titleLabel.text = buildingObject[@"title"];
}

@end
