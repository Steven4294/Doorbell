//
//  DBNotificationCenterViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBNotificationCenterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
