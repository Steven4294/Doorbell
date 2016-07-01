//
//  DBChannelData.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

@class PFObject;

@interface DBChannelData : NSObject

@property (strong, nonatomic) PFObject *channel;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@end
