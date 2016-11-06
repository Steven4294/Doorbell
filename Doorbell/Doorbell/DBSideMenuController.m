//
//  DBSideMenuController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBSideMenuController.h"
#import "DBNavigationController.h"
#import "DBLeftMenuViewController.h"
#import "DBLeftMenuCell.h"
#import "DBSecondaryMenuViewController.h"
#import "FTImageAssetRenderer.h"

@interface DBSideMenuController()

@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) NSArray *imagesArray;

@end

@implementation DBSideMenuController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBNavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"DBNavigationController"];
    navigationController.sideMenuController = self;

    self = [super initWithRootViewController:navigationController];

    
    // default width: 270.0f
    [self setLeftViewEnabledWithWidth:270.0f presentationStyle:LGSideMenuPresentationStyleSlideBelow alwaysVisibleOptions:0];

    // some properties for the side menu
    self.leftViewStatusBarStyle = UIStatusBarStyleDefault;
    self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnNone;
    
    DBSecondaryMenuViewController *recentMessagesVC = [storyboard instantiateViewControllerWithIdentifier:@"DBSecondaryMenuViewController"];
    recentMessagesVC.sideMenuController = self;

    self.swipeViewController = [storyboard instantiateViewControllerWithIdentifier:@"DBSwipeBetweenViewController"];

    self.swipeViewController.view.frame = CGRectMake(0, 0, 270.0f, self.swipeViewController.view.frame.size.height);
    
    self.leftViewController = [storyboard instantiateViewControllerWithIdentifier:@"DBLeftMenuViewController"];

   // self.swipeViewController.viewControllers = @[self.leftViewController, recentMessagesVC];
    self.swipeViewController.viewControllers = @[recentMessagesVC, self.leftViewController];

    [self.leftView addSubview:self.swipeViewController.view];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.leftViewController.sideMenuController = self;
    

}



@end
