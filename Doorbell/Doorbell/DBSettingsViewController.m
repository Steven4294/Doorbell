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

@interface DBSettingsViewController ()

@property (nonatomic, strong) NSArray *arrayOfItems;

@end

@implementation DBSettingsViewController

- (void)setup{
    self.title = @"settings";
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Account" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOSwitchTableViewCell cellWithTitle:@"Switch 1" key:@"bool_1" handler:nil]];
        
        [section addCell:[BOSwitchTableViewCell cellWithTitle:@"Switch 2" key:@"bool_2" handler:^(BOSwitchTableViewCell *cell) {
            cell.visibilityKey = @"bool_1";
            cell.visibilityBlock = ^BOOL(id settingValue) {
                return [settingValue boolValue];
            };
            cell.onFooterTitle = @"Switch setting 2 is on";
            cell.offFooterTitle = @"Switch setting 2 is off";
        }]];
        
        // blocked users
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Blocked Users" key:@"key" handler:^(BOChoiceTableViewCell *cell) {
            
            DBBlockedUsersViewController *vc = [[DBBlockedUsersViewController alloc] init];
            cell.destinationViewController = vc;
            
        }]];
        
    }]];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Information & Support" handler:^(BOTableViewSection *section) {
              // [section addCell:[BODateTableViewCell cellWithTitle:@"Date" key:@"date" handler:nil]];
        
    
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Choice" key:@"choice_1" handler:^(BOChoiceTableViewCell *cell) {
            cell.options = @[@"Option 1", @"Option 2", @"Option 3"];
            cell.footerTitles = @[@"Option 1", @"Option 2", @"Option 3"];
        }]];
        
        [section addCell:[BOChoiceTableViewCell cellWithTitle:@"Choice disclosure" key:@"choice_2" handler:^(BOChoiceTableViewCell *cell) {
            cell.options = @[@"Option 1", @"Option 2", @"Option 3", @"Option 4"];
            //cell.destinationViewController = [OptionsTableViewController new];
        }]];
        
      
        
        
    }]];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOButtonTableViewCell cellWithTitle:@"Logout" key:nil handler:^(BOButtonTableViewCell *cell) {
            cell.actionBlock = ^{
                [weakSelf logout];
            };
        }]];
        
        section.footerTitle = @"Built in Cambridge";
    }]];

}

- (void)logout {
    {
        NSLog(@"logging out");
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error == nil) {
                [FBSDKAccessToken setCurrentAccessToken:nil];
                
                NSLog(@"logged out!");
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DBLoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBLoginViewController"];
                [self presentViewController:vc animated:NO completion:nil];
                
            }
            
        }];
        
    }}

@end
