//
//  DBNavigationController.h
//  Doorbell
//
//  Created by Steven Petteruti on 3/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CEReversibleAnimationController, CEBaseInteractionController, DBSideMenuController;

@interface DBNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (strong, nonatomic) CEReversibleAnimationController *navigationAnimationController;
@property (strong, nonatomic) CEBaseInteractionController *navigationInteractionController;
@property (strong, nonatomic) DBSideMenuController *sideMenuController;

@end
