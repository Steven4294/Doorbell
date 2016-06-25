//
//  DBNotificationCenterViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNotificationCenterViewController.h"
#import "DBNotificationCell.h"
#import "DBCommentViewController.h"
#import "DBGenericProfileViewController.h"
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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.title = @"notifications";
    
    [self fetchNotifications];
}

- (void)fetchNotifications
{
    [[[DBObjectManager alloc] init] fetchAllNotificationsForUser:[PFUser currentUser] withCompletion:^(NSError *error, NSArray *notifications) {
        
        if (error == nil)
        {
            notificationsArray = [notifications mutableCopy];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    // assumes the notification is for a comment
    PFObject *notification = [notificationsArray objectAtIndex:indexPath.row];
    PFUser *user = notification[@"comment"][@"poster"];
    cell.notificationObject = notification;
    
    cell.nameClassifier.tapHandler = ^(KILabel *label, NSString *string, NSRange range)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBGenericProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBGenericProfileViewController"];
        vc.user = user;
        
        [vc setModalPresentationStyle:UIModalPresentationFullScreen];
        [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBNotificationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.notificationObject)
    {
        PFObject *request = cell.notificationObject[@"comment"][@"request"];
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBCommentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBCommentViewController"];
        vc.request = request;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
