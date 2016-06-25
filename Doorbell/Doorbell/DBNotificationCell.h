//
//  DBNotificationCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@class PFObject;

@interface DBNotificationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet KILabel *commentLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;

@property (nonatomic, strong) KILabelLinkClassifier *nameClassifier;
@property (nonatomic, strong) KILabelLinkClassifier *postClassifier;


@property (nonatomic, strong) PFObject *notificationObject;

@end
