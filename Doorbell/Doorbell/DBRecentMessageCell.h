//
//  DBRecentMessageCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/24/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PFObject, PFUser;
@interface DBRecentMessageCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *conversation;
@property (nonatomic, strong) IBOutlet UIView *onlineView;
@property (nonatomic) BOOL isOnline;

@end
