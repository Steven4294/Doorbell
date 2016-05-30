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
    self.title = @"";
    __unsafe_unretained typeof(self) welf = self;

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         if (error == nil) {
             NSMutableArray *flaggedUsers = [objects mutableCopy];
             
             [welf addSection:[BOTableViewSection sectionWithHeaderTitle:@"Blocked Users" handler:^(BOTableViewSection *section) {
                 
                 for (PFUser *user in flaggedUsers)
                 {
                     BOSwitchTableViewCell *cell = [BOSwitchTableViewCell cellWithTitle:user[@"facebookName"] key:[user objectId] handler:^(BOSwitchTableViewCell *cell)
                     {
                         if (cell.toggleSwitch.on)
                         {
                             NSLog(@"switch on: %@", user[@"facebookName"]);
                         }
                         else
                         {
                             NSLog(@"switch off: %@", user[@"facebookName"]);
                         }
                         
                         cell.actionbl
                         
                     }];
                     
                     [cell.toggleSwitch setOn:YES];
                     
                     [section addCell:cell];;
                     
                 }
             }]];
             
         }
         
         
     }];
}

@end
