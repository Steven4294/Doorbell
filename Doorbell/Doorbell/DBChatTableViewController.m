//
//  DBChatTableViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 4/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBChatTableViewController.h"
#import "DBChatViewCell.h"
#import "Parse.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DBMessageViewController.h"
#import "DBLoginViewController.h"
#import "DBChatNavigationController.h"
#import "TTTTimeIntervalFormatter.h"
#import "DBSearchUserViewController.h"
#import "UIImageView+Profile.h"
#import "DBObjectManager.h"


@interface DBChatTableViewController ()
{
    NSMutableArray *usersArray;
    NSMutableArray *usersWithMessages;
    NSMutableArray *mostRecentMessages;
    DBObjectManager *objectManager;
    
}

@end

@implementation DBChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    objectManager = [[DBObjectManager alloc] init];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.messageButton addTarget:self action:@selector(newMessageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self findUsersWithMessages];
}


- (void)newMessageButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBSearchUserViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSearchUserViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)findUsersWithMessages
{
    usersWithMessages = [[NSMutableArray alloc] init];
    mostRecentMessages = [[NSMutableArray alloc] init];
    [objectManager fetchAllConversations:^(BOOL success, NSArray *conversations)
     {
        if (success)
        {
            for (PFObject *conversation in conversations) {
                if (conversation[@"mostRecentMessage"]) {
                    [mostRecentMessages addObject:conversation[@"mostRecentMessage"]];

                }
                else
                {
                    PFObject *spoofMessage = [PFObject objectWithClassName:@"Message"];
                    spoofMessage[@"sender"] = [PFUser currentUser];
                    spoofMessage[@"message"] = @" ";
                    
                    [mostRecentMessages addObject:spoofMessage];
                }
                NSArray *users = [conversation valueForKey:@"users"];
                for (PFUser *user in users) {
                    if (user != [PFUser currentUser]) {
                        [usersWithMessages addObject:user];
                    }
                }
            }
            
            [self.tableView reloadData];
        }
    }];
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mostRecentMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if ([mostRecentMessages count] > indexPath.row)
    {
        
        PFObject *message = [mostRecentMessages objectAtIndex:indexPath.row];
        PFUser *user = [usersWithMessages objectAtIndex:indexPath.row];

        cell.messageLabel.text = @"";
        
        //PFUser *user = message[@"sender"];
        cell.nameLabel.text = user[@"facebookName"];
        cell.user = (PFUser *) user;
        [cell.profileImageView setProfileImageViewForUser:user isCircular:NO];
        
        cell.messageLabel.text = message[@"message"];
        NSDate *date = [message createdAt];
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
        
        

        [cell.messageLabel sizeToFit];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBChatViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = cell.user;
    messageVC.senderId = [PFUser currentUser].objectId;
    messageVC.senderDisplayName = @"display name";
    messageVC.automaticallyScrollsToMostRecentMessage = YES;
    
    [self.navigationController pushViewController:messageVC animated:YES];
    
}

@end
