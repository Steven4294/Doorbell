//
//  DBObjectManager.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBObjectManager.h"
#import <SDWebImage/SDWebImageManager.h>
@interface DBObjectManager ()

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation DBObjectManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentUser = [self currentUser];
    }
    return self;
}

- (PFUser *)currentUser
{
    return [PFUser currentUser];
}

- (void)postCommentWithString:(NSString *)commentString toRequest:(PFObject *)request fromUser:(PFUser *)poster withCompletion:(void(^)(BOOL success, PFObject *comment))block;
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"poster"] = poster;
    comment[@"commentString"] = commentString;
    comment[@"request"] = request;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {
         if (error == nil)
         {
             PFRelation *relation = [request relationForKey:@"comments"];
             [relation addObject:comment];
             //request[@"commentsCount"] = relation.
             [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
              {
                  if (error == nil)
                  {
                      if (block) block(succeeded, comment);
                  }
              }];
         }
     }];
}

- (void)fetchLikersForRequest:(PFObject *)request withBlock:(void (^)(BOOL isLiked, NSArray *objects, NSError *error))block
{
    PFRelation *relation = request[@"likers"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         if (block != nil)
         {
             BOOL doesLike = [objects containsObject:[PFUser currentUser]];
             if (block) block(doesLike, objects, error);
         }
         
     }];
}

- (void)toggleLike:(PFObject *)request
         withBlock:(void (^)(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error))block
{
    [self fetchLikersForRequest:request withBlock:^(BOOL isLiked, NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             NSUInteger oldNumberOfLikes = objects.count;
             int numberOfLikesCalculated = (int) oldNumberOfLikes;
             
             if (isLiked == YES)
             {
                 [self unlikeRequest:request withCompletion:block withLikers:numberOfLikesCalculated - 1];
             }
             else
             {
                 [self likeRequest:request withCompletion:block withLikers:numberOfLikesCalculated + 1];
             }
             
             NSLog(@"should trigger cloud code");
             [PFCloud callFunctionInBackground:@"computeNumberOfLikers"
                                withParameters:@{ @"objectId": request.objectId}
                                         block:nil];
             
         }
         else
         {
             NSLog(@"error: %@", error);
         }
     }];
}

- (void)deleteRequest:(PFObject *)request withBlock:(void (^)(BOOL success, NSError *error))block
{
    PFUser *poster = request[@"poster"];
    NSString *posterId = poster.objectId;
    NSString *currentUserId = [PFUser currentUser].objectId;
    if ([posterId isEqualToString:currentUserId])
    {
        [request deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
         {
             if (error == nil)
             {
                 NSLog(@"deleted message");
                 if (block) block(YES, nil);
             }
             else
             {
                 if (block) block(NO, error);
             }
         }];
    }
    else
    {
        NSLog(@"user does not have permission to delete this request");
        NSLog(@"%@ trying to delete %@ post", poster, currentUserId);
        if (block) block(NO, nil);
    }
}

- (void)blockUser:(PFUser *)user
        withBlock:(void (^)(BOOL success, NSError *error))block;
{
    PFUser *userToFlag = user;
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flagRelation =  [currentUser relationForKey:@"flaggedUsers"];
    [flagRelation addObject:userToFlag];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {
         if (block) block(succeeded, error);
    }];
}

- (void)fetchAllRequests:(void (^)(NSError *error, NSArray *requests))block
{
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *flaggedUserRelation = [currentUser relationForKey:@"flaggedUsers"];
    PFQuery *relationQuery = [flaggedUserRelation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         // objects = all the flagged users
         PFQuery *query = [PFQuery queryWithClassName:@"Request"];
         [query orderByDescending:@"createdAt"];
         [query includeKey:@"poster"];
         [query whereKey:@"building" equalTo:currentUser[@"building"]];
         
         [query whereKey:@"poster" notContainedIn:objects   ];
         [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
          {
              if (block) block(error, objects);
          }];
     }];
}

- (void)fetchImageForUser:(PFUser *)user withBlock:(void (^)(BOOL, UIImage *))block
{
    // returns the cropped image (square)
    if (user[@"profileImage"] != nil)
    {
        // use custom profile image
        [user[@"profileImage"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
         {
             if (error == nil)
             {
                 UIImage *image = [UIImage imageWithData:data];
                 CGFloat size = MIN(image.size.width, image.size.height);
                 image = [self imageByCroppingImage:image toSize:CGSizeMake(size,size)];
                 if (block) block(YES, image);
             }
         }];
    }
    else
    {
        // use FB provided profile picture
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user[@"facebookId"]];
        
        NSURL *url = [NSURL URLWithString:URLString];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager  ];
        [manager downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (error == nil)
             {
                 CGFloat size = MIN(image.size.width, image.size.height);
                 UIImage *cropped_image = [self imageByCroppingImage:image toSize:CGSizeMake(size,size)];
                 if (block) block(YES, cropped_image);
             }
         }];
    }

}

