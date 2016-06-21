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
#import "LMPullToBounceWrapper.h"
#import "UIScrollView+JElasticPullToRefresh.h"
#import "FTImageAssetRenderer.h"

@interface DBFeedTableViewController ()  <UIViewControllerTransitioningDelegate>
{
    NSMutableArray *requests;
    NSMutableDictionary *userDict;
    NSMutableArray *flaggedUsers;
    NSMutableOrderedSet *requestOrderedSet;
    int currentSelection;
    DBObjectManager *objectManager;
    LMPullToBounceWrapper *pullToBounce;

}

@property (nonatomic, strong) DBTableViewCell *prototypeCell;

@end

@implementation DBFeedTableViewController
- (void)dealloc
{
    [self.tableView removeJElasticPullToRefreshView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    objectManager = [[DBObjectManager alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    requestOrderedSet = [[NSMutableOrderedSet alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    userDict = [[NSMutableDictionary alloc] init];
    NSLog(@"view did load");
    
    [[PFUser currentUser] fetchIfNeeded];
    
    [self loadTableView];

    [self setupRefreshControl];
    [self.requestButton addTarget:self action:@selector(requestButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    FTImageAssetRenderer *renderer1 = [FTAssetRenderer rendererForImageNamed:@"compose" withExtension:@"png"];
    renderer1.targetColor = [UIColor whiteColor];
    UIImage *image= [renderer1 imageWithCacheIdentifier:@"white"];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 22, 22);
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(requestButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc] init];
    [rightButtonItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setupRefreshControl
{
    __weak typeof(self) welf = self;
   /* [self.tableView addPullToRefreshWithActionHandler:^
     {
         // prepend data to dataSource, insert cells at top of table view
         [welf refreshTableView];
         
     }];*/
    
    
    JElasticPullToRefreshLoadingViewCircle *loadingViewCircle = [[JElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingViewCircle.tintColor = [UIColor whiteColor];
    
    [self.tableView addJElasticPullToRefreshViewWithActionHandler:^
     {
         [welf refreshTableView];
     }
                                                      LoadingView:loadingViewCircle];
    
    [self.tableView setJElasticPullToRefreshFillColor:self.navigationController.navigationBar.barTintColor];
    [self.tableView setJElasticPullToRefreshBackgroundColor:[UIColor whiteColor]];
}
- (void)loadTableView
{
    [objectManager fetchAllRequests:^(NSError *error, NSArray *objects) {
        
        if (!error) {
            requests = [objects mutableCopy];
            [requestOrderedSet addObjectsFromArray:objects];
            [self.tableView reloadData];
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    }];
}

- (void)refreshTableView
{
    int countInitial = (int) requestOrderedSet.count;
    int countBefore = (int)requests.count;
    
    [objectManager fetchAllRequests:^(NSError *error, NSArray *objects) {
        
        if (error == nil)
        {
                 requests = [objects mutableCopy];
                 [requestOrderedSet addObjectsFromArray:objects];
                 int amountToInsert = (int)requests.count - countBefore;
        
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
            NSLog(@"error refreshing: %@", error);
        }
        [self.tableView.pullToRefreshView stopAnimating];
        [self.tableView stopLoading];
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

- (void)profileButtonPressed
{
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (void)chatButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBChatTableViewController *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"DBChatTableViewController"];
    
    [self.navigationController pushViewController:vc2 animated:YES];
}

#pragma mark - Gesture Recognizers

- (void)cellImageViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
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

- (void)commentLabelWasTapped:(UIGestureRecognizer *)gesture
{
    CGPoint swipeLocation = [gesture locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    DBTableViewCell* tappedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        tappedCell.commentLabel.alpha = .5;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        tappedCell.commentLabel.alpha = 1.0f;
        [self openCommentsViewController:tappedCell];
    }
    else
    {
        tappedCell.commentLabel.alpha = 1.0f;
    }
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
        //cell.separatorInset = UIEdgeInsetsZero;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapRecognizer addTarget:self action:@selector(cellImageViewTapped:)];
        [cell.profileImageView addGestureRecognizer:tapRecognizer];
        
        cell.classifier.tapHandler = ^(KILabel *label, NSString *string, NSRange range)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DBGenericProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBGenericProfileViewController"];
            vc.user = poster;
            
            [vc setModalPresentationStyle:UIModalPresentationFullScreen];
            [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        UILongPressGestureRecognizer *commentGesture = [[UILongPressGestureRecognizer alloc] init];
        commentGesture.minimumPressDuration = 0.0f;
        [commentGesture addTarget:self action:@selector(commentLabelWasTapped:)];
        [cell.commentLabel addGestureRecognizer:commentGesture];
        
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // TODO: protect against crashing here
    [self.tableView beginUpdates];
    [requests removeObject:cell.requestObject];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

@end
