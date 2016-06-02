//
//  DBObjectManager.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBObjectManager.h"

@implementation DBObjectManager

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
             [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
              {
                  if (error == nil)
                  {
                      if (block) block(succeeded, comment);
                      NSLog(@"saved comment to backend");
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
         withBlock:(void (^)(BOOL success, BOOL wasLiked, NSError *error))block
{
    [self fetchLikersForRequest:request withBlock:^(BOOL isLiked, NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if (isLiked == YES)
             {
                 [self unlikeRequest:request withCompletion:block];
             }
             else
             {
                 [self likeRequest:request withCompletion:block];
             }
         }
         else
         {
             NSLog(@"error: %@", error);
         }
     }];
}

- (void)deleteRequest:(PFObject *)request withBlock:(void (^)(BOOL success, NSError *error))block;

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
         
         [query whereKey:@"poster" notContainedIn:objects   ];
         [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
         {
                 if (block) block(error, objects);
         }];
     }];
}

# pragma mark - Internal Methods

- (void)likeRequest:(PFObject *)request withCompletion:(void (^)(BOOL success, BOOL wasLiked, NSError *error))block
{
    if (block) block(YES, YES, nil);
    PFObject *currentUser = [PFUser currentUser];
    PFRelation *relation =  [request relationForKey:@"likers"];
    [relation addObject:currentUser];
    [request saveInBackground];
}

- (void)unlikeRequest:(PFObject *)request withCompletion:(void (^)(BOOL success, BOOL wasLiked, NSError *error))block
{
    if (block) block(YES, NO, nil);
    PFObject *currentUser = [PFUser currentUser];
    PFRelation *relation =  [request relationForKey:@"likers"];
    [relation removeObject:currentUser];
    [request saveInBackground];
}

@end
