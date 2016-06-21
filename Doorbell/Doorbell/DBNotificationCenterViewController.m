//
//  DBNotificationCenterViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNotificationCenterViewController.h"
#import "DBNotificationCell.h"
#import "DBObjectManager.h"
#import "Parse.h"

@implementation DBNotificationCenterViewController
{
    NSMutableArray *notificationsArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    notificationsArray = [[NSMutableArray alloc] init];
}

- (void)fetchNotifications
{
    [[[DBObjectManager alloc] init] fetchAllNotificationsForUser:[PFUser currentUser] withCompletion:^(NSError *error, NSArray *notifications) {
        
        if (error == nil)
        {
            notificationsArray = [notifications mutableCopy];
            NSLog(@"notifications: %@", notificationsArray);
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notificationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    return cell;
    
}

@end
