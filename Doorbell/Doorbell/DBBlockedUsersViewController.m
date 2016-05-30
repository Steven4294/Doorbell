//
//  DBBlockedUsersViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBlockedUsersViewController.h"
#import "Parse.h"

@interface DBBlockedUsersViewController ()

@end

@implementation DBBlockedUsersViewController


- (void)setup{
    self.title = @"settings";
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         //flaggedUsers = [objects mutableCopy];
         
     }];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Blocked Users" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOSwitchTableViewCell cellWithTitle:@"Switch 1" key:@"bool_1" handler:nil]];
        
        [section addCell:[BOSwitchTableViewCell cellWithTitle:@"Switch 2" key:@"bool_2" handler:^(BOSwitchTableViewCell *cell) {
            cell.visibilityKey = @"bool_1";
            cell.visibilityBlock = ^BOOL(id settingValue) {
                return [settingValue boolValue];
            };
            cell.onFooterTitle = @"Switch setting 2 is on";
            cell.offFooterTitle = @"Switch setting 2 is off";
        }]];
        
        
    }]];
    
  //  __unsafe_unretained typeof(self) weakSelf = self;
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
    
   
}

- (void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




@end
