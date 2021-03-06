//
//  DBChatData.h
//  Doorbell
//
//  Created by Steven Petteruti on 4/6/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessages.h"
#import "Parse.h"


static NSString * const kJSQDemoAvatarDisplayNameSquires = @"bob";
static NSString * const kJSQDemoAvatarDisplayNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarDisplayNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarDisplayNameWoz = @"Steve Wozniak";
static NSString * const kJSQDemoAvatarDisplayNameFrom = @"Stevo B";


static NSString * const kJSQDemoAvatarIdSquires = @"bob";
static NSString * const kJSQDemoAvatarIdCook = @"468-768355-23123";
static NSString * const kJSQDemoAvatarIdJobs = @"707-8956784-57";
static NSString * const kJSQDemoAvatarIdWoz = @"309-41802-93823";
static NSString * const kJSQDemoAvatarIdFrom = @"401-68888-90405";


@interface DBChatData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSMutableDictionary *users;

@property (strong, nonatomic) PFUser *userReciever;

- (void)addPhotoMediaMessage;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

- (void)addVideoMediaMessage;

@end