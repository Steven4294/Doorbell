//
//  DBSecondaryMenuViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/24/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBSideMenuController;

@interface DBSecondaryMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DBSideMenuController *sideMenuController;

@end
