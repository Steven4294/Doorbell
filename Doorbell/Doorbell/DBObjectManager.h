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

- (void)postCommentWithString:(NSString *)commentString
                    toRequest:(PFObject *)request
                     fromUser:(PFUser *)poster
               withCompletion:(void(^)(BOOL success, PFObject *comment))block;

- (void)fetchLikersForRequest:(PFObject *)request
                    withBlock:(void (^)(BOOL isLiked, NSArray *objects, NSError *error))block;

// @param isLiked: determines whether you have liked or unliked the object
- (void)toggleLike:(PFObject *)request
          withBlock:(void (^)(BOOL success, BOOL wasLiked, NSError *error))block;

- (void)deleteRequest:(PFObject *)request
            withBlock:(void (^)(BOOL success, NSError *error))block;

- (void)blockUser:(PFUser *)user
        withBlock:(void (^)(BOOL success, NSError *error))block;



@end




