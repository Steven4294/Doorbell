//
//  DBNotificationSettingsViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/30/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNotificationSettingsViewController.h"

@interface DBNotificationSettingsViewController ()

@end

@implementation DBNotificationSettingsViewController

-(void)setup
{
    __unsafe_unretained typeof(self) welf = self;
    
    [welf addSection:[BOTableViewSection sectionWithHeaderTitle:@"Notifications" handler:^(BOTableViewSection *section) {
        
        
        BOSwitchTableViewCell *cell1 = [BOSwitchTableViewCell cellWithTitle:@"Messages" key:@"messageNotification" handler:^(BOSwitchTableViewCell *cell)
                                        {
                                            
                                        }];
        
        BOSwitchTableViewCell *cell2 = [BOSwitchTableViewCell cellWithTitle:@"Comments" key:@"commentNotification" handler:^(BOSwitchTableViewCell *cell)
                                        {
                                            
                                        }];
        
        BOSwitchTableViewCell *cell3 = [BOSwitchTableViewCell cellWithTitle:@"Likes" key:@"likeNotification" handler:^(BOSwitchTableViewCell *cell)
                                        {
                                            
                                        }];
        [section addCell:cell1];
        [section addCell:cell2];
        [section addCell:cell3];
        
        
        
    }]];
}

@end
