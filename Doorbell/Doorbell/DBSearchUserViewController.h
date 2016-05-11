//
//  DBSearchUserViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/10/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"

@interface DBSearchUserViewController : UIViewController <MLPAutoCompleteSortOperationDelegate>

@property (nonatomic, strong) IBOutlet MLPAutoCompleteTextField *acTextField;

@end

