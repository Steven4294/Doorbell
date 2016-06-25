
//
//  DBChatViewCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 4/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBChatViewCell.h"
#import "UIColor+FlatColors.h"

@implementation DBChatViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsUserActive:(BOOL)isUserActive
{
    _isUserActive = isUserActive;
    if (isUserActive == YES)
    {
        self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width/2;
        self.onlineView.clipsToBounds = YES;
        self.onlineView.backgroundColor = [UIColor flatPeterRiverColor];
     
        CGFloat borderWidth = 5.0f;
        CALayer * externalBorder = [CALayer layer];
        externalBorder.frame = CGRectMake(-borderWidth, -borderWidth, self.onlineView.frame.size.width+2*borderWidth, self.onlineView.frame.size.height+2*borderWidth);
        externalBorder.cornerRadius = externalBorder.frame.size.width/2;
        externalBorder.borderColor = [UIColor whiteColor].CGColor;
        externalBorder.borderWidth = borderWidth;
        
        [self.onlineView.layer addSublayer:externalBorder];
        self.onlineView.layer.masksToBounds = NO;
        self.onlineView.hidden = NO;
    }
    else
    {
        self.onlineView.hidden = YES;

    }
}

@end
