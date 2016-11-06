//
//  DBInviteViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 8/4/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Doorbell-Swift.h"
#import "DBSideMenuController.h"
#import <MessageUI/MessageUI.h>

@interface DBInviteViewController : UIViewController <EPPickerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) DBSideMenuController *sideMenuController;

@end
