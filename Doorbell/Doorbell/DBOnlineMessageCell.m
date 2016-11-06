//
//  DBOnlineMessageCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/26/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBOnlineMessageCell.h"
#import "Parse.h"
#import "UIImageView+Profile.h"
#import "UIColor+FlatColors.h"

@implementation DBOnlineMessageCell

- (void)setUser:(PFUser *)user
{
    NSLog(@"user: %@", user);
    _user = user;
    
    [self setSelectionStyle: UITableViewCellSelectionStyleNone];

    self.nameLabel.text = user[@"facebookName"];
    
    [self.profileImageView setProfileImageViewForUser:user isCircular:NO];
    self.profileImageView.layer.cornerRadius = 5.0f;
    
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
    
    self.onlineView.backgroundColor = [UIColor flatEmeraldColor];
    self.onlineView.layer.borderWidth = 0.0f;
}

@end
