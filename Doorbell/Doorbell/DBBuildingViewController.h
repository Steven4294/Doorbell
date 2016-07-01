//
//  DBBuildingViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/27/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBBuildingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
