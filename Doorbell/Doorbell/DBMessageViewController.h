//
//  DBMessageViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 4/6/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h> 
#import "parse.h"
#import "DBChatData.h"

@class DBMessageViewController;

@protocol DBChatViewControllerDelegate <NSObject>

- (void)didDismissDBChatViewController:(DBMessageViewController *)vc;

@end

@interface DBMessageViewController : JSQMessagesViewController

@property (nonatomic, strong) PFUser *userReciever;

@property (weak, nonatomic) id<DBChatViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DBChatData *chatData;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;


@end
