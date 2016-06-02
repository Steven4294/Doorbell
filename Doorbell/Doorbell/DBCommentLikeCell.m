//
//  DBCommentLikeCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBCommentLikeCell.h"
#import "FTImageAssetRenderer.h"
#import "Parse.h"

@implementation DBCommentLikeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureLikeLabel
{
    if ([self.likersArray containsObject:[PFUser currentUser]])
    {
        FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"heart_large" withExtension:@"png"];
        renderer.targetColor = [UIColor colorWithRed:100/255.0f green:184.0/255.0 blue:250/255.0 alpha:1.0f];
        UIImage *image_highlighted = [renderer imageWithCacheIdentifier:@"blue"];
        self.likeIconView.image = image_highlighted;
    }
    else
    {
        FTImageAssetRenderer *renderer1 = [FTAssetRenderer rendererForImageNamed:@"heart_large" withExtension:@"png"];
        renderer1.targetColor = [UIColor lightGrayColor];
        UIImage *image_unhighlighted = [renderer1 imageWithCacheIdentifier:@"gray"];
        self.likeIconView.image = image_unhighlighted;
    }

    if (self.likersArray.count == 0)
    {
        self.likeLabel.text = @"Be the first to like this";
    }
    else
    {
        if (self.likersArray.count == 1)
        {
            NSString *string1 = [self.likersArray objectAtIndex:0][@"facebookName"];
            self.likeLabel.text = string1;
        }
        else if (self.likersArray.count == 2)
        {
            NSString *string1 = [self.likersArray objectAtIndex:0][@"facebookName"];
            NSString *string2 = [self.likersArray objectAtIndex:1][@"facebookName"];
            
            self.likeLabel.text = [NSString stringWithFormat:@"%@, %@", string1, string2];
        }
        else
        {
            NSString *string1 = [self.likersArray objectAtIndex:0][@"facebookName"];
            NSString *string2 = [self.likersArray objectAtIndex:1][@"facebookName"];
            NSInteger others = self.likersArray.count - 2;
            
            self.likeLabel.text = [NSString stringWithFormat:@"%@, %@ and %ld others", string1, string2, (long)others];
        }
    }


    
    NSLog(@"configuring like label");
}

@end
