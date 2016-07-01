//
//  DBLeftMenuViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@class DBSideMenuController;

@interface DBLeftMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SLExpandableTableViewDelegate, SLExpandableTableViewDatasource>

@property (nonatomic, strong) IBOutlet SLExpandableTableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) DBSideMenuController *sideMenuController;
@property (nonatomic, strong) IBOutlet UIView *headerView;

@end
