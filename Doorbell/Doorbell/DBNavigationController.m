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
#import "CSNotificationView.h"
#import <JTHamburgerButton.h>
#import "UIColor+FlatColors.h"

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
    self.navigationBar.shadowImage = [UIImage new];
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    [self pushViewController:feed animated:nil];

    self.topViewController.navigationItem.leftBarButtonItem = self.leftBarButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowLeftView:) name:kLGSideMenuControllerWillShowLeftViewNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDismissLeftView:) name:kLGSideMenuControllerWillDismissLeftViewNotification object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagePushRecieved:) name:@"pushNotificationRecievedForMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentPushRecieved:) name:@"pushNotificationRecievedForComment" object:nil];

}

- (void)commentPushRecieved:(NSNotification *)notification
{
    NSString *message = [notification userInfo][@"aps"][@"alert"];

    [CSNotificationView showInViewController:self
                                   tintColor:[[UIColor flatTurquoiseColor] colorWithAlphaComponent:.8f]
                                        font:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]
                               textAlignment:NSTextAlignmentCenter
                                       image:nil
                                     message:message
                                    duration:3.0f];
}

- (void)messagePushRecieved:(NSNotification *)notification
{
   // TODO: badging
}

- (UIBarButtonItem *)leftBarButton
{
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
