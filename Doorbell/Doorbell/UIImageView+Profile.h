//
//  UIImageView+Profile.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface UIImageView (Profile)

- (void)setProfileImageViewForUser:(PFUser *)user isCircular:(BOOL)circle;

@end
