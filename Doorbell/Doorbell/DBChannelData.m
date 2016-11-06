//
//  DBChannelData.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBChannelData.h"
#import "UIColor+FlatColors.h"
#import "Parse.h"
#import "DBObjectManager.h"

@interface DBChannelData ()
{
    BOOL isSendingMessage;
    DBObjectManager *objectManager;
}
@end

@implementation DBChannelData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        
        
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]
                                                        initWithBubbleImage:[UIImage imageNamed:@"bubble_custom3.png"]
                                                        capInsets:UIEdgeInsetsZero];
        // custom bubble can go here
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor flatPeterRiverColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    
    return self;
}

- (void)setChannel:(PFObject *)channel
{
    _channel = channel;
    PFUser *currentUser = [PFUser currentUser];
    objectManager = [DBObjectManager sharedInstance];
    self.avatars = [[NSMutableDictionary alloc] init];
    
    [objectManager fetchMessagesForChannel:channel withCompletion:^(BOOL success, NSArray *messages) {
        for (PFObject *message in messages)
        {
            PFUser *sender = message[@"sender"];
            JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender[@"facebookName"] date:[message createdAt] text:message[@"message"]];
            [self.messages addObject:jsqMessage];
        }
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"messagesLoaded" object:self]];
        
    }];
    
    [objectManager fetchUsersForChannel:channel withCompletion:^(BOOL success, NSArray *users)
    {
        for (PFUser *user in users)
        {
            [objectManager fetchImageForUser:user withBlock:^(BOOL success, UIImage *image)
            {
                JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                               diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                NSDictionary *avatarDict = @{user.objectId: avatar};
                [self.avatars addEntriesFromDictionary:avatarDict];
                
                if (self.avatars.count == users.count)
                {   // you went through all the avatars
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"messagesLoaded" object:self]];
                }
            }];
        }
        
        

    }];
    /*
    // get the FB image of the reciever
    [objectManager fetchImageForUser:userReciever withBlock:^(BOOL success, UIImage *image)
     {
         JSQMessagesAvatarImage *fromImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
         NSDictionary *avatarDict = @{userReciever.objectId: fromImage};
         [self.avatars addEntriesFromDictionary:avatarDict];
     }];
    
    // get the FB image of the current User
    
    NSString *avatarIdSender = currentUser.objectId;
    [objectManager fetchImageForUser:currentUser withBlock:^(BOOL success, UIImage *image)
     {
         JSQMessagesAvatarImage *toImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
         NSDictionary *avatarDict = @{avatarIdSender: toImage};
         [self.avatars addEntriesFromDictionary:avatarDict];
         
     }];*/
    
}

@end
