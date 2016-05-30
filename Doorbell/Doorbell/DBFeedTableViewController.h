//
//  DBFeedTableViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 3/8/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReversibleAnimationController.h"

@class DBSideMenuController;

@interface DBFeedTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DBSideMenuController *sideMenuController;

@end
