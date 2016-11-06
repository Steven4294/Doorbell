//
//  ViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 1/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLoginViewController.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4.h>

#import "DBProfileViewController.h"
#import "DBSideMenuController.h"
#import "DBEmailSignUpViewController.h"
#import "DBEmailLoginViewController.h"
#import "DBBuildingPickerViewController.h"
#import "DBLabel.h"
#import "FTImageAssetRenderer.h"
#import "UIColor+FlatColors.h"

#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"

@interface DBLoginViewController ()

@end

@implementation DBLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    // self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    // self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.cornerRadius = 5.0f;
    self.emailSignInButton.layer.cornerRadius = 5.0f;
    self.emailSignUpButton.layer.cornerRadius = 5.0f;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signUpWithEmail)];
    self.emailSignupLabel.userInteractionEnabled = YES;
    [self.emailSignupLabel addGestureRecognizer:tapGesture];
    
    [self.emailSignInButton addTarget:self action:@selector(signInWithEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.emailSignUpButton addTarget:self action:@selector(signUpWithEmail) forControlEvents:UIControlEventTouchUpInside];
    
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    alertConfig.defaultTextOK = @"OK";
    alertConfig.defaultTextCancel = @"Cancel";
    alertConfig.defaultTextConfirm = @"OK";
    
    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
   // self.swipeView.delaysContentTouches = NO;
    //self.swipeView.autoscroll = -.25f;
    
    NSLog(@"%f auto", self.swipeView.autoscroll );
    [self.pageControl setNumberOfPages:4];
}

- (void)signInWithEmail
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBEmailLoginViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBEmailLoginViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)signUpWithEmail
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBEmailSignUpViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBEmailSignUpViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)loginButtonClicked
{
    [self loginUser];
}

- (void)loginUser
{
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Facebook login: %@", [PFUser currentUser].username);
        }
        else
        {
            if ([FBSDKAccessToken currentAccessToken])
            {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                 {
                     if (!error)
                     {
                         PFUser *currentUser = [PFUser currentUser];
                         
                         currentUser[@"facebookId"] = result[@"id"];
                         currentUser[@"facebookName"] = result[@"name"];
                         
                         [currentUser saveInBackground];
                     }
                 }];
            }
            
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];
            
            BOOL isVerified = [user[@"verifiedCode"] boolValue];
            
            if (user[@"building"] == nil || [user[@"building"] isEqualToString:@""] || (isVerified == NO))
            {
                [self pushBuildingPicker];
            }
            else
            {
                [self presentFeed];
            }
        }
        
    }];
    
}

- (void)presentFeed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBSideMenuController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSideMenuController"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 4;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *titleLabel = nil;
    DBLabel *descriptionLabel = nil;
    UIImageView *iconImageView = nil;
    
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.swipeView.frame.size.width - 2*20.0, 50.0f)];
        titleLabel.center = CGPointMake(view.center.x, view.center.y);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.tag = 1;
        titleLabel.numberOfLines = 2;
        //  titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        //  titleLabel.layer.borderWidth = 1.0f;
        [view addSubview:titleLabel];
        
        descriptionLabel = [[DBLabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + 50.0f, self.swipeView.frame.size.width - 20.0, 100.0f)];
        descriptionLabel.center = CGPointMake(view.center.x, descriptionLabel.center.y);
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
        descriptionLabel.textColor = [UIColor lightGrayColor];
        descriptionLabel.numberOfLines = 3;
        descriptionLabel.tag = 2;
        // descriptionLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        // descriptionLabel.layer.borderWidth = 1.0f;
        descriptionLabel.verticalAlignment = UIControlContentVerticalAlignmentTop;
        [view addSubview:descriptionLabel];
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y - 100.0f, 90.0, 90.0)];
        iconImageView.center = CGPointMake(view.center.x, iconImageView.center.y);
        iconImageView.tag = 3;
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        // iconImageView.layer.borderColor = [UIColor greenColor].CGColor;
        //  iconImageView.layer.borderWidth = 1.0f;
        [view addSubview:iconImageView];
    }
    else
    {
        titleLabel = (UILabel *)[view viewWithTag:1];
        descriptionLabel = (DBLabel *)[view viewWithTag:2];
        iconImageView = (UIImageView *)[view viewWithTag:3];
        
    }
    
    switch (index) {
        case 0:
            titleLabel.text = @"Welcome to Doorbell";
            descriptionLabel.text = @"Swipe to learn more.";
            iconImageView.image = [self imageNamed:@"DBhigh_white2"];
            break;
        case 1:
            titleLabel.text = @"Meet your neighbors";
            descriptionLabel.text = @"Share goods, services, experiences and more.";
            iconImageView.image = [self imageNamed:@"building-icon"];
            
            break;
        case 2:
            titleLabel.text = @"Building Events";
            descriptionLabel.text = @"Have access to great events. Get smart notifications to help you make the most of living in your building.";
            iconImageView.image = [self imageNamed:@"events-login"];
            break;
        case 3:
            titleLabel.text = @"Exclusive Deals";
            descriptionLabel.text = @"Tune into your neighborhood with great deals at local businesses.";
            iconImageView.image = [self imageNamed:@"sale"];
            break;
        default:
            break;
    }
    return view;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    [self.pageControl setCurrentPage:[swipeView currentPage]];
}

- (UIImage *)imageNamed:(NSString *)imageName
{
    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:imageName withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *image = [renderer imageWithCacheIdentifier:@"white"];
    return image;
}

- (void)pushBuildingPicker
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBBuildingPickerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBBuildingPickerViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
