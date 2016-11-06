//
//  DBEmailLoginViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/13/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JVFloatLabeledTextField;

@interface DBEmailLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *passwordTextField;

@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@end
