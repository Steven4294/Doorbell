//
//  DBTableViewCell.h
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBSDKProfilePictureView;

@interface DBTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet FBSDKProfilePictureView *profileImageView;

@end
