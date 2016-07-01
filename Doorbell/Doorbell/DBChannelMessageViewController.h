//
//  DBChannelMessageViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "DBChannelData.h"

@class PFObject;

@interface DBChannelMessageViewController : JSQMessagesViewController

@property (strong, nonatomic) DBChannelData *chatData;
@property (strong, nonatomic) PFObject *channel;

@end
