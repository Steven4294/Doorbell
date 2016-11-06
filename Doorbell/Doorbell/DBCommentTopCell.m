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
#import "DBLocationManager.h"
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
    
    PFGeoPoint *location = requestObject[@"location"];
    PFGeoPoint *currentLocation =  [PFGeoPoint geoPointWithLocation:[[DBLocationManager sharedInstance] currentLocation]];
    double distance = [location distanceInMilesTo:currentLocation];
    
    if ([[PFUser currentUser][@"building"] isEqualToString:@""])
    {
        if (distance < 1) {
            self.distanceLabel.text = [NSString stringWithFormat:@"less than a mile away"];

        }
        else if (distance > 10)
        {
            self.distanceLabel.text = [NSString stringWithFormat:@"10+ miles away"];

        }
        else
        {
            self.distanceLabel.text = [NSString stringWithFormat:@"%d miles away", (int) distance];

            
        }

    }
    else
    {
        self.distanceLabel.text = @"";

    }

    
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
