//
//  DBRequestFormViewController.m
//  Doorbell
//
//  Created by Steven on 3/16/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBRequestFormViewController.h"
#import "Parse.h"

BOOL responderOverride;



@interface DBRequestFormViewController ()

@property (nonatomic) NSArray *contacts;
@property (nonatomic) UIColor *blueColor;

@end

@implementation DBRequestFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setToolbarHidden:NO];

    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.acTextField setBorderStyle:UITextBorderStyleNone];
    [self.acTextField setAutoCompleteTableCornerRadius:0.0f];
    self.acTextField.autoCompleteDelegate = self;
    self.acTextField.delegate = self;
    self.acTextField.autoCompleteFontSize = 16.0f;
    self.acTextField.autoCompleteBoldFontName = @"Avenir"  ;
    self.acTextField.applyBoldEffectToAutoCompleteSuggestions = NO;
    self.acTextField.maximumNumberOfAutoCompleteRows = 12;
    self.acTextField.autoCompleteTableCellTextColor = [UIColor darkGrayColor];
    
    
    self.blueColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    responderOverride = YES;
}

- (void)cancelButtonPressed{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


- (void)submitButtonPressed{
    [self.view endEditing:YES];
    
    
    PFObject *requestObject = [PFObject objectWithClassName:@"Request"];
    requestObject[@"sender"] = [PFUser currentUser];
    requestObject[@"message"] = self.acTextField.text;
    
    [requestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:^{
                
                
            }];
            
        }
        else{
            NSLog(@"couldn't save object: %@", error);
        }
    }];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    responderOverride = NO;
    [self resignFirstResponder];
    
}

#pragma mark - MLPAutoCompleteTextField Delegate


- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //This is your chance to customize an autocomplete tableview cell before it appears in the autocomplete tableview
    // NSString *filename = [autocompleteString stringByAppendingString:@".png"];
    // filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    // filename = [filename stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
    // [cell.imageView setImage:[UIImage imageNamed:filename]];
    
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedObject){
        NSLog(@"selected object from autocomplete menu %@ with string %@", selectedObject, [selectedObject autocompleteString]);
    } else {
        NSLog(@"selected string '%@' from autocomplete menu", selectedString);
    }
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be added to the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50.0)];

    submitButton.backgroundColor = self.blueColor;
    [submitButton setTitle:@"request" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    textField.inputAccessoryView = submitButton;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return !responderOverride;
}

@end
