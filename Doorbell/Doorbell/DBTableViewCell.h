//
//  DBTableViewCell.h
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBSDKProfilePictureView, PFUser;

@interface DBTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *profileLabel;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIView *borderView;

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) PFUser *user;


@end
