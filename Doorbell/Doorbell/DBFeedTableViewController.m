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
#import "SDWebImageManager.h"
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
#import "MOOMaskedIconView.h"
#import "DBGenericProfileViewController.h"
#import "DBSideMenuController.h"
#import "UIColor+FlatColors.h"
#import "DBCommentViewController.h"
#import "DBObjectManager.h"

@interface DBFeedTableViewController ()  <UIViewControllerTransitioningDelegate>
{
    NSMutableArray *requests;
    NSMutableDictionary *userDict;
    NSMutableArray *flaggedUsers;
    NSMutableOrderedSet *requestOrderedSet;
    int currentSelection;
    DBObjectManager *objectManager;
}

@property (nonatomic, strong) DBTableViewCell *prototypeCell;

@end

@implementation DBFeedTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    objectManager = [[DBObjectManager alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    requestOrderedSet = [[NSMutableOrderedSet alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    userDict = [[NSMutableDictionary alloc] init];
    NSLog(@"view did load");
    
    [[PFUser currentUser] fetchIfNeeded];
    
    [self loadTableView];
    __weak typeof(self) welf = self;
    // self.shyNavBarManager.scrollView = self.tableView;
    
    [self.tableView addPullToRefreshWithActionHandler:^
     {
         // prepend data to dataSource, insert cells at top of table view
         [welf refreshTableView];
         
     }];
    
    [self.requestButton addTarget:self action:@selector(requestButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 22, 22);
    [rightButton setImage:[UIImage imageNamed:@"Chat_white.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(chatButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc] init];
    [rightButtonItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    // self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.x, self.view.frame.size.width, self.view.frame.size.height   );
}

- (void)loadTableView
{
    NSLog(@"loading table view");
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         flaggedUsers = [objects mutableCopy];
         PFQuery *query = [PFQuery queryWithClassName:@"Request"];
         [query orderByDescending:@"createdAt"];
         [query includeKey:@"poster"];

         [query whereKey:@"poster" notContainedIn:flaggedUsers   ];
         [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
             
             if (!error)
             {
                 requests = [objects mutableCopy];
                 [requestOrderedSet addObjectsFromArray:objects];
                 [self.tableView reloadData];
                 [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
             }
             else
             {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];
     }];
}

- (void)refreshTableView
{
    int countInitial = (int) requestOrderedSet.count;
    NSLog(@"ordered set before: %d", countInitial);
    int countBefore = requests.count;
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         flaggedUsers = [objects mutableCopy];
         PFQuery *query = [PFQuery queryWithClassName:@"Request"];
         [query orderByDescending:@"createdAt"];
         [query includeKey:@"poster"];
         [query whereKey:@"poster" notContainedIn:flaggedUsers];
         [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
             
             if (!error)
             {
                 requests = [objects mutableCopy];
                 [requestOrderedSet addObjectsFromArray:objects];
                 int amountToInsert = (int)requests.count - countBefore;
                 NSLog(@"inserting: %d", amountToInsert);
                 
                 if (amountToInsert > 0)
                 {
                     NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                     
                     for (int i = 0; i < amountToInsert; i++)
                     {
                         [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                     }
                     
                     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
                     
                     for (PFObject *object in objects)
                     {
                         object[@"createdAt"] = [object createdAt];
                     }
                     [requests sortUsingDescriptors:@[sortDescriptor]];
                     
                     [self.tableView beginUpdates];
                     [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                     [self.tableView endUpdates];
                 }
                 else if (amountToInsert < 0)
                 {
                     requests = [objects mutableCopy];
                     [self.tableView reloadData];
                     
                 }
                 else
                 {
                     requests = [objects mutableCopy];
                     [self.tableView reloadData];
                     
                 }
                 
             }
             else
             {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
             [self.tableView.pullToRefreshView stopAnimating];
         }];
     }];
}

-(void)requestButtonPressed
{
    NSLog(@"request button pressed: %d", self.sideMenuController.leftViewShowing);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *bulletinForm = [storyboard instantiateViewControllerWithIdentifier:@"DBBulletinFormViewController"];
    
    
    bulletinForm.transitioningDelegate = self;
    [bulletinForm setModalPresentationStyle:UIModalPresentationFullScreen];
    if (self.sideMenuController.leftViewShowing == YES)
    {
        NSLog(@"request button pressed: %@", self.sideMenuController);
        [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
        [self.sideMenuController presentViewController:bulletinForm animated:YES completion:nil];
    }
    else
    {
        [self.sideMenuController presentViewController:bulletinForm animated:YES completion:nil];
    }
    
}

-(void)profileButtonPressed
{
    NSLog(@"profile Button pressed: %d", self.sideMenuController.isLeftViewShowing);
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)likeLabelTapped:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"like label tapped");
    CGPoint tapLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    DBTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self toggleLike:cell];
}

- (void)toggleLike:(DBTableViewCell *)cell
{
    [objectManager toggleLike:cell.requestObject withBlock:^(BOOL success, BOOL wasLiked, NSError *error) {
        
        if (wasLiked == YES)
        {
            NSLog(@"Update UI because of LIKE");
            [cell.likersArray addObject:[PFUser currentUser]];
            [cell configureLikeLabel];
        }
        else
        {
            NSLog(@"Update UI because of UNLIKE");
            [cell.likersArray removeObject:[PFUser currentUser]];
            [cell configureLikeLabel];
        }
        
    }];
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
        PFUser *poster = object[@"poster"];
        cell.requestObject = object;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.listOfLikersLabel.text = @" ";
        
        [cell configureLikeLabel];
        
        [objectManager fetchLikersForRequest:cell.requestObject withBlock:^(BOOL isLiked, NSArray *objects, NSError *error) {
            
            if (error == nil)
            {
                cell.likersArray = [objects mutableCopy];
                [cell configureLikeLabel];
            }
        }];
        if (poster != nil)
        {
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
            [tapRecognizer addTarget:self action:@selector(cellImageViewTapped:)];
            [cell.profileImageView addGestureRecognizer:tapRecognizer];
            
            UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] init];
            [tapRecognizer2 addTarget:self action:@selector(cellImageViewTapped:)];
            [cell.nameLabel addGestureRecognizer:tapRecognizer2];
            
            UITapGestureRecognizer *tapRecognizer3 = [[UITapGestureRecognizer alloc] init];
            [tapRecognizer3 addTarget:self action:@selector(likeLabelTapped:)];
            [cell.likeLabel addGestureRecognizer:tapRecognizer3];
            
            cell.delegate = self;
            
            [cell removeAllLeftButtons];
            [cell removeAllRightButtons];
            UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
            if (poster != [PFUser currentUser])
            {
                [cell addRightButtonWithText:@"Block" textColor:[UIColor whiteColor] backgroundColor:[UIColor flatAlizarinColor] font:font];
                [cell addRightButtonWithText:@"Chat" textColor:[UIColor whiteColor] backgroundColor:[UIColor flatPeterRiverColor] font:font];
            }
            else
            {
                [cell addRightButtonWithText:@"Delete" textColor:[UIColor whiteColor] backgroundColor:[UIColor flatAlizarinColor] font:font];
            }
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self openCommentsViewController:cell];
}

- (void)openCommentsViewController:(DBTableViewCell *)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBCommentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBCommentViewController"];
    vc.likersArray = cell.likersArray;
    vc.request = cell.requestObject;
  
    [self.navigationController pushViewController:vc animated:YES];
}

-(CGFloat)paddingForString:(NSString *)string
{
    CGFloat kNumberOfCharsPerLine = 30.0f;
    CGFloat padding = round([string length] / kNumberOfCharsPerLine);
    padding = padding * 15.0f;
    return padding;
}

#pragma mark - SESlideDelegate

- (void)slideTableViewCell:(SESlideTableViewCell*)cell didTriggerLeftButton:(NSInteger)buttonIndex
{
    
}

- (void)slideTableViewCell:(SESlideTableViewCell*)cell didTriggerRightButton:(NSInteger)buttonIndex
{
    DBTableViewCell *feedCell = (DBTableViewCell *) cell;
    
    NSLog(@"%@", feedCell.user);
    if (feedCell.user == [PFUser currentUser])
    {
        switch (buttonIndex)
        {
            case 0:
                // delete content
                [objectManager deleteRequest:feedCell.requestObject withBlock:nil];
                [self removeCellFromFeed:feedCell];
                break;
        }
    }
    else
    {
        switch (buttonIndex)
        {
            case 0:
                // block content
                [objectManager blockUser:feedCell.user withBlock:nil];
                // remove cell from feed
                [self removeCellFromFeed:feedCell];
                break;
            case 1:
                // chat content
                [self chatWithUser:feedCell.user];
                break;
        }
    }
}

- (BOOL)slideTableViewCell:(SESlideTableViewCell*)cell canSlideToState:(SESlideTableViewCellSlideState)slideState
{
    switch (slideState)
    {
        default:
            return YES;
    }
}

- (void)slideTableViewCell:(SESlideTableViewCell *)cell willSlideToState:(SESlideTableViewCellSlideState)slideState
{
    
}

- (void)slideTableViewCell:(SESlideTableViewCell *)cell didSlideToState:(SESlideTableViewCellSlideState)slideState
{
    
}

- (void)slideTableViewCell:(SESlideTableViewCell *)cell wilShowButtonsOfSide:(SESlideTableViewCellSide)side
{
    
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
    if ([segue.identifier isEqualToString:@"panSegue"] || [segue.identifier isEqualToString:@"DBFeedTableViewController"])
    {
        UIViewController *toVC = segue.destinationViewController;
        toVC.transitioningDelegate = self;
    }
    
    [super prepareForSegue:segue sender:sender];
}

- (void)cellImageViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        DBTableViewCell* tappedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
        
        PFUser *user = tappedCell.user;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBGenericProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBGenericProfileViewController"];
        vc.user = user;
        
        [vc setModalPresentationStyle:UIModalPresentationFullScreen];
        [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)blockUser:(PFUser *)user
{
    
    NSLog(@"blocking user");
    PFUser *userToFlag = user;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flagRelation =  [currentUser relationForKey:@"flaggedUsers"];
    [flagRelation addObject:userToFlag];
    
}

- (void)chatWithUser:(PFUser *)user
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = user;
    messageVC.senderId = [PFUser currentUser].objectId;
    messageVC.senderDisplayName = @"display name";
    messageVC.automaticallyScrollsToMostRecentMessage = YES;
    
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)removeCellFromFeed:(DBTableViewCell *)cell
{
    
    NSLog(@"object to remove: %@", [cell.requestObject objectId]);
    
    for (PFObject *object in requests) {
        NSLog(@"%@", [object objectId]);
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // TODO: protect against crashing here
    [self.tableView beginUpdates];
    NSLog(@"# of requests: %d", requests.count);
    [requests removeObject:cell.requestObject];
    NSLog(@"# of requests: %d", requests.count);
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

- (void)deleteRequest:(PFObject *)request
{
    PFUser *poster = request[@"poster"];
    NSString *posterId = poster.objectId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    if ([posterId isEqualToString:currentUserId])
    {
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
         {
             if (error == nil)
             {
                 NSLog(@"deleted message");
             }
             else
             {
                 NSLog(@"error: %@", error);
             }
         }];
    }
    else
    {
        NSLog(@"user does not have permission to delete this request");
        NSLog(@"%@ trying to delete %@ post", poster, currentUserId);
    }
}

@end
