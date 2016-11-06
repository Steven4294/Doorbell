//
//  DBRecentMessageCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/24/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBRecentMessageCell.h"
#import "Parse.h"
#import "UIImageView+Profile.h"
#import "UIColor+FlatColors.h"
#import "NSDate+DateTools.h"

@implementation DBRecentMessageCell

- (void)setConversation:(PFObject *)conversation
{
    _conversation = conversation;
    
    PFObject *message = conversation[@"mostRecentMessage"];
    
    PFUser *user = [self otherUser:message[@"sender"] andUser:message[@"recipient"]];

    //self.nameLabel.text = user[@"facebookName"];
    self.messageLabel.text = message[@"message"];
    
    [self.profileImageView setProfileImageViewForUser:user isCircular:NO];
    self.profileImageView.layer.cornerRadius = 5.0f;
    
  
    self.messageLabel.text = message[@"message"];
    
    if (message[@"recipient"] == [PFUser currentUser])
    {
        // you have recieved the message
        if ([conversation[@"read"] boolValue] == TRUE)
        {
            // you've already opened it
            
        }
        else
        {
            // you haven't opened it
            // display a green circle!
        }
    }
    else
    {
        // the most recent message was sent by you
        self.messageLabel.text = [NSString stringWithFormat:@"You: %@", message[@"message"]];
        
        if ([conversation[@"read"] boolValue] == TRUE)
        {
            // show read reciept?
        }
        else
        {
            // show unread reciept?
        }
    }

    NSDate *date = [message createdAt];
    NSString *timeString = [date shortTimeAgoSinceNow];
    
    UIColor *color = [UIColor colorWithWhite:.60 alpha:1.0]; //0 = black,  1 = white
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
    
    NSDictionary *timeAttributes = @{NSForegroundColorAttributeName: color,
                                     NSFontAttributeName: font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@   %@", user[@"facebookName"], timeString]];
    [attrStr addAttributes:timeAttributes range:NSMakeRange(attrStr.length - timeString.length, timeString.length)];
    self.nameLabel.attributedText = attrStr;
}

- (void)setIsOnline:(BOOL)isOnline
{
    _isOnline = isOnline;
    CGFloat borderWidth = 3.0f;
    self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width/2;
    self.onlineView.clipsToBounds = YES;
    
    UIColor *backgroundColor = self.contentView.backgroundColor;
    
    CALayer * externalBorder = [CALayer layer];
    externalBorder.frame = CGRectMake(-borderWidth, -borderWidth, self.onlineView.frame.size.width+2*borderWidth, self.onlineView.frame.size.height+2*borderWidth);
    externalBorder.cornerRadius = externalBorder.frame.size.width/2;
    externalBorder.borderColor = backgroundColor.CGColor;
    externalBorder.borderWidth = borderWidth;
    
    [self.onlineView.layer addSublayer:externalBorder];
    self.onlineView.layer.masksToBounds = NO;
    
    if (isOnline == YES)
    {
        self.onlineView.backgroundColor = [UIColor flatEmeraldColor];
        self.onlineView.layer.borderWidth = 0.0f;

    }
    else
    {
        self.onlineView.backgroundColor = backgroundColor;
        self.onlineView.layer.borderWidth = 1.0f;
        self.onlineView.layer.borderColor = [UIColor grayColor].CGColor;
    }
}

- (PFUser *)otherUser:(PFUser *)user1 andUser:(PFUser *)user2
{
    if (![user1 isEqual:[PFUser currentUser]])
    {
        return user1;
    }
    else
    {
        return user2;
    }
}

@end
