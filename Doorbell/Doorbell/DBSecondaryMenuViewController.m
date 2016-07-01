//
//  DBSecondaryMenuViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/24/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBSecondaryMenuViewController.h"
#import "DBRecentMessageCell.h"
#import "DBOnlineMessageCell.h"
#import "DBObjectManager.h"
#import "DBMessageViewController.h"
#import "DBSideMenuController.h"
#import "DBNavigationController.h"
#import "UIScrollView+JElasticPullToRefresh.h"

@implementation DBSecondaryMenuViewController
{
    NSMutableArray *recentUsersAll;
    NSMutableArray *recentUsersToDisplay;

    NSMutableArray *allUsers; //that have sent a message
    NSArray *conversations;

    DBObjectManager *objectManager;
}

- (void)viewDidLoad
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    allUsers = [[NSMutableArray alloc] init];
    conversations = [[NSArray alloc] init];
    objectManager = [DBObjectManager sharedInstance];
    
    [self fetchConversations];
    [self setupRefreshControl];
}

- (void)setupRefreshControl
{
    __weak typeof(self) welf = self;
    
    JElasticPullToRefreshLoadingViewCircle *loadingViewCircle = [[JElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingViewCircle.tintColor = [UIColor whiteColor];
    
    [self.tableView addJElasticPullToRefreshViewWithActionHandler:^
     {
         [welf fetchConversations];
     }
     
                                                      LoadingView:loadingViewCircle];
    
    [self.tableView setJElasticPullToRefreshBackgroundColor:self.tableView.backgroundColor];
    [self.tableView setJElasticPullToRefreshFillColor:[UIColor colorWithRed:40/255.0f green:46/255.0f blue:52/255.0f alpha:1.0f]];
}

- (void)fetchOnlineUsers
{
    recentUsersAll = [[NSMutableArray alloc] init];
    recentUsersToDisplay = [[NSMutableArray alloc] init];
    [objectManager fetchAllActiveUsers:^(NSError *error, NSArray *users)
    {
        recentUsersAll = [users mutableCopy];

        for (PFUser *user in users)
        {
            if (![allUsers containsObject:user] && (![user isEqual:[PFUser currentUser]]))
            {
                [recentUsersToDisplay addObject:user];
            }
        }
        
        [self.tableView stopLoading];
        [self.tableView reloadData];
    }];
}

- (void)fetchConversations
{
    [objectManager fetchAllConversations:^(BOOL success, NSArray *conversationsFetched)
    {
        conversations = conversationsFetched;
        
        for (PFObject *conversation in conversations)
        {
            PFUser *user = [self otherUser:conversation[@"mostRecentMessage"][@"sender"]
                                   andUser:conversation[@"mostRecentMessage"][@"recipient"]];
            
            [allUsers addObject:user];
        }
        [self fetchOnlineUsers];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return conversations.count;
    }
    else
    {
        return recentUsersToDisplay.count;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        DBRecentMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentMessageCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        PFObject *conversation = [conversations objectAtIndex:indexPath.row];
        
        PFUser *user = [self otherUser:conversation[@"mostRecentMessage"][@"sender"]
                               andUser:conversation[@"mostRecentMessage"][@"recipient"]];
        cell.conversation = conversation;
        cell.user = user;
        // this can get piped down eventually
        if ([recentUsersAll containsObject:user])
        {
            cell.isOnline = YES;
        }
        else
        {
            cell.isOnline = NO;
        }
      
        return cell;
    }
    else
    {
        DBOnlineMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"onlineMessageCell" forIndexPath:indexPath];
        cell.user = [recentUsersToDisplay objectAtIndex:indexPath.row];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBRecentMessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = cell.user;
    PFObject *conversation = cell.conversation;
    PFObject *message = conversation[@"mostRecentMessage"];
    
    if (message[@"recipient"] == [PFUser currentUser])
    {
        // mark message as read
        conversation[@"read"] = [NSNumber numberWithBool:YES];
        [conversation saveInBackground];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = user;
    messageVC.senderId = [PFUser currentUser].objectId;
    messageVC.senderDisplayName = @"display name";
    messageVC.automaticallyScrollsToMostRecentMessage = YES;
    
    // somehow push this
    DBNavigationController *navigationController = (DBNavigationController *) self.sideMenuController.rootViewController;
    [navigationController setViewControllers:@[messageVC] animated:NO];
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:11.0f]];
    [label setTextColor:[UIColor colorWithWhite:160/255.0 alpha:1.0f]];
    NSString *string;
    if (section == 0)
    {
        string = @"RECENT MESSAGES";
    }
    else
    {
        string = @"ONLINE USERS";
    }
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:self.tableView.backgroundColor]; //your background color...
    return view;
}

- (PFUser *)otherUser:(PFUser *)user1 andUser:(PFUser *)user2
{
    if (![user1 isEqual:[PFUser currentUser]])
    {
        return user1;
    }
    else
    {
        return user2;
    }
}

@end
