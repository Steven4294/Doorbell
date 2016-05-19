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

#import "DBNavigationController.h"

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
    self.loginButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginButton.layer.borderWidth = 1.0f;
    self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height/2;
    
    MMAlertViewConfig *alertConfig = [MMAlertViewConfig globalConfig];
    alertConfig.defaultTextOK = @"OK";
    alertConfig.defaultTextCancel = @"Cancel";
    alertConfig.defaultTextConfirm = @"OK";
    
    PFUser *currentUser = [PFUser currentUser];
    /*if (currentUser.isNew == NO)
    {
        NSLog(@"old user has been shown loginflow");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBNavigationController"];
        [self presentViewController:vc animated:YES completion:^{}];
        
    }*/
}

- (void)loginButtonClicked
{
    [self loginUser];
}

- (void)loginTestUser
{
    NSDictionary *params = @{
                             @"password": @"newpassword",
                             @"name": @"Newname Smith",
                             };
    /* make the API call */
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/{test-user-id}"
                                  parameters:params
                                  HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        NSLog(@"login test user");
    }];
}

- (void)loginUser
{
    NSLog(@"attempting to login user...");
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user)
        {
            NSLog(@"Uh oh. The user cancelled the Facebook login: %@", [PFUser currentUser].username);
        }
        else
        {
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error)
                     {
                         PFUser *currentUser = [PFUser currentUser];
                         
                          currentUser[@"facebookId"] = result[@"id"];
                          currentUser[@"facebookName"] = result[@"name"];
                    
                         [currentUser saveInBackground];
                     }
                 }];
            }
            
           // [self presentFeed];
            
            if (user.isNew)
            {
                // the user is new!
            }
            else
            {
                // an old user has logged back in
            }
            NSLog(@"%@", user[@"verifiedCode"]);
            BOOL isVerified = [user[@"verifiedCode"] boolValue];
          
            if (isVerified == NO)
            {
                [self promptUserForCode];
            }
            else
            {
                [self presentFeed];
                NSLog(@"user already verified");
            }
        }
        
    }];

}

- (void)presentFeed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBNavigationController"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)promptUserForCode
{
 
    MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"Building Code" detail:@"Input Dialog" placeholder:@"enter building code" handler:^(NSString *text)
                              {
                                  PFQuery *query = [PFQuery queryWithClassName:@"BuildingCode"];
                                  query.limit = 1000;
                                  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
                                   {
                                       BOOL correctCode = NO;
                                       for (PFObject *codeObject in objects)
                                       {
                                           NSString *codeString = codeObject[@"codeString"];
                                           
                                           if ([text caseInsensitiveCompare:codeString] == NSOrderedSame) {
                                               correctCode = YES;

                                               PFUser *currentUser = [PFUser currentUser];
                                               currentUser[@"verifiedCode"] = [NSNumber numberWithBool:YES];
                                               [currentUser saveInBackground];
                                               [self presentFeed];
                                           }
                                         
                                           
                                       }
                                       if (correctCode == NO) {
                                           [self showIncorrectCodeAlert];
                                       }
                                   }];
                              }];
    alertView.attachedView = self.view;
    alertView.attachedView.mm_dimBackgroundBlurEnabled = YES;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
    [alertView showWithBlock:nil];
}

-(void)showIncorrectCodeAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        if (index == 1) {
            // retry
            [self promptUserForCode];
        
        }
    };
    
    NSArray *items =
    @[
      MMItemMake(@"Cancel", MMItemTypeHighlight, block),
      MMItemMake(@"Retry", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"invalid code"
                                                         detail:@"sorry that is incorrect!"
                                                          items:items];
    //            alertView.attachedView = self.view;
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

@end
