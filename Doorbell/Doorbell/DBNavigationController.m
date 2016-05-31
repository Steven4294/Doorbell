//
//  DBNavigationController.m
//  Doorbell
//
//  Created by Steven Petteruti on 3/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNavigationController.h"
#import "CEBaseInteractionController.h"
#import "CEReversibleAnimationController.h"
#import "LGSideMenuController.h"
#import "DBProfileViewController.h"
#import "DBFeedTableViewController.h"
#import "DBSideMenuController.h"
#import "MOOMaskedIconView.h"

#import <JTHamburgerButton.h>

@interface DBNavigationController ()

@property (nonatomic, strong) UIBarButtonItem *leftBarButton;
@property (nonatomic, strong)  JTHamburgerButton *button;

@end

@implementation DBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBFeedTableViewController *feed = [storyboard instantiateViewControllerWithIdentifier:@"DBFeedTableViewController"];
    feed.sideMenuController = self.sideMenuController;
    
    [self pushViewController:feed animated:nil];

    self.topViewController.navigationItem.leftBarButtonItem = self.leftBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowLeftView:) name:kLGSideMenuControllerWillShowLeftViewNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissLeftView:) name:kLGSideMenuControllerWillDismissLeftViewNotification object:nil];

}

- (UIBarButtonItem *)leftBarButton
{
    
    
    /*UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setImage:[UIImage imageNamed:@"User_Profile_white.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:iconView];*/
    
    
    self.button = [[JTHamburgerButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self.button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:self.button];

    return barButton;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated

{
    [super setViewControllers:viewControllers animated:animated];
    if (viewControllers.count == 1)
    {
        UIViewController *viewController = [viewControllers firstObject];
        viewController.navigationItem.leftBarButtonItem = self.leftBarButton;
    }
}

- (void)menuButtonPressed:(id)sender
{
    if (self.sideMenuController.leftViewShowing == YES)
    {
        [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    }
    else
    {
        [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
    }
}

- (void)willShowLeftView:(id)sender
{
    [self.button setCurrentModeWithAnimation:JTHamburgerButtonModeCross];
}

- (void)willDismissLeftView:(id)sender
{
    [self.button setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:
(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    
    // reverse the animation for 'pop' transitions
    _navigationAnimationController.reverse = operation == UINavigationControllerOperationPop;
    return _navigationAnimationController;
}




@end
