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
#import "Doorbell-Swift.h"
#import "KILabel.h"

@class PFUser, PFObject;

@interface DBTableViewCell : SESlideTableViewCell

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *profileLabel;
@property (nonatomic, strong) IBOutlet KILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentLabel;
@property (nonatomic, strong) IBOutlet UILabel *listOfLikersLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

@property (nonatomic, strong) PFUser *user;

// message object that can be used to create all of the labels
@property (nonatomic, strong) PFObject *requestObject;
@property (nonatomic, strong) NSMutableArray *likersArray;

@property (nonatomic, strong) KILabelLinkClassifier *classifier;

- (void)configureLikeLabelWithInteger:(int)numberOfLikers;

@end
