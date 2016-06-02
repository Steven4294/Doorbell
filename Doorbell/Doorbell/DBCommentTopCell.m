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
#import "UIImage+Resize.h"

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
    
    
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                             placeholderImage: nil
                                    completed: nil];
    
    self.messageLabel.text = [requestObject objectForKey:@"message"];
    
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [requestObject createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
    [self.messageLabel sizeToFit];
}

- (void)configureLikeLabel
{
    BOOL isUserLiker = [self.likersArray containsObject:[PFUser currentUser]];
    
    if (self.likersArray.count == 0)
    {
        self.listOfLikersLabel.text = @" ";
    }
    else
    {
        if (self.likersArray.count == 1)
        {
            NSString *string1 = [self formattedUsernameForUser:[self.likersArray objectAtIndex:0]];
            self.listOfLikersLabel.text = string1;
        }
        else if (self.likersArray.count == 2)
        {
            NSString *string1 = [self formattedUsernameForUser:[self.likersArray objectAtIndex:0]];
            NSString *string2 = [self formattedUsernameForUser:[self.likersArray objectAtIndex:1]];
            
            self.listOfLikersLabel.text = [NSString stringWithFormat:@"%@, and %@", string1, string2];
        }
        else
        {
            NSString *string1 = [self formattedUsernameForUser:[self.likersArray objectAtIndex:0]];
            NSString *string2 = [self formattedUsernameForUser:[self.likersArray objectAtIndex:1]];
            NSInteger others = self.likersArray.count - 2;
            
            self.listOfLikersLabel.text = [NSString stringWithFormat:@"%@, %@ and %ld others", string1, string2, (long)others];
        }
    }
    if (isUserLiker == YES)
    {
        self.likeLabel.text = @"Unlike";
    }
    else
    {
        self.likeLabel.text = @"Like"   ;
    }
}

- (NSString *)formattedUsernameForUser:(PFUser *)user
{
    return user[@"facebookName"];
}



@end
