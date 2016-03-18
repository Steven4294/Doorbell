//
//  DBRequestFormViewController.m
//  Doorbell
//
//  Created by Steven on 3/16/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBRequestFormViewController.h"
#import "LRTextField.h"
#import "Parse.h"



@interface DBRequestFormViewController ()

@property (nonatomic) NSArray *contacts;

@end

@implementation DBRequestFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setToolbarHidden:NO];

    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 260, 80, 50)];
    [submitButton setTitle:@"submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:submitButton];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    LRTextField *textFieldValidation = [[LRTextField alloc] initWithFrame:CGRectMake(20, 120, 320, 60) labelHeight:15];
    textFieldValidation.placeholder = @"Item Description";
    textFieldValidation.hintText = @"Enter \"abc\"";
    [textFieldValidation setValidationBlock:^NSDictionary *(LRTextField *textField, NSString *text) {
        [NSThread sleepForTimeInterval:.5];
        if ([text length] >= 100) {
            return @{ VALIDATION_INDICATOR_NO : @"100+ characters" };
        }
        else{
            
            PFObject *requestObject = [PFObject objectWithClassName:@"Request"];
            requestObject[@"sender"] = [PFUser currentUser];
            requestObject[@"message"] = text;
            
            [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (succeeded) {
                    
                }
                else{
                    NSLog(@"couldn't save object: %@", error);
                }
            }];
            
            return @{ VALIDATION_INDICATOR_YES : @"sumbitting" };

            
        }
    }];
    [self.view addSubview:textFieldValidation];
    
    
       
    
}

- (void)cancelButtonPressed{
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


- (void)submitButtonPressed{
    [self.view endEditing:YES];
    
    NSLog(@"submit button pressed");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
