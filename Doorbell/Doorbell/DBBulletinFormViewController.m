
//
//  DBBulletinFormViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/10/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBulletinFormViewController.h"
#import "Parse.h"

@interface DBBulletinFormViewController ()

@end

@implementation DBBulletinFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.textView.delegate = self;
    self.textView.autocorrectionType = UITextAutocorrectionTypeYes;
}

- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


- (void)submitButtonPressed
{
    [self.view endEditing:YES];
    
    PFObject *requestObject = [PFObject objectWithClassName:@"Request"];
    requestObject[@"poster"] = [PFUser currentUser];
    requestObject[@"message"] = self.textView.text;
    
    [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:^{
        
                
            }];
            
        }
        else{
            NSLog(@"couldn't save object: %@", error);
        }
    }];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];
    
    submitButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [submitButton setTitle:@"request" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    textField.inputAccessoryView = submitButton;
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];
    
    submitButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [submitButton setTitle:@"request" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    textView.inputAccessoryView = submitButton;
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.defaultLabel.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    self.defaultLabel.hidden = ([txtView.text length] > 0);
}

@end