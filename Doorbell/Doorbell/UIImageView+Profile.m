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

- (void)setProfileImageViewForUser:(PFUser *)user
{
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
    [self sd_setImageWithURL:[NSURL URLWithString:URLString]
                         placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
    

}

@end
