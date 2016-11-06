//
//  DBInviteViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 8/4/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBInviteViewController.h"

@implementation DBInviteViewController
{
    UINavigationController *navigationController;
}

- (void)viewDidLoad
{
    EPContactsPicker *picker = [[EPContactsPicker alloc] initWithDelegate:self multiSelection:YES];
    //navigationController = [[UINavigationController alloc] initWithRootViewController:picker];
    //[self presentViewController:navigationController animated:YES completion:nil];
    [self.navigationController pushViewController:picker animated:NO];
    picker.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:nil];
    picker.title= @"";
}

- (void)epContactPicker:(EPContactsPicker *)_ didCancel:(NSError *)error
{
    NSLog(@"did cancel");
    // press the menu button
  //  [self dismissViewControllerAnimated:YES completion:nil];
    
   // [navigationController dismissViewControllerAnimated:YES completion:nil];
    if (self.sideMenuController.isLeftViewShowing == NO)
    {
        [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
    }
    else
    {
        [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    }

}

- (void)epContactPicker:(EPContactsPicker *)_ didSelectContact:(EPContact *)contact
{
}

- (void)epContactPicker:(EPContactsPicker *)_ didSelectMultipleContacts:(NSArray<EPContact *> *)contacts
{
    NSMutableArray *recipients = [[NSMutableArray alloc] init];
    for (EPContact *contact in contacts)
    {
        if (contact.phoneNumber != nil) {
            [recipients addObject:contact.phoneNumber];
        }
    }

    if (recipients.count > 0)
    {
        [self showSMS:recipients.copy];
    }
    
}

- (void)epContactPicker:(EPContactsPicker *)_ didContactFetchFailed:(NSError *)error
{
    NSLog(@"error fetching contacts: %@", error);
}

- (void)showSMS:(NSArray *)recipients {
    
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = @"Hey! Check out Doorbell :) https://appsto.re/us/5SBwcb.i";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
