//
//  DBCommentTopCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBCommentTopCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Parse.h"
#import "UIImageView+Profile.h"
#import "KILabel.h"

@implementation DBCommentTopCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    // Initialization code
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0f;
    self.profileImageView.clipsToBounds = YES;

}

-(void)setRequestObject:(PFObject *)requestObject
{
    _requestObject = requestObject;
    PFUser *user = requestObject[@"poster"];
    self.user = user;
    
    self.nameLabel.text = user[@"facebookName"];
    
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
    
    
    
    [self.profileImageView setProfileImageViewForUser:user isCircular:YES];
    self.messageLabel.text = [requestObject objectForKey:@"message"];
    
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [requestObject createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
    [self.messageLabel sizeToFit];
}

- (NSString *)formattedUsernameForUser:(PFUser *)user
{
    return user[@"facebookName"];
}



@end
