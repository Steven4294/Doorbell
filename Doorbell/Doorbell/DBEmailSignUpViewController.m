//
//  DBEmailSignUpViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/7/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEmailSignUpViewController.h"
#import "JVFloatLabeledTextField.h"
#import "NSString+EmailAddresses.h"
#import "Parse.h"
#import "DBSideMenuController.h"
#import "DBBuildingPickerViewController.h"
#import "UIViewController+Utils.h"
#import "DBEmailLoginViewController.h"

#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"

@implementation DBEmailSignUpViewController
{
    NSArray *textFields;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpPlaceholders];
    [self configureBackButtonOnView];
    
    [self.firstNameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.firstNameTextField)
    {
        [self.lastNameTextField becomeFirstResponder];
    }
    else if (textField == self.lastNameTextField)
    {
        [self.emailTextField becomeFirstResponder];
    }
    else if (textField == self.emailTextField)
    {
        // fix the email
        NSString *goodAddress = [self.emailTextField.text stringByCorrectingEmailTypos];
        self.emailTextField.text = goodAddress;
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField)
    {
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.confirmPasswordTextField)
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

- (void)setUpPlaceholders
{
    textFields = [[NSArray alloc] initWithObjects:self.firstNameTextField, self.lastNameTextField, self.passwordTextField, self.confirmPasswordTextField, self.emailTextField, nil];
    
    UIColor *color = [UIColor colorWithWhite:.75 alpha:1.0f];
    
    self.firstNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"first" attributes:@{NSForegroundColorAttributeName: color}];
    self.lastNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"last (optional)" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"password" attributes:@{NSForegroundColorAttributeName: color}];
    self.confirmPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"confirm password" attributes:@{NSForegroundColorAttributeName: color}];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"email" attributes:@{NSForegroundColorAttributeName: color}];
    
    for (UITextField *textField in textFields)
    {
        textField.delegate = self;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    }
}

- (void)submitButtonPressed
{
    NSString *password = self.passwordTextField.text;
    NSString *confirmedPassword = self.confirmPasswordTextField.text;

    if ([self.firstNameTextField.text isEqualToString:@""])
    {
        // first Name is blank
        // please enter a first name
        [self showInvalidNameAlert];
    }
    else if ([self.emailTextField.text isValidEmailAddress] == NO)
    {
        // email is not valid!
        // please enter a valid email
        [self showInvalidEmailAlert];
    }
    else if (password.length < 4)
    {
        [self showInvalidPasswordAlert:@"Passwords is too short!" detail:@"your password must be 4 characters or longer"];
    }
    else if (![password isEqualToString:confirmedPassword])
    {
        // passwords are not the same
        [self showInvalidPasswordAlert:@"Passwords don't match!" detail:@"please re-enter your password"];
    }
    else
    {
        NSString *name;
        if ([self.lastNameTextField.text isEqualToString:@""])
        {
            name = self.firstNameTextField.text;
        }
        else
        {
            name = [NSString stringWithFormat:@"%@ %@", self.firstNameTextField.text, self.lastNameTextField.text];
        }
        
        [self signUpAccount:name email:self.emailTextField.text password:self.passwordTextField.text];
    }
}

- (void)signUpAccount:(NSString *)userName email:(NSString *)email password:(NSString *)password
{
    PFFile *file = [PFFile fileWithName:@"placeholder.png" data:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder.png"], .9)];
    PFUser *user = [[PFUser alloc] init];
    
    user[@"username"] = email;
    user[@"facebookName"] = userName;
    user[@"email"] = email;
    user[@"password"] = password;
    user[@"profileImage"] = file;
    // make sure email is not taken?
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
    {
        
        if (!error)
        {
            // push to building
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];
            
            [self pushBuildingPicker];
            
        }
        else
        {
            NSLog(@"signup error: %@", error);
            if (error.code == 202)
            {
                [self showEmailAlreadyTakenAlert];
            }
        }
    }];
}

- (void)presentFeed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBSideMenuController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSideMenuController"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)showInvalidNameAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        [self.firstNameTextField becomeFirstResponder];
        
    };
    
    NSArray *items = @[MMItemMake(@"Retry", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"First Name cannot be empty!"
                                                         detail:@"please enter your first name"
                                                          items:items];
    
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

- (void)showInvalidEmailAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        [self.emailTextField becomeFirstResponder];
    };
    
    NSArray *items = @[MMItemMake(@"Retry", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"Invalid email address!"
                                                         detail:@"please reenter your email address"
                                                          items:items];
    
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

- (void)showInvalidPasswordAlert:(NSString *)title detail:(NSString *)detail
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        self.passwordTextField.text = nil;
        self.confirmPasswordTextField.text = nil;
        [self.passwordTextField becomeFirstResponder];
        
    };
    
    NSArray *items = @[MMItemMake(@"Retry", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:title
                                                         detail:detail
                                                          items:items];

    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

- (void)showEmailAlreadyTakenAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        self.emailTextField.text = @"";
        [self.emailTextField becomeFirstResponder];
        
    };
    
    MMPopupItemHandler loginBlock = ^(NSInteger index)
    {
        UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DBEmailLoginViewController *vc = [main instantiateViewControllerWithIdentifier:@"DBEmailLoginViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    };
    
    NSArray *items = @[MMItemMake(@"Retry", MMItemTypeNormal, block), MMItemMake(@"Log in", MMItemTypeHighlight, loginBlock)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"That email is already taken!"
                                                         detail:@"please enter a different email"
                                                          items:items];
    
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

- (void)pushBuildingPicker
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBBuildingPickerViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBBuildingPickerViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)shouldShowSubmitButton
{
    if ([self.firstNameTextField.text isEqualToString:@""]) {
        return NO;
    }
    else if ([self.emailTextField.text isEqualToString:@""]) {
        return NO;
    }
    else if ([self.passwordTextField.text isEqualToString:@""]) {
        return NO;
    }
    else if ([self.confirmPasswordTextField.text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (UIView *)constructAccessoryView
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 63.0f)];
    CGFloat y_padding = 10.0f;
    CGFloat x_padding = 30.0f;
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(x_padding, y_padding, self.view.frame.size.width - 2*x_padding, 63.0f - 2*y_padding)];
    
    submitButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0];
    submitButton.layer.cornerRadius = 5.0f;
    
    [containerView addSubview:submitButton];
    return containerView;
}

@end

