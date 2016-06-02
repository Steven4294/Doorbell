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
    
    NSString *userName = [self formattedUsernameForUser:user];
    NSString *messageBody = comment[@"commentString"];
    
    UIColor *blueColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", userName, messageBody]];
    
    [attrStr addAttributes:@{NSForegroundColorAttributeName: blueColor, NSFontAttributeName: font}
                     range:NSMakeRange(0, userName.length+1)];
    self.messageLabel.attributedText = [attrStr copy];
    
    
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                             placeholderImage: nil
                                    completed: nil];
    
    
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [comment createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
    [self.messageLabel sizeToFit];
    
  
}

- (NSString *)formattedUsernameForUser:(PFUser *)user
{
    NSArray *components = [user[@"facebookName"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *string = [NSString stringWithFormat:@"%@ %@", [components objectAtIndex:0], [[components objectAtIndex:1] substringToIndex:1]];
    return string;
}
@end
