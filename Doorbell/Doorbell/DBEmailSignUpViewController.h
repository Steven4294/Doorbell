//
//  DBEmailSignUpViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/7/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JVFloatLabeledTextField;

@interface DBEmailSignUpViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *firstNameTextField;
@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *lastNameTextField;
@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *emailTextField;
@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *passwordTextField;
@property (nonatomic, strong) IBOutlet JVFloatLabeledTextField *confirmPasswordTextField;

@end
