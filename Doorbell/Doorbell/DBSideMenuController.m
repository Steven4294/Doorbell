//
//  DBSideMenuController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBSideMenuController.h"
#import "DBNavigationController.h"
#import "DBProfileViewController.h"
#import "DBLeftMenuViewController.h"
#import "DBLeftMenuCell.h"
#import "DBFeedTableViewController.h"
#import "DBSettingsViewController.h"
#import "DBEventsViewController.h"
#import "FTImageAssetRenderer.h"

@interface DBSideMenuController()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) NSArray *imagesArray;

@end

@implementation DBSideMenuController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    _titlesArray = @[@"Home",
                     @"Profile",
                     @"Events",
                     @"Settings"];
    
    _imagesArray = @[@"home1",
                     @"profile1",
                     @"event1",
                     @"settings1"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBNavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"DBNavigationController"];
    navigationController.sideMenuController = self;

    self = [super initWithRootViewController:navigationController];


    self.leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"DBLeftMenuViewController"];
    self.leftViewController.sideMenuController = self;

    //leftViewController.view.backgroundColor = [UIColor yellowColor];
    [self setLeftViewEnabledWithWidth:250.0f presentationStyle:LGSideMenuPresentationStyleSlideBelow alwaysVisibleOptions:0];
    
    // some properties for the side menu
    self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
    self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnAll;
    self.rightViewStatusBarStyle = UIStatusBarStyleDefault;
    self.rightViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnAll;
    
    [self.leftView addSubview:self.leftViewController.view];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.leftViewController.sideMenuController = self;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; // set to whatever you want to be selected first
    [self.leftViewController.tableView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionNone];

}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titlesArray count];
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

   // cell.unhighlightedImage = image_unhighlighted;
    //cell.highlightedImage = image_highlighted;
    
    [cell.iconImageView setImage:image_unhighlighted];
    [cell.iconImageView setHighlightedImage:image_highlighted];
        
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setSelected:YES animated:YES];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *indexPathForSelectedRow = [tableView indexPathForSelectedRow];
    
    
    if (indexPathForSelectedRow != indexPath)
    {
        DBLeftMenuCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *menuItem = cell.itemLabel.text;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DBNavigationController *navigationController = (DBNavigationController *) self.rootViewController;
        
        if ([menuItem isEqualToString:@"Home"])
        {
            DBFeedTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBFeedTableViewController"];
            viewController.sideMenuController = self;
            [navigationController setViewControllers:@[viewController] animated:NO];

        }
        else if ([menuItem isEqualToString:@"Profile"])
        {
            DBProfileViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBProfileViewController"];
            viewController.sideMenuController = self;
            [navigationController setViewControllers:@[viewController] animated:NO];
        }
        else if ([menuItem isEqualToString:@"Events"])
        {
            DBEventsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBEventsViewController"];
            [navigationController setViewControllers:@[viewController] animated:NO];
        }
        else if ([menuItem isEqualToString:@"Settings"])
        {
            DBSettingsViewController *viewController = [[DBSettingsViewController alloc] init];
            [navigationController setViewControllers:@[viewController] animated:NO];
        }
    }
 
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideLeftViewAnimated:YES completionHandler:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



@end
