//
//  DEMOCustomAutoCompleteObject.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import "DBCustomAcObject.h"

@interface DBCustomAcObject ()
@property (strong) NSString *userName;

@end

@implementation DBCustomAcObject


- (id)initWithUsername:(NSString *)name objectId:(NSString *)objectId
{
    self = [super init];
    if (self) {
        [self setUserName:name];
        [self setObjectId:objectId];

    }
    return self;
}

#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return self.userName;
}

@end
