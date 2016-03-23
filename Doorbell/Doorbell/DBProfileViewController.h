//
//  DBProfileViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 2/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface DBProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;



-(IBAction)cancelButton:(id)sender;

@end
