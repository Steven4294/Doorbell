//
//  DBPerkCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/25/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface DBPerkCell : UITableViewCell

@property (nonatomic, strong) PFObject *deal;
@property (nonatomic, strong) IBOutlet UIImageView *dealImageView;

@property (nonatomic, strong) IBOutlet UILabel *topLabel;
@property (nonatomic, strong) IBOutlet UILabel *bottomLabel;


@end
