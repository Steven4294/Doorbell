//
//  DBLeftMenuViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLeftMenuViewController.h"
#import "DBLeftMenuCell.h"
#import "DBSideMenuController.h"
#import "Parse.h"
#import "UIImageView+Profile.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FTImageAssetRenderer.h"
#import "DBNavigationController.h"
#import "DBChannelCell.h"
#import "DBObjectManager.h"
#import "Doorbell-Swift.h"

// menu view controllers
#import "DBProfileViewController.h"
#import "DBFeedTableViewController.h"
#import "DBSettingsViewController.h"
#import "DBEventsViewController.h"
#import "DBChatTableViewController.h"
#import "DBNotificationCenterViewController.h"
#import "DBBuildingViewController.h"
#import "DBChannelMessageViewController.h"
#import "DBPerkViewController.h"
#import "DBInviteViewController.h"

@interface DBLeftMenuViewController ()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) NSArray *imagesArray;
@property (strong, nonatomic) NSMutableArray *channelArray;
@property (strong, nonatomic) DBObjectManager *objectManager;


@end

@implementation DBLeftMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initing left menu");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _titlesArray = @[//@"Channels",
                         @"Home",
                         @"Invite Friends",
                         @"Notifications",
                         @"Messages",
                         @"Events",
                         @"Deals",
                         @"Building",
                         @"Settings"];
        
        
        _imagesArray = @[//@"message_bubble",
                         @"home1",
                         @"invite3",
                         @"notification1",
                         @"message_bubble",
                         @"event1",
                         @"sale",
                         @"building1",
                         @"settings1"];
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"loading menu list");
    
    [super viewDidLoad];
    self.objectManager = [DBObjectManager sharedInstance];

    [self.tableView registerClass:[DBLeftMenuCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
 
    [self.tableView reloadData];
    
    [self updateProfileImage];
    
    PFUser *currentUser = [PFUser currentUser];

    self.nameLabel.text = currentUser[@"facebookName"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfileImage)
                                                 name:@"updatedProfileImage" object:nil];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapped:)];
    gesture.minimumPressDuration = 0.0f;
    [self.headerView addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewWasTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // set to whatever you want to be selected first
    [self.tableView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionNone];
    
    [self.objectManager fetchAllChannelsWithCompletion:^(BOOL success, NSArray *channels)
     {
        self.channelArray = [channels copy];
        [self.tableView reloadData];
    }];
    
    self.channelArray = [[NSMutableArray alloc] init];
}

- (void)tableViewWasTapped:(UITapGestureRecognizer *)gesture
{
    // delay for a short time just for animation's sake
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                     //  [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
                   });
}

- (void)headerViewTapped:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        UIColor *darkBlueColor = self.headerView.backgroundColor;
        
        [UIView animateWithDuration:.2 animations:^
         {
             self.headerView.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:.2 animations:^
                              {
                                  self.headerView.layer.backgroundColor = darkBlueColor.CGColor;
                              } completion:nil];
                         }];
        
    }    // do a cheeky animation
    else
    {
        [self transitionToMenuItem:@"Profile"];
    }
}

- (void)updateProfileImage
{
    PFUser *currentUser = [PFUser currentUser];
    [self.profileImage setProfileImageViewForUser:currentUser isCircular:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
}

- (void)setSideMenuController:(DBSideMenuController *)sideMenuController
{
    _sideMenuController = sideMenuController;
 
}
#pragma mark - UITableView Datasource

- (BOOL)tableView:(SLExpandableTableView *)tableView canExpandSection:(NSInteger)section
{
    
    if ([_titlesArray[section] isEqualToString:@"Channels"]) {
        return YES;

    }
    
    return NO;
}

 - (BOOL)tableView:(SLExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section
{
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(SLExpandableTableView *)tableView expandingCellForSection:(NSInteger)section
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DBLeftMenuCell" owner:self options:nil];
    DBLeftMenuCell *cell = [topLevelObjects objectAtIndex:0];
    cell.itemLabel.text = @"Channels";
    
    FTImageAssetRenderer *renderer1 = [FTAssetRenderer rendererForImageNamed:@"home1" withExtension:@"png"];
    renderer1.targetColor = [UIColor whiteColor];
    UIImage *image_unhighlighted = [renderer1 imageWithCacheIdentifier:@"white"];
    
    FTImageAssetRenderer *renderer2 = [FTAssetRenderer rendererForImageNamed:@"home1" withExtension:@"png"];
    renderer2.targetColor = [UIColor colorWithRed:100/255.0f green:184.0/255.0 blue:250/255.0 alpha:1.0f];
    UIImage *image_highlighted = [renderer2 imageWithCacheIdentifier:@"render2"];
    
    [cell.iconImageView setImage:image_unhighlighted];
    [cell.iconImageView setHighlightedImage:image_highlighted];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelected:YES animated:YES];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_titlesArray[section] isEqualToString:@"Channels"]) 
    {
        return self.channelArray.count+1;
    }
    else
    {
        return [self.titlesArray count];
    }
    return 0;
}

# pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_titlesArray[indexPath.section] isEqualToString:@"Channels"])
    {
        DBChannelCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
        ///cell.isLoading = YES;
        //cell.channelLabel.text = @"# general";
        PFObject *channel =  [self.channelArray objectAtIndex:indexPath.row-1];
        cell.channelLabel.text = channel[@"channelName"];
        cell.channel = channel;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DBLeftMenuCell" owner:self options:nil];
        DBLeftMenuCell *cell = [topLevelObjects objectAtIndex:0];
        cell.itemLabel.text = [self.titlesArray objectAtIndex:indexPath.row];
        
        FTImageAssetRenderer *renderer1 = [FTAssetRenderer rendererForImageNamed:[self.imagesArray objectAtIndex:indexPath.row] withExtension:@"png"];
        renderer1.targetColor = [UIColor whiteColor];
        UIImage *image_unhighlighted = [renderer1 imageWithCacheIdentifier:@"white"];
        
        FTImageAssetRenderer *renderer2 = [FTAssetRenderer rendererForImageNamed:[self.imagesArray objectAtIndex:indexPath.row] withExtension:@"png"];
        renderer2.targetColor = [UIColor colorWithRed:100/255.0f green:184.0/255.0 blue:250/255.0 alpha:1.0f];
        UIImage *image_highlighted = [renderer2 imageWithCacheIdentifier:@"render2"];
        
        [cell.iconImageView setImage:image_unhighlighted];
        [cell.iconImageView setHighlightedImage:image_highlighted];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelected:YES animated:YES];
        return cell;

    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([cell isKindOfClass:[DBChannelCell class]])
    {
        DBChannelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self transitionToChannel:cell.channel];
    }
    else if ([cell isKindOfClass:[DBLeftMenuCell class]])
    {
        
        DBLeftMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *menuItem = cell.itemLabel.text;
        [self transitionToMenuItem:menuItem];
    }

    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0 && indexPath.section == 0)
    {
       // return 40;
    }
    return 60;
}

- (void)transitionToChannel:(PFObject *)channel
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DBNavigationController *navigationController = (DBNavigationController *) self.sideMenuController.rootViewController;

    DBChannelMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBChannelMessageViewController"];
    viewController.channel = channel;
    [navigationController setViewControllers:@[viewController]];
    
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
}

- (void)transitionToMenuItem:(NSString *)menuItem
{
    NSLog(@"transition to menu item %@", menuItem);
    NSUInteger number = [self.titlesArray indexOfObject:menuItem];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath
                                                   animated:YES
                                             scrollPosition:UITableViewScrollPositionNone];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DBNavigationController *navigationController = (DBNavigationController *) self.sideMenuController.rootViewController;
    NSString *currentClass = NSStringFromClass([[navigationController.viewControllers lastObject] class]);
    NSString *newClass = [self classNameForMenuItem:menuItem];
    
    if ([currentClass isEqualToString:newClass] == FALSE && ![newClass isEqualToString:@"Unknown Menu"])
    {
        if ([newClass isEqualToString:@"DBSettingsViewController"])
        {
            DBSettingsViewController *viewController = [[DBSettingsViewController alloc] init];
            [navigationController setViewControllers:@[viewController] animated:NO];
        }
        else
        {
            id viewController = [storyboard instantiateViewControllerWithIdentifier:newClass];
            if ([viewController respondsToSelector:@selector(sideMenuController)])
            {
                [viewController setSideMenuController:self.sideMenuController];
            }
            [navigationController setViewControllers:@[viewController] animated:NO];
        }
    }
    if (![_titlesArray[indexPath.section] isEqualToString:@"Channels"])
    {
        // delay just for a nice animation
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                       {
                           [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
                       });
        
    }

}

- (NSString *)classNameForMenuItem:(NSString *)menuItem
{
    if ([menuItem isEqualToString:@"Home"])
    {
        return @"DBFeedTableViewController";
    }
    else if ([menuItem isEqualToString:@"Profile"])
    {
        return @"DBProfileViewController";
    }
    else if ([menuItem isEqualToString:@"Messages"])
    {
        return @"DBChatTableViewController";
    }
    else if ([menuItem isEqualToString:@"Events"])
    {
        return @"DBEventsViewController";
    }
    else if ([menuItem isEqualToString:@"Notifications"])
    {
        return @"DBNotificationCenterViewController";
    }
    else if ([menuItem isEqualToString:@"Settings"])
    {
        return @"DBSettingsViewController";
    }
    else if ([menuItem isEqualToString:@"Building"])
    {
        return @"DBBuildingViewController";
    }
    else if ([menuItem isEqualToString:@"#general"])
    {
        return @"DBChannelMessageViewController";
    }
    else if ([menuItem isEqualToString:@"Deals"])
    {
        return @"DBPerkViewController";
    }
    else if ([menuItem isEqualToString:@"Invite Friends"])
    {
        return @"DBInviteViewController";
    }
    else
    {
        return @"Unknown Menu";
    }
}



@end
