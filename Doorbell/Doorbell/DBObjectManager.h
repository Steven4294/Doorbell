//
//  DBObjectManager.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse.h"

@interface DBObjectManager : NSObject

//
//  Posting APIs
//

- (void)postCommentWithString:(NSString *)commentString
                    toRequest:(PFObject *)request
                     fromUser:(PFUser *)poster
               withCompletion:(void(^)(BOOL success, PFObject *comment))block;

/*
 *  @param wasLiked: determines whether you have liked or unliked the object
 */
- (void)toggleLike:(PFObject *)request
         withBlock:(void (^)(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error))block;

- (void)deleteRequest:(PFObject *)request
            withBlock:(void (^)(BOOL success, NSError *error))block;

- (void)blockUser:(PFUser *)user
        withBlock:(void (^)(BOOL success, NSError *error))block;

- (void)postMessage:(NSString *)string toUser:(PFUser *)user withCompletion:(void (^)(BOOL success))block;

//
//  Fetching APIs
//

- (void)fetchLikersForRequest:(PFObject *)request
                    withBlock:(void (^)(BOOL isLiked, NSArray *objects, NSError *error))block;

- (void)fetchAllRequests:(void (^)(NSError *error, NSArray *requests))block;

- (void)fetchImageForUser:(PFUser *)user withBlock:(void (^)(BOOL success, UIImage *image))block;

- (void)fetchConversationWithUser:(PFUser *)user withCompletion:(void (^)(BOOL success, PFObject *conversation))block;

- (void)fetchAllMessagesForUser:(PFUser *)user withCompletion:(void (^)(BOOL success, NSArray *messages))block;

- (void)fetchAllConversations:(void (^)(BOOL success, NSArray *conversations))block;

- (void)fetchAllUsersThatHaveMessaged:(void (^)(BOOL success, NSArray *users))block;

- (void)fetchMostRecentMessageForUser:(PFUser *)user withCompletion:(void (^)(BOOL success, PFObject *message, BOOL wasRead))block;

- (void)fetchAllMostRecentMessagesWithCompletion:(void (^)(BOOL success, NSArray *messages))block;


@end




