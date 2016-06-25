//
//  DBChatViewCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 4/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface DBChatViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *roomLabel;
@property (nonatomic, strong) PFUser *user;

@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) IBOutlet UIView *onlineView;

@property (nonatomic) BOOL isUserActive;

@end
