//
//  DBSettingsViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBSettingsViewController.h"
#import "Parse.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DBLoginViewController.h"
#import "DBBlockedUsersViewController.h"
#import "DBNotificationSettingsViewController.h"
#import "DBFeedbackViewController.h"

@interface DBSettingsViewController ()

@end

@implementation DBSettingsViewController

- (void)setup{
    self.title = @"settings";
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Account" handler:^(BOTableViewSection *section) {
        // blocked users
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Blocked Users" key:@"key" handler:^(BOChoiceTableViewCell *cell) {
            
            DBBlockedUsersViewController *vc = [[DBBlockedUsersViewController alloc] init];
            cell.destinationViewController = vc;
            
        }]];
        
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Notifications" key:@"key" handler:^(BOChoiceTableViewCell *cell) {
            
            DBNotificationSettingsViewController *vc = [[DBNotificationSettingsViewController alloc] init];
            cell.destinationViewController = vc;
            
        }]];
    }]];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Information & Support" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Send Feedback" key:@"key" handler:^(BOChoiceTableViewCell *cell)
        {
            DBFeedbackViewController *vc = [[DBFeedbackViewController alloc] init];
            cell.destinationViewController = vc;
        }]];
    }]];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOButtonTableViewCell cellWithTitle:@"Logout" key:nil handler:^(BOButtonTableViewCell *cell)
        {
            cell.actionBlock = ^
            {
                [weakSelf logout];
            };
            cell.mainColor = [UIColor colorWithRed:100/255.0f green:184.0/255.0 blue:250/255.0 alpha:1.0f];
        }]];
        
        section.footerTitle = @"Built in Cambridge";
    }]];

}

- (void)logout
{
    {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error)
        {
            if (error == nil)
            {
                [FBSDKAccessToken setCurrentAccessToken:nil];
                
                NSLog(@"logged out!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DBLoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBLoginViewController"];
                [self presentViewController:vc animated:NO completion:nil];
            }
        }];
    }
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        NSLog(@"Result : %d",result);
    }
    if (error) {
        NSLog(@"Error : %@",error);
    }
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
