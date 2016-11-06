//
//  ViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 1/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@interface DBLoginViewController : UIViewController <SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *emailSignInButton;
@property (nonatomic, strong) IBOutlet UIButton *emailSignUpButton;
@property (nonatomic, strong) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UILabel *emailSignupLabel;

@end

