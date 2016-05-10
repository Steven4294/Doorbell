//
//  DBBulletinFormViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/10/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBBulletinFormViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *defaultLabel;


@end
