//
//  DBChatData.m
//  Doorbell
//
//  Created by Steven Petteruti on 4/6/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBChatData.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation DBChatData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.messages = [[NSMutableArray alloc] init];
        [self loadFakeMessages];
        
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
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}

- (void)setUserReciever:(PFUser *)userReciever
{
    _userReciever = userReciever;
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFRelation *messagesRelation = currentUser[@"messages"];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"Message"];
    PFQuery *query2 = [messagesRelation query];
   // [query2 whereKey:@"to" equalTo:userReciever];
    [query2 whereKey:@"to" containedIn:@[userReciever, currentUser]];
    [query1 whereKey:@"to" matchesKey:@"to" inQuery:query2];
    query1.limit = 200;
    query2.limit = 5000;// keep this limit large
    // get the messages
    [query1 orderByDescending:@"createdAt"];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         NSLog(@"Found: %lu", objects.count);
         for (PFObject *message in objects)
         {
             PFUser *from = message[@"from"];
             if ([from.objectId isEqualToString:currentUser.objectId])
             {
                 // the message was sent by the current user
                 JSQMessage *Message = [[JSQMessage alloc] initWithSenderId:currentUser.objectId senderDisplayName:currentUser.objectId date:[message createdAt] text:message[@"message"]];
                 [self.messages addObject:Message];
                 
             }
             else
             {
              
                 JSQMessage *Message = [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdFrom senderDisplayName:userReciever[@"facebookName"] date:[message createdAt] text:message[@"message"]];
                 [self.messages addObject:Message];
             }

         }
         self.messages = [[self.messages reverseObjectEnumerator] allObjects];

         [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"messagesLoaded" object:self]];
         
     }];
    
    // get the FB image of the reciever
    if (userReciever[@"facebookId"] != nil)
    {
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userReciever[@"facebookId"]];
        NSURL *imageURL = [NSURL URLWithString:URLString];

        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:imageURL
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image)
                                {
                                    JSQMessagesAvatarImage *fromImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                    NSDictionary *avatarDict = @{kJSQDemoAvatarIdFrom: fromImage};
                                    [self.avatars addEntriesFromDictionary:avatarDict];
                                    
                                }
                            }];

    }
    
    // get the FB image of the current User
    if (currentUser[@"facebookId"] != nil)
    {
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentUser[@"facebookId"]];
        NSURL *imageURL = [NSURL URLWithString:URLString];
        
        NSString *avatarIdSender = currentUser.objectId;
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:imageURL
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image)
                                {
                                    JSQMessagesAvatarImage *toImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                    NSDictionary *avatarDict = @{avatarIdSender: toImage};
                                    [self.avatars addEntriesFromDictionary:avatarDict];
                                    
                                }
                            }];
        
    }
    
    
    
    
}

- (void)loadFakeMessages
{
    /*
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate distantPast]
                                                     text:@"Welcome to JSQMessages: A messaging UI framework for iOS."],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdWoz
                                        senderDisplayName:kJSQDemoAvatarDisplayNameWoz
                                                     date:[NSDate distantPast]
                                                     text:@"It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy."],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate distantPast]
                                                     text:@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com."],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdJobs
                                        senderDisplayName:kJSQDemoAvatarDisplayNameJobs
                                                     date:[NSDate date]
                                                     text:@"JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better."],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdCook
                                        senderDisplayName:kJSQDemoAvatarDisplayNameCook
                                                     date:[NSDate date]
                                                     text:@"It is unit-tested, free, open-source, and documented."],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate date]
                                                     text:@"Now with media messages!"],
                     nil];
    
    
   
    JSQMessage *reallyLongMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                        displayName:kJSQDemoAvatarDisplayNameSquires
                                                               text:@"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END"];
    
    [self.messages addObject:reallyLongMessage];
    */
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
