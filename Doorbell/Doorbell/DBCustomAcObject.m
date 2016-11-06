//
//  DEMOCustomAutoCompleteObject.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import "DBCustomAcObject.h"
#import "Parse.h"

@interface DBCustomAcObject ()
@property (strong) NSString *userName;

@end

@implementation DBCustomAcObject


- (id)initWithUsername:(NSString *)name user:(PFUser *)user
{
    self = [super init];
    if (self) {
        [self setUserName:name];
        [self setUser:user];
    }
    return self;
}

#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return self.userName;
}

@end
