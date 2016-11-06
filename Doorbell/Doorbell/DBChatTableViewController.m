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
#import "DBChatNavigationController.h"
#import "TTTTimeIntervalFormatter.h"
#import "DBSearchUserViewController.h"
#import "UIImageView+Profile.h"
#import "DBObjectManager.h"
#import "FTImageAssetRenderer.h"
#import "UIColor+FlatColors.h"
#import "UIViewController+Utils.h"

@interface DBChatTableViewController ()
{
    NSMutableArray *usersArray;
    NSMutableArray *usersWithMessages;
    NSMutableArray *mostRecentMessages;
    NSMutableArray *conversationsArray;

    DBObjectManager *objectManager;
}

@end

@implementation DBChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"chat table loaded");
    objectManager = [DBObjectManager sharedInstance];

    self.title = @"messages";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.messageButton addTarget:self action:@selector(newMessageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    FTImageAssetRenderer *renderer1 = [FTAssetRenderer rendererForImageNamed:@"search" withExtension:@"png"];
    renderer1.targetColor = [UIColor whiteColor];
    UIImage *image= [renderer1 imageWithCacheIdentifier:@"white"];

    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 22, 22);
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(newMessageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc] init];
    [rightButtonItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self configureCustomBackButton];
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
    conversationsArray = [[NSMutableArray alloc] init];

    [objectManager fetchAllConversations:^(BOOL success, NSArray *conversations)
     {
        if (success)
        {
            for (PFObject *conversation in conversations)
            {
                if (conversation[@"mostRecentMessage"])
                {
                    [mostRecentMessages addObject:conversation[@"mostRecentMessage"]];
                    [conversationsArray addObject:conversation];
                }
             
                NSArray *users = [conversation valueForKey:@"users"];
                for (PFUser *user in users) {
                    if (user != [PFUser currentUser])
                    {
                        [usersWithMessages addObject:user];
                    }
                }
            }
            
            [self.tableView reloadData];
        }
         
         if (conversations.count == 0)
         {
             [self displayEmptyView:YES withText:@"No messages" andSubText:@"You can find your messages here."];
         }
         else
         {
             [self displayEmptyView:NO withText:@"" andSubText:@""];
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
    DBChatViewCell *cell = [DBChatViewCell new];
    
    if ([mostRecentMessages count] > indexPath.row)
    {
        
        PFObject *message = [mostRecentMessages objectAtIndex:indexPath.row];
        PFObject *conversation = [conversationsArray objectAtIndex:indexPath.row];

        PFUser *user = [usersWithMessages objectAtIndex:indexPath.row];
        
        if (message[@"recipient"] == [PFUser currentUser])
        {
            // you have recieved the message
            if ([conversation[@"read"] boolValue] == TRUE)
            {
                // you've already opened it
                cell = [tableView dequeueReusableCellWithIdentifier:@"withoutIcon" forIndexPath:indexPath];

            }
            else
            {
                // you haven't opened it
                // display a green circle!
                cell = [tableView dequeueReusableCellWithIdentifier:@"withIcon" forIndexPath:indexPath];
                FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"circle-filled" withExtension:@"png"];
                renderer.targetColor = [UIColor flatEmeraldColor];
                UIImage *image = [renderer imageWithCacheIdentifier:@"red"];
                [cell.iconImageView setImage:image];
            }
        }
        else
        {
            // the most recent message was sent by you
            cell = [tableView dequeueReusableCellWithIdentifier:@"withIcon" forIndexPath:indexPath];

            FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"reply" withExtension:@"png"];
            renderer.targetColor = [UIColor colorWithWhite:.65f alpha:1.0f];
            UIImage *image = [renderer imageWithCacheIdentifier:@"grayish"];
            [cell.iconImageView setImage:image];
            
            if ([conversation[@"read"] boolValue] == TRUE)
            {
                // show read reciept?
            }
            else
            {
                // show unread reciept?
            }
        }
        
        cell.isUserActive = [objectManager isUserActive:user];
        
        cell.messageLabel.text = @"";
        
        cell.nameLabel.text = user[@"facebookName"];
        cell.user = (PFUser *) user;
        [cell.profileImageView setProfileImageViewForUser:user isCircular:YES];
        
        cell.messageLabel.text = message[@"message"];
        NSDate *date = [message createdAt];
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [timeIntervalFormatter setUsesIdiomaticDeicticExpressions:YES];
        [timeIntervalFormatter setUsesAbbreviatedCalendarUnits:YES];
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBChatViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFObject *message = [mostRecentMessages objectAtIndex:indexPath.row];

    if (message[@"recipient"] == [PFUser currentUser])
    {
        // mark message as read
        PFObject *conversation = [conversationsArray objectAtIndex:indexPath.row];
        conversation[@"read"] = [NSNumber numberWithBool:YES];
        [conversation saveInBackground];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = cell.user;
    messageVC.senderId = [PFUser currentUser].objectId;
    messageVC.senderDisplayName = @"display name";
    messageVC.automaticallyScrollsToMostRecentMessage = YES;
    
    [self.navigationController pushViewController:messageVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
