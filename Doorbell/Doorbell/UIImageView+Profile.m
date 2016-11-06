//
//  UIImageView+Profile.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "UIImageView+Profile.h"
#import "Parse.h"
#import "DBObjectManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (Profile)

- (void)setProfileImageViewForUser:(PFUser *)user isCircular:(BOOL)circle
{
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;

    if (circle == YES)
    {
        self.layer.cornerRadius =  self.frame.size.width/2;
    }
    
    [[DBObjectManager sharedInstance] fetchImageForUser:user withBlock:^(BOOL success, UIImage *image)
    {
        [self setImage:image];
    }];
}

@end
