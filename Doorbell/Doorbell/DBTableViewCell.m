//
//  DBTableViewCell.m
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Parse.h"

@implementation DBTableViewCell

- (void)awakeFromNib
{
    // Initialization code

    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0f;
    self.profileImageView.clipsToBounds = YES;

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];    
}

- (void)setRequestObject:(PFObject *)requestObject
{
    _requestObject = requestObject;
    PFUser *user = requestObject[@"poster"];
    self.user = user;
    
    self.nameLabel.text = user[@"facebookName"];
    
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
    
    
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                             placeholderImage: nil
                                    completed: nil];
    
    self.messageLabel.text = [requestObject objectForKey:@"message"];
    
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [requestObject createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
    [self.messageLabel sizeToFit];


    
}

@end
