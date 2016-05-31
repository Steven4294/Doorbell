//
//  DBFeedTableViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 3/8/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReversibleAnimationController.h"
#import "SESlideTableViewCell.h"

@class DBSideMenuController;

@interface DBFeedTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SESlideTableViewCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *requestButton;

@property (nonatomic, strong) DBSideMenuController *sideMenuController;

@end
