//
//  DBTableViewCell.m
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBTableViewCell.h"

@implementation DBTableViewCell

- (void)awakeFromNib {
    // Initialization code

    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0f;
    self.profileImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    [super prepareForReuse];    
}

@end
