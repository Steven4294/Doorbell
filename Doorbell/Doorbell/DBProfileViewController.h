//
//  DBProfileViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 2/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@class DBSideMenuController;

@interface DBProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UIImageView *coverImage;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfRequests;
@property (nonatomic, strong) IBOutlet UILabel *numberOfMessages;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *editImageButton;

@property (nonatomic, strong) DBSideMenuController *sideMenuController;

-(IBAction)cancelButton:(id)sender;
-(IBAction)logoutButton:(id)sender;

@end
