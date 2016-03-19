//
//  DBRequestFormViewController.h
//  Doorbell
//
//  Created by Steven on 3/16/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextField.h"

@interface DBRequestFormViewController : UIViewController <UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet MLPAutoCompleteTextField *acTextField;

@end
