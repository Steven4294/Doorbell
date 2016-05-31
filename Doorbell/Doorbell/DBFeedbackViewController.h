//
//  DBFeedbackViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/31/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DBFeedbackViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    MFMailComposeViewController *mailComposer;
}

@end
