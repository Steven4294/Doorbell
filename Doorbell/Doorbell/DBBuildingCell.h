//
//  DBBuildingCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/27/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject;
@interface DBBuildingCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumber;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) PFObject *buildingObject;

@end
