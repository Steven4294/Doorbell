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

@property (nonatomic, strong) NSMutableOrderedSet *flaggedUsersSet;


@end

@implementation DBBlockedUsersViewController


- (void)setup
{
    self.title = @"";
    __unsafe_unretained typeof(self) welf = self;

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         if (error == nil)
         {
             if (objects.count > 0)
             {
                 NSMutableArray *flaggedUsers = [objects mutableCopy];
                 self.flaggedUsersSet = [NSMutableOrderedSet orderedSetWithArray:flaggedUsers];
                 
                 [welf addSection:[BOTableViewSection sectionWithHeaderTitle:@"Blocked Users" handler:^(BOTableViewSection *section) {
                     
                     NSMutableDictionary *defaultDictionary = [[NSMutableDictionary alloc] init];
                     
                     for (PFUser *user in flaggedUsers)
                     {
                         [defaultDictionary setValue:@YES forKey:[user objectId]];
                     }
                     if (defaultDictionary != nil)
                     {
                         [[NSUserDefaults standardUserDefaults] registerDefaults:defaultDictionary];
                     }
                     
                     for (PFUser *user in flaggedUsers)
                     {
                         BOSwitchTableViewCell *cell = [BOSwitchTableViewCell cellWithTitle:user[@"facebookName"] key:[user objectId] handler:^(BOSwitchTableViewCell *cell)
                                                        {
                                                            __unsafe_unretained typeof(BOSwitchTableViewCell) *celf = cell;
                                                            
                                                            cell.actionBlock = ^{
                                                                if (celf.toggleSwitch.on)
                                                                {
                                                                    NSLog(@"switch on: %@", user[@"facebookName"]);
                                                                }
                                                                else
                                                                {
                                                                    NSLog(@"switch off: %@", user[@"facebookName"]);
                                                                }
                                                            };
                                                        }];
                         [section addCell:cell];;
                     }
                     
                 }]];
                 
             }
             else
             {
                 NSLog(@"no blocked users");
                 // possibly add an empty state in future! :)
             }
         }
     }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the user defaults to flagging array
    BOOL didRemoveObject = NO;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    for (PFUser *user in self.flaggedUsersSet)
    {
        NSNumber *flaggedNumber = [[NSUserDefaults standardUserDefaults] valueForKey:[user objectId]];
        BOOL isFlagged = flaggedNumber.boolValue;
        if (isFlagged == NO)
        {
            [flaggedUserRelation removeObject:user];
            didRemoveObject = YES;
        }
    }
    
    if (didRemoveObject == YES)
    {
        [currentUser saveInBackground];
    }
}

@end
