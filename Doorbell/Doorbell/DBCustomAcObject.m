//
//  DEMOCustomAutoCompleteObject.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import "DBCustomAcObject.h"

@interface DBCustomAcObject ()
@property (strong) NSString *countryName;
@end

@implementation DBCustomAcObject


- (id)initWithCountry:(NSString *)name
{
    self = [super init];
    if (self) {
        [self setCountryName:name];
    }
    return self;
}

#pragma mark - MLPAutoCompletionObject Protocl

- (NSString *)autocompleteString
{
    return self.countryName;
}

@end
