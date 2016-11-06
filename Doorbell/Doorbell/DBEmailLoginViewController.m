//
//  DBEmailLoginViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/13/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEmailLoginViewController.h"
#import "JVFloatLabeledTextField.h"
#import "UIViewController+Utils.h"
#import "Parse.h"
#import "DBSideMenuController.h"

#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"

@implementation DBEmailLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPlaceholders];
    [self configureBackButtonOnView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailTextField becomeFirstResponder];
    
}
- (void)setUpPlaceholders
{
    UIColor *color = [UIColor colorWithWhite:.75 alpha:1.0f];
    
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: color}];
    
    
    self.passwordTextField.delegate = self;
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.emailTextField.delegate = self;
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self submitButtonPressed];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self constructAccessoryView];
    textField.inputAccessoryView.hidden = ![self shouldShowSubmitButton];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    textField.inputAccessoryView.hidden = ![self shouldShowSubmitButton];
}

- (UIView *)constructAccessoryView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 63.0f)];
    CGFloat y_padding = 10.0f;
    CGFloat x_padding = 30.0f;
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(x_padding, y_padding, self.view.frame.size.width - 2*x_padding, 63.0f - 2*y_padding)];
    
    submitButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [submitButton setTitle:@"Login" forState:UIControlStateNormal];
    [submitButton setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0];
    submitButton.layer.cornerRadius = 5.0f;
    
    [containerView addSubview:submitButton];
    return containerView;
}

- (BOOL)shouldShowSubmitButton
{
    if ([self.emailTextField.text isEqualToString:@""])
    {
        return NO;
    }
    else if ([self.passwordTextField.text isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}

- (void)submitButtonPressed
{
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error == nil)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DBSideMenuController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSideMenuController"];
            [self presentViewController:vc animated:YES completion:^{}];
        }
        else
        {
            [self showIncorrectCodeAlert];
        }
 
    }];
}

-(void)showIncorrectCodeAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        self.passwordTextField.text = @"";
        [self.passwordTextField becomeFirstResponder];
    };
    
    NSArray *items =
    @[
      MMItemMake(@"Cancel", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"Incorrect username or password"
                                                         detail:@"sorry that password is incorrect!"
                                                          items:items];
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

@end
