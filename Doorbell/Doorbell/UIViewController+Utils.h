//
//  UIViewController+Utils.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utils)

- (void)configureCustomBackButton;
- (void)configureBackButtonOnView;
- (void)displayEmptyView:(BOOL)displayed withText:(NSString *)text andSubText:(NSString *)subText;

@end
