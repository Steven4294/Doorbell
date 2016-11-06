//
//  DBEventCreateController.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/19/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bohr/Bohr.h>
#import "Doorbell-Swift.h"

@class PFObject;

@interface DBEventCreateController : BOTableViewController <LocationPickerDelegate>

@property (nonatomic, strong) PFObject *event;

@end
