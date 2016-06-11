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

@end
