//
//  DBLeftMenuViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBSideMenuController;

@interface DBLeftMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) DBSideMenuController *sideMenuController;

@end
