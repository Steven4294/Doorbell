
//
//  DBBuildingSettingsViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBuildingSettingsViewController.h"
#import "Parse.h"

@interface DBBuildingSettingsViewController ()

@end

@implementation DBBuildingSettingsViewController

-(void)setup
{
    __unsafe_unretained typeof(self) welf = self;

    PFUser *currentUser = [PFUser currentUser];
    NSString *buildingName = currentUser[@"building"];
    
    [welf addSection:[BOTableViewSection sectionWithHeaderTitle:@"Building" handler:^(BOTableViewSection *section)
    {
        BOChoiceTableViewCell *cell1 = [BOChoiceTableViewCell cellWithTitle:buildingName key:@"buildingName" handler:^(BOSwitchTableViewCell *cell)
                                        {
                                            
                                        }];
       [section addCell:cell1];
     }]];
}

@end
