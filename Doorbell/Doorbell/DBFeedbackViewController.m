//
//  DBFeedbackViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/31/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBFeedbackViewController.h"
#import "Parse.h"


@interface DBFeedbackViewController ()
{
    NSString *messageBody;
}

@end


BOOL shouldPresentMail = YES;

@implementation DBFeedbackViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // add device type
    NSString *name = [PFUser currentUser][@"facebookName"];
    messageBody =  [NSString stringWithFormat:@"Tell us what's on your mind: \n\n\n\n\n ----- \n User: %@", name];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  
    if (shouldPresentMail)
    {
        [self sendMail:self];
        shouldPresentMail = NO;
    }
}

-(void)sendMail:(id)sender
{
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Feedback"];
    [mailComposer setToRecipients:@[@"support@doorbell.me"]];
    [mailComposer setMessageBody:messageBody isHTML:NO];
    [self presentModalViewController:mailComposer animated:YES];
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"did finish");
    if (result)
    {
        NSLog(@"Result : %d",result);
    }
    if (error)
    {
        NSLog(@"Error : %@",error);
    }
    [self dismissViewControllerAnimated:YES completion:^
    {
        shouldPresentMail = YES;
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];


}



@end
