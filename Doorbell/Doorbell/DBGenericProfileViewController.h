//
//  DBGenericProfileViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface DBGenericProfileViewController : UIViewController

@property (nonatomic, strong) PFUser *user;

@end
