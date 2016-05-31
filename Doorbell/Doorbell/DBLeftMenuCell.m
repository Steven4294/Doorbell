//
//  DBLeftMenuCell.m
//  
//
//  Created by Steven Petteruti on 5/29/16.
//
//

#import "DBLeftMenuCell.h"

@implementation DBLeftMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected == YES)
    {
        self.itemLabel.textColor = [UIColor colorWithRed:100/255.0f green:184.0/255.0 blue:250/255.0 alpha:1.0f];
        [self.iconImageView setHighlighted:YES];
    }
    else
    {
        self.itemLabel.textColor = [UIColor whiteColor];
        [self.iconImageView setHighlighted:NO];
    }
}

@end
