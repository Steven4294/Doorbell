//
//  DBCommentChatCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@class PFObject, PFUser, TTTAttributedLabel;

@interface DBCommentChatCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *attributedLabel;


@property (nonatomic, strong) PFObject *comment;
@property (nonatomic, strong) PFUser *user;


@end
