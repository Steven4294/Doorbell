//
//  DBCommentViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 5/31/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse.h"

@class NextGrowingTextView;

@interface DBCommentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) PFObject *request;
@property (nonatomic, strong) NSMutableArray *likersArray;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet NextGrowingTextView *NextGrowingTextView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint  *inputContainerViewConstraint;
@property (nonatomic, strong) IBOutlet UIView              *inputContainerView;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;

@end
