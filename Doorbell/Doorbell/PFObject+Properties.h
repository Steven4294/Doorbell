//
//  PFObject+Properties.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/26/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (Properties)

- (NSDate *)openingTimeAsDate;

- (NSDate *)closingTimeAsDate;

- (NSString *)openingTimeAsString;

- (NSString *)closingTimeAsString;

- (BOOL)isBusinessOpen;

@end
