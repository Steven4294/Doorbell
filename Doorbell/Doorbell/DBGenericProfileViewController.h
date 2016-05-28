//
//  DBGenericProfileViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface DBGenericProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PFUser *user;

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfPosts;
@property (nonatomic, strong) IBOutlet UIButton *chatButton;

@property (nonatomic, strong) IBOutlet UITableView *tableView;


@end