- (void)postMessage:(NSString *)string toUser:(PFUser *)user withCompletion:(void (^)(BOOL success))block
{
    if (user != self.currentUser) {
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"message"] = string;
        message[@"sender"] = self.currentUser;
        message[@"recipient"] = user;
        
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
         {
             [self fetchConversationWithUser:user withCompletion:^(BOOL success, PFObject *conversation) {
                 
                 if (conversation != nil)
                 {
                     PFRelation *relation = [conversation relationForKey:@"messages"];
                     [relation addObject:message];
                     conversation[@"mostRecentMessage"] = message;
                     conversation[@"read"] = [NSNumber numberWithBool:NO];
                     [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                         if (succeeded)
                         {
                             NSLog(@"succesfully added message to an EXISTING conversation");
                             if (block) block(YES);
                         }
                     }];
                 }
                 else
                 {
                     NSLog(@"creating new conversation item");
                     PFObject *conversation = [PFObject objectWithClassName:@"Conversation"];
                     conversation[@"mostRecentMessage"] = message;
                     
                     PFRelation *relation = [conversation relationForKey:@"messages"];
                     [relation addObject:message];
                     NSArray *usersArray = @[self.currentUser, user];
                     conversation[@"users"] = usersArray;
                     [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                         if (succeeded)
                         {
                             NSLog(@"succesfully created a NEW conversation");
                             if (block) block(YES);
                         }
                     }];
                 }
                 
             }];
         }];
    }
}

- (void)fetchConversationWithUser:(PFUser *)user withCompletion:(void (^)(BOOL success, PFObject *conversation))block
{
    NSString *name =  user[@"facebookName"];
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"users" containsAllObjectsInArray:@[self.currentUser, user]];
    [query includeKey:@"mostRecentMessage"];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil)
        {
            if (objects.count > 0)
            {
                if (block) block(YES, [objects firstObject]);
            }
            else
            {
                if (block) block(YES, nil);
                
            }
        }
    }];
}

- (void)fetchAllMessagesForConversation:(PFObject *)conversation withCompletion:(void (^)(BOOL success, NSArray *messages))block
{
    PFRelation *relation = conversation[@"messages"];
    PFQuery *query = [relation query];
    query.limit = 1000; // fix this later to only query the most recent!
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error == nil)
        {
            if (block) block(YES, objects);
        }
    }];
}

- (void)fetchAllMessagesForUser:(PFUser *)user withCompletion:(void (^)(BOOL success, NSArray *messages))block
{
    [self fetchConversationWithUser:user withCompletion:^(BOOL success, PFObject *conversation) {
        if (success) {
            [self fetchAllMessagesForConversation:conversation withCompletion:^(BOOL success, NSArray *messages) {
                if (success)
                {
                    if (block) block(YES, messages);
                }
            }];
        }
    }];
}

- (void)fetchAllConversations:(void (^)(BOOL success, NSArray *conversations))block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query includeKey:@"mostRecentMessage"];
    [query includeKey:@"users"];
    [query whereKey:@"users" containsAllObjectsInArray:@[self.currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
     {
         // filter out the messages sent to oneself
         if (error == nil)
         {
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessage.createdAt" ascending:NO];
             NSArray *sortedArray = [[NSArray alloc] init];
             sortedArray = [objects sortedArrayUsingDescriptors:@[sortDescriptor]];
             
             if (block) block(YES, sortedArray);
         }
         else
         {
             NSLog(@"there is some error");
             if (block) block(NO, objects);
         }
     }];
}

- (void)fetchAllUsersThatHaveMessaged:(void (^)(BOOL success, NSArray *users))block
{
    [self fetchAllUserIdsThatHaveMessaged:^(BOOL success, NSArray *userIds)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"objectId" containedIn:userIds];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (block) block(success, objects);
        }];
        
    }];
}

- (void)fetchMostRecentMessageForUser:(PFUser *)user withCompletion:(void (^)(BOOL success, PFObject *message, BOOL wasRead))block
{
    [self fetchConversationWithUser:user withCompletion:^(BOOL success, PFObject *conversation)
    {
        if (block) block(success, conversation[@"mostRecentMessage"], conversation[@"read"]);
    }];
}

- (void)fetchAllMostRecentMessagesWithCompletion:(void (^)(BOOL success, NSArray *messages))block
{
    NSMutableArray *recentMessages = [[NSMutableArray alloc] init];
    [self fetchAllConversations:^(BOOL success, NSArray *conversations) {
        for (PFObject *conversation in conversations) {
            PFObject *message = conversation[@"mostRecentMessage"];
            [recentMessages addObject:message];
        }
        if (block) block(success, recentMessages);
    }];
}

- (void)fetchAllNotificationsForUser:(PFUser *)user withCompletion:(void (^)(NSError *error, NSArray *notifications))block
{
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
    {
        block(error, objects);
    }];
}


# pragma mark - Private Methods

- (void)likeRequest:(PFObject *)request withCompletion:(void (^)(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error))block withLikers:(int)numberOfLikers
{
    if (block) block(YES, YES, numberOfLikers, nil);
    PFObject *currentUser = [PFUser currentUser];
    PFRelation *relation =  [request relationForKey:@"likers"];
    [relation addObject:currentUser];
    [request saveInBackground];
}

- (void)unlikeRequest:(PFObject *)request withCompletion:(void (^)(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error))block withLikers:(int)numberOfLikers
{
    if (block) block(YES, NO, numberOfLikers, nil);
    PFObject *currentUser = [PFUser currentUser];
    PFRelation *relation =  [request relationForKey:@"likers"];
    [relation removeObject:currentUser];
    [request saveInBackground];
}

- (void)fetchAllUserIdsThatHaveMessaged:(void (^)(BOOL success, NSArray *userIds))block
{
    NSMutableArray *otherUsers = [[NSMutableArray alloc] init];
    [self fetchAllConversations:^(BOOL success, NSArray *conversations)
     {
         if (success)
         {
             for (PFObject *conversation in conversations)
             {
                 NSArray *usersArray = [conversation valueForKey:@"users"];
                 
                 for (PFUser *user in usersArray) {
                     if ([user isEqual:self.currentUser] == NO)
                     {
                         [otherUsers addObject:user.objectId];
                     }
                 }
             }
             block(YES, otherUsers);
         }
     } ];
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


@end
