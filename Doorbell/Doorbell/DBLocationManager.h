//
//  DBLocationManager.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DBLocationManager : NSObject  <CLLocationManagerDelegate>

+ (id)sharedInstance;

@property (nonatomic, strong) CLLocation *currentLocation;

@end
