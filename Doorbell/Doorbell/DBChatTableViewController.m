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

@interface DBChatTableViewController ()
{
    NSMutableArray *usersArray;
    NSMutableArray *usersWithMessages;
}

@end

@implementation DBChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    usersWithMessages = [[NSMutableArray alloc] init];

    [self findUsersWithMessages];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];

    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    usersArray = [[NSMutableArray alloc] init];
    PFQuery *query = [PFUser query];
    
    [query orderByAscending:@"facebookName"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            // The find succeeded.
            // Do something with the found objects
            NSLog(@"found %lu", objects.count);
            usersArray = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else
        {
            // Log details of the failure
        }
    }];
    
}

- (void)findUsersWithMessages
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = currentUser[@"messages"];
    PFQuery *query = [relation query];
    query.limit = 1000;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"poster"];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
        NSLog(@"found in query %lu", objects.count);
         for (PFObject *message in objects)
         {
             PFUser *userTo = message[@"to"];
             PFUser *userFrom = message[@"to"];
             
             if (![usersWithMessages containsObject:userTo] && userTo != currentUser)
             {
                 [usersWithMessages addObject:userTo];
             }
             else if (![usersWithMessages containsObject:userFrom] && userFrom != currentUser)
             {
                 [usersWithMessages addObject:userFrom];
             }
         }
         [self.tableView reloadData];

         NSLog(@"unique users: %lu", usersWithMessages.count);
         
         // this gets all of the messages. Now we must filter down to the
     }];
    
    
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        PFObject *user = [usersWithMessages objectAtIndex:indexPath.row];
        if (user[@"facebookName"] != nil)
        {
            cell.nameLabel.text = user[@"facebookName"];

        }
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
   /* [self presentViewController:messageVC animated:NO completion:^{
        NSLog(@"presented message vc");
    }];
    */
    
    [self.navigationController pushViewController:messageVC animated:YES];
    
}

@end
