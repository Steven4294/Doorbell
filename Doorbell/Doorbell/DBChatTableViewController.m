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


@interface DBChatTableViewController ()
{
    NSMutableArray *usersArray;
    NSMutableArray *usersWithMessages;
    NSMutableArray *recentMessagesArray;
    
}

@end

@implementation DBChatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    usersWithMessages = [[NSMutableArray alloc] init];
    recentMessagesArray = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.messageButton addTarget:self action:@selector(newMessageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    usersArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    
    [query orderByAscending:@"facebookName"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            // The find succeeded.
            // Do something with the found objects
            usersArray = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else
        {
            // Log details of the failure
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self findUsersWithMessages];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)messageWasSent
{
    NSLog(@"message was sent");
}

- (void)newMessageButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBSearchUserViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSearchUserViewController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)findUsersWithMessages
{
    NSLog(@"making call");
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *flagQuery = [flaggedUserRelation query];
    
    PFRelation *relation = currentUser[@"messages"];
    PFQuery *query = [relation query];
    query.limit = 1000;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"poster"];
    
    [flagQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        NSMutableArray *flaggedUsers = [objects mutableCopy];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
         {
             for (PFObject *message in objects)
             {
                 PFUser *userTo = message[@"to"];
                 PFUser *userFrom = message[@"from"];
                 
                 if (![usersWithMessages containsObject:userTo] && userTo != currentUser && (![flaggedUsers containsObject:userTo]))
                 {
                     [usersWithMessages addObject:userTo];
                 }
                 else if (![usersWithMessages containsObject:userFrom] && userFrom != currentUser && (![flaggedUsers containsObject:userFrom]))
                 {
                     [usersWithMessages addObject:userFrom];
                 }
             }
             
             [self.tableView reloadData];
             
         }];
        
    }];
    
    
}
- (void)findMostRecentMessageForUser:(PFUser *)user withBlock:(void (^)(PFObject *message, BOOL success))completionBlock
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation =  currentUser[@"messages"];
    PFQuery *query = [relation query];
    [query whereKey:@"from" containedIn:@[user, currentUser ]];
    [query whereKey:@"to" containedIn:@[user, currentUser ]];
    query.limit = 1;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         
         PFObject *object = [objects firstObject];
         completionBlock(object, YES);
     }];
    
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [usersWithMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if ([usersWithMessages count] > indexPath.row)
    {
        PFUser *user = [usersWithMessages objectAtIndex:indexPath.row];
        cell.messageLabel.text = @"";
        
        if (user[@"facebookName"] != nil)
        {
            cell.nameLabel.text = user[@"facebookName"];
            
        }
        
        [self findMostRecentMessageForUser:user withBlock:^(PFObject *message, BOOL success) {

            cell.messageLabel.text = message[@"message"];
            NSDate *date = [message createdAt];
            TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
            cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date];
        }];
        
        
        cell.user = (PFUser *) user;
        
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                                 placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
        
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
