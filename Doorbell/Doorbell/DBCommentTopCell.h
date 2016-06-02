//
//  DBCommentTopCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser, PFObject;

@interface DBCommentTopCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *profileLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) IBOutlet UILabel *listOfLikersLabel;
@property (nonatomic, strong) IBOutlet UIView *borderView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) PFUser *user;

// message object that can be used to create all of the labels
@property (nonatomic, strong) PFObject *requestObject;
@property (nonatomic, strong) NSMutableArray *likersArray;

- (void)configureLikeLabel;

@end
