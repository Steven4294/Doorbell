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
}

@end

@implementation DBChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return [usersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if ([usersArray count] > indexPath.row)
    {
        PFObject *user = [usersArray objectAtIndex:indexPath.row];
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
    NSLog(@"selected row");
    DBChatViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = cell.user;
    messageVC.senderId = @"bob";
    messageVC.senderDisplayName = @"bob displayname";
    NSLog(@"about to push vc");
    [self presentViewController:messageVC animated:NO completion:^{
        NSLog(@"presented message vc");
    }];
}

@end
