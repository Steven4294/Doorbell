//
//  DBCommentChatCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBCommentChatCell.h"
#import "Parse.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+Profile.h"
#import "UIColor+FlatColors.h"
#import "FRHyperLabel.h"
#import "NSString+Utils.h"

@implementation DBCommentChatCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialization code
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0f;
    self.profileImageView.clipsToBounds = YES;
}

-(void)setComment:(PFObject *)comment
{
    
    _comment = comment;
    PFUser *user = comment[@"poster"];
    self.user = user;
    
    NSString *userName = [user[@"facebookName"] firstName];
    NSString *messageBody = comment[@"commentString"];
    
    UIColor *blueColor = [UIColor flatBelizeHoleColor];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", userName, messageBody]];
    
   // [attrStr addAttributes:@{NSForegroundColorAttributeName: blueColor, NSFontAttributeName: font} range:NSMakeRange(0, userName.length+1)];
    self.messageLabel.attributedText = [attrStr copy];
    
    [self.profileImageView setProfileImageViewForUser:user isCircular:YES];

    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [comment createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
   // [self.messageLabel sizeToFit];
    

}

@end
