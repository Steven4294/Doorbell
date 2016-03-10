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
#import "DBSwipeBetweenVCViewController.h"
@interface DBLoginViewController () <FBSDKLoginButtonDelegate>

@end

@implementation DBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"footba"] = @"barasdf";
    [testObject saveInBackground];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 50, 50)];
    loginButton.backgroundColor = [UIColor blueColor];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loginButtonClicked
{
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"login button did complete");
            
            
            
            
            
        }
    }
        ];
        
}



@end
