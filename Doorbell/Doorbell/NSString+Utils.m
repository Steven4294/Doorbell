//
//  NSString+Utils.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/6/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)firstName
{
    NSArray *components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *string = [components objectAtIndex:0];
    return string;
}

- (NSString *)lastName
{
    NSArray *components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSUInteger count = components.count;
    if (count > 1) {
        NSString *string = [components objectAtIndex:count-1];
        return string;
    }
    else
    {
        return nil;
    }
}

- (NSString *)firstNameLastInitial
{
    NSString *firstName = [self firstName];
    NSString *lastName = [self lastName];
    if (lastName.length > 0)
    {
        NSString *initial = [lastName substringToIndex:1];
        return [NSString stringWithFormat:@"%@ %@", firstName, initial];
    }
    else
    {
        return firstName;
    }
}

@end
