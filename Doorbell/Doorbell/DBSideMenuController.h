//
//  DBSideMenuController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <LGSideMenuController/LGSideMenuController.h>
#import "YZSwipeBetweenViewController.h"

@class DBLeftMenuViewController;

@interface DBSideMenuController : LGSideMenuController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) DBLeftMenuViewController *leftViewController;
@property (nonatomic, strong) YZSwipeBetweenViewController *swipeViewController;
@property (nonatomic, strong) UIPageControl *pageControl;

@end
