//
//  DBSearchUserViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/10/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBSearchUserViewController.h"
#import "DBCustomAcObject.h"
#import "Parse.h"
#import "DBMessageViewController.h"

@interface DBSearchUserViewController ()

@end

@implementation DBSearchUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.acTextField setBorderStyle:UITextBorderStyleNone];
    [self.acTextField setAutoCompleteTableCornerRadius:0.0f];
    self.acTextField.autoCompleteDelegate = self;
    self.acTextField.delegate = self;
    self.acTextField.autoCompleteFontSize = 16.0f;
    self.acTextField.autoCompleteBoldFontName = @"Avenir"  ;
    self.acTextField.applyBoldEffectToAutoCompleteSuggestions = NO;
    self.acTextField.maximumNumberOfAutoCompleteRows = 12;
    self.acTextField.autoCompleteTableCellTextColor = [UIColor darkGrayColor];
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
    if(selectedObject)
    {
        // present the message view controller when user taps the name from drop down menu
        DBCustomAcObject *customObject = (DBCustomAcObject *) selectedObject;
        NSString *userId = customObject.objectId;
        
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" equalTo:userId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            PFUser *user = [objects firstObject];
            PFUser *currentUser = [PFUser currentUser];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DBMessageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
            
            vc.userReciever = user;
            vc.senderId = currentUser.objectId;
            vc.senderDisplayName = currentUser[@"facebookName"];
            vc.automaticallyScrollsToMostRecentMessage = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    else
    {
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
 
    return YES;
}




@end