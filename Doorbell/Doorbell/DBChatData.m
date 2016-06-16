//
//  DBChatData.m
//  Doorbell
//
//  Created by Steven Petteruti on 4/6/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBChatData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DBObjectManager.h"
#import "UIColor+FlatColors.h"

@implementation DBChatData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        
        /**
         *  Create avatar images once.
         *
         *  Be sure to create your avatars one time and reuse them for good performance.
         *
         *  If you are not using avatars, ignore this.
         */

        JSQMessagesAvatarImage *cookImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"kanye.jpg"]
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *jobsImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"kanye.jpg"]
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *wozImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"kanye.jpg"]
                                                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        
        NSDictionary *avatars = @{ kJSQDemoAvatarIdSquires : cookImage,
                                   kJSQDemoAvatarIdCook : cookImage,
                                   kJSQDemoAvatarIdJobs : jobsImage,
                                   kJSQDemoAvatarIdWoz : wozImage };
        
        
        NSDictionary *users = @{ kJSQDemoAvatarIdJobs : kJSQDemoAvatarDisplayNameJobs,
                                 kJSQDemoAvatarIdCook : kJSQDemoAvatarDisplayNameCook,
                                 kJSQDemoAvatarIdWoz : kJSQDemoAvatarDisplayNameWoz,
                                 kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires,
                                 kJSQDemoAvatarIdFrom: kJSQDemoAvatarDisplayNameFrom};
        
        self.avatars = [[NSMutableDictionary alloc] initWithDictionary:avatars];
        self.users = [[NSMutableDictionary alloc] initWithDictionary:users];
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]
                                                        initWithBubbleImage:[UIImage imageNamed:@"bubble_custom3.png"]
                                                        capInsets:UIEdgeInsetsZero];
        
        NSLog(@"created bubble factory");
# warning - custom bubble goes here
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor flatPeterRiverColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    
    return self;
}

- (void)setUserReciever:(PFUser *)userReciever
{
    _userReciever = userReciever;
    PFUser *currentUser = [PFUser currentUser];
    DBObjectManager *objectManager = [[DBObjectManager alloc] init];

    [objectManager fetchAllMessagesForUser:userReciever withCompletion:^(BOOL success, NSArray *messages) {
        
        for (PFObject *message in messages)
        {
            PFUser *sender = message[@"sender"];
            JSQMessage *jsqMessage = [[JSQMessage alloc] initWithSenderId:sender.objectId senderDisplayName:sender[@"facebookName"] date:[message createdAt] text:message[@"message"]];
            [self.messages addObject:jsqMessage];
        }
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"messagesLoaded" object:self]];
    }];
    
    
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
         
     }];
    
}

- (void)addPhotoMediaMessage
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                      displayName:kJSQDemoAvatarDisplayNameSquires
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
    NSURL *videoURL = [NSURL URLWithString:@"file://"];
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

@end
