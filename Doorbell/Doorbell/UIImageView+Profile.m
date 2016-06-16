//
//  UIImageView+Profile.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "UIImageView+Profile.h"
#import "Parse.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (Profile)

- (void)setProfileImageViewForUser:(PFUser *)user isCircular:(BOOL)circle
{
    self.clipsToBounds = YES;
    
    if (circle == YES)
    {
        self.layer.cornerRadius =  self.frame.size.width/2;
    }
    
    if (user[@"profileImage"] != nil)
    {
        // use custom profile image
        [user[@"profileImage"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
         {
             [self setImage:[UIImage imageWithData:data]];
             self.contentMode = UIViewContentModeScaleAspectFill;
          
         }];
    }
    else
    {
        // use FB provided profile picture
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
        [self sd_setImageWithURL:[NSURL URLWithString:URLString]
                placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
    }
}

@end
