//
//  DBFeedTableViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 3/8/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBFeedTableViewController.h"
#import "DRCellSlideGestureRecognizer.h"
#import "Parse.h"
#import "DBTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SVPullToRefresh.h"

#import "DBRequestFormViewController.h"
#import "DBBulletinFormViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TLYShyNavBarManager.h"
#import "CEBaseInteractionController.h"
#import "DBNavigationController.h"
#import "DBChatNavigationController.h"
#import "DBChatTableViewController.h"
#import "DBMessageViewController.h"

@interface DBFeedTableViewController ()  <UIViewControllerTransitioningDelegate>
{
    NSMutableArray *requests;
    NSMutableDictionary *userDict;
}

@property (nonatomic, strong) DBTableViewCell *prototypeCell;


@end

@implementation DBFeedTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    userDict = [[NSMutableDictionary alloc] init];
    NSLog(@"view did load");
    
    [[PFUser currentUser] fetchIfNeeded];

    
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"poster"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            // TODO: Create the dictionary to map stuff
            requests = [objects mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self.tableView.pullToRefreshView stopAnimating];

    }];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        PFQuery *query = [PFQuery queryWithClassName:@"Request"];
        [query orderByDescending:@"createdAt"];
        [query includeKey:@"poster"];

        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error)
            {
                requests = [objects mutableCopy];
                [self.tableView reloadData];
            }
            else
            {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            [self.tableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
    CGFloat padding_x = 0;
    CGFloat padding_y = 0;
    UIButton *requestButton = [[UIButton alloc] initWithFrame:CGRectMake(0 + padding_x, self.view.frame.size.height - 65 - padding_y, self.view.frame.size.width - 2*padding_x, 65 - padding_y)];
    requestButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestButton setTitle:@"request" forState:UIControlStateNormal];
    [requestButton.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:20.0]];
    [self.view addSubview:requestButton];
    [self.view bringSubviewToFront:requestButton];
    [requestButton addTarget:self action:@selector(requestButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
   /* [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:242/255.0 green:120/255.0 blue:75/255.0 alpha:1.0],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];*/
    
     [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
     NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    self.shyNavBarManager.scrollView = self.tableView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setImage:[UIImage imageNamed:@"User_Profile_white.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(profileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 0, 22, 22);
    [button2 setImage:[UIImage imageNamed:@"Chat_white.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(chatButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIBarButtonItem *barButton2=[[UIBarButtonItem alloc] init];
    [barButton2 setCustomView:button2];
    self.navigationItem.rightBarButtonItem = barButton2;
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height   );
    
    
}

-(void)requestButtonPressed
{
    NSLog(@"request button pressed");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBRequestFormViewController"];
    UIViewController *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"DBBulletinFormViewController"];

    vc.transitioningDelegate = self;
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    vc2.transitioningDelegate = self;
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:vc2 animated:YES completion:^{
    }];
}

-(void)profileButtonPressed
{
    
    NSLog(@"profile button pressed");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBProfileViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self performSegueWithIdentifier:@"panSegue" sender:self];

}

-(void)chatButtonPressed
{
    
    NSLog(@"chat button pressed");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBChatNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBChatNavigationController"];
    DBChatTableViewController *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"DBChatTableViewController"];

    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    //[self performSegueWithIdentifier:@"chatSegue" sender:self];
    
    [self.navigationController pushViewController:vc2 animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [requests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if ([requests count] > indexPath.row)
    {

        PFObject *object = [requests objectAtIndex:indexPath.row];

        cell.messageLabel.text = [object objectForKey:@"message"];
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        NSDate *createdDate = [object createdAt];
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
        
        PFUser *poster = object[@"poster"];
        cell.user = poster;
        
        if (poster != nil)
        {
            cell.nameLabel.text = poster[@"facebookName"];
            NSLog(@"name: %@   id: %@", poster[@"facebookName"], poster[@"facebookId"]);
    
            NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", poster[@"facebookId"]];
            
            NSLog(@"url: %@", URLString);
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                                     placeholderImage:nil];
            
            [cell.messageLabel sizeToFit];
            
            
        }
        
        
    }
    
    DRCellSlideGestureRecognizer *slideGestureRecognizer = [DRCellSlideGestureRecognizer new];
    DRCellSlideAction *squareAction = [DRCellSlideAction actionForFraction:0.25];
    squareAction.activeBackgroundColor = [UIColor clearColor];
    squareAction.inactiveBackgroundColor = [UIColor clearColor];
    squareAction.behavior = DRCellSlideActionPushBehavior;
    squareAction.elasticity = 40;
    squareAction.didTriggerBlock = [self pushTriggerBlock];
    
    [slideGestureRecognizer addActions:squareAction];
    
    [cell addGestureRecognizer:slideGestureRecognizer];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // DBTableViewCell *DBCell = (DBTableViewCell *) cell;
   // DBCell.profileImageView = nil;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 150;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // dynamically resizes cells
    PFObject *object = [requests objectAtIndex:indexPath.row];
    NSString *messageString = [object objectForKey:@"message"];
    CGFloat labelHeight = [self paddingForString:messageString];
    CGFloat staticHeight = 85.0f;
    
    return labelHeight + staticHeight;
}

- (DRCellSlideActionBlock)pushTriggerBlock
{
    return ^(UITableView *tableView, NSIndexPath *indexPath)
    {
        DBTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
        
        messageVC.userReciever = cell.user;
        messageVC.senderId = [PFUser currentUser].objectId;
        messageVC.senderDisplayName = @"display name";
        messageVC.automaticallyScrollsToMostRecentMessage = YES;

        [self.navigationController pushViewController:messageVC animated:YES];
    };
}

- (DRCellSlideActionBlock)pullTriggerBlock
{
    return ^(UITableView *tableView, NSIndexPath *indexPath) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hooray!" message:@"You just pushed a cell." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

-(CGFloat)paddingForString:(NSString *)string
{
    CGFloat kNumberOfCharsPerLine = 30.0f;
    CGFloat padding = round([string length] / kNumberOfCharsPerLine);
    padding = padding * 15.0f;
    return padding;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    DBNavigationController *navigationController = (DBNavigationController *) self.navigationController;
    
    if (navigationController.navigationInteractionController)
    {
        [navigationController.navigationInteractionController wireToViewController:presented forOperation:CEInteractionOperationDismiss];
    }
    
    navigationController.navigationAnimationController = nil;
    if ([presented isKindOfClass:NSClassFromString(@"DBProfileViewController")])
    {
        navigationController.navigationAnimationController = [[NSClassFromString(@"CEPanAnimationController") alloc] init];
        navigationController.navigationAnimationController.reverse = YES;

    }
    if ([presented isKindOfClass:NSClassFromString(@"DBChatTableViewController")])
    {
        navigationController.navigationAnimationController = [[NSClassFromString(@"CEPanAnimationController") alloc] init];
        navigationController.navigationAnimationController.reverse = NO;

    }
    
    

    

    
    
    return navigationController.navigationAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    DBNavigationController *navigationController = (DBNavigationController *) self.navigationController;

    navigationController.navigationAnimationController.reverse = NO;
    
    navigationController.navigationAnimationController = nil;
    if ([dismissed isKindOfClass:NSClassFromString(@"DBProfileViewController")])
    {
        navigationController.navigationAnimationController = [[NSClassFromString(@"CEPanAnimationController") alloc] init];
        navigationController.navigationAnimationController.reverse = NO;
        
    }
    if ([dismissed isKindOfClass:NSClassFromString(@"DBChatTableViewController")])
    {
        navigationController.navigationAnimationController = [[NSClassFromString(@"CEPanAnimationController") alloc] init];
        navigationController.navigationAnimationController.reverse = YES;
        
    }
    
    return navigationController.navigationAnimationController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    DBNavigationController *navigationController = (DBNavigationController *) self.navigationController;

    return navigationController.navigationInteractionController && navigationController.navigationInteractionController.interactionInProgress ? navigationController.navigationInteractionController : nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"panSegue"] || [segue.identifier isEqualToString:@"chatSegue"])
    {
        UIViewController *toVC = segue.destinationViewController;
        toVC.transitioningDelegate = self;
    }
    
    [super prepareForSegue:segue sender:sender];
}



@end
