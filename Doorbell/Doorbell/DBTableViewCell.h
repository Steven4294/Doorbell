//
//  DBTableViewCell.h
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

/*
 *  Cell used for the feed
 */

#import <UIKit/UIKit.h>
#import "SESlideTableViewCell.h"

@class FBSDKProfilePictureView, PFUser, PFObject
;

@interface DBTableViewCell : SESlideTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *profileLabel;

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UIView *borderView;

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) PFUser *user;

// message object that can be used to create all of the labels
@property (nonatomic, strong) PFObject *requestObject;


@end
