//
//  DBLocationManager.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLocationManager.h"
#import "Parse.h"

@interface DBLocationManager ()

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) CLLocationManager *CLLocationManager;


@end

@implementation DBLocationManager

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _currentUser = [self currentUser];
        _CLLocationManager = [self CLLocationManager];
    }
    return self;
}

- (CLLocationManager *)CLLocationManager
{
    if (_CLLocationManager == nil)
    {
        _CLLocationManager = [[CLLocationManager alloc] init];
        [_CLLocationManager requestWhenInUseAuthorization];
        _CLLocationManager.delegate = self;
        _CLLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // Set a movement threshold for new events.
        _CLLocationManager.distanceFilter = 500; // meters
        
        NSLog(@"going to update locations %d", [CLLocationManager authorizationStatus]);
        [_CLLocationManager startUpdatingLocation];
    }
    
    return _CLLocationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation* location = [locations lastObject];
    self.currentLocation = location;
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    // If the event is recent, do something with it.
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location manager failed with error: %@", [error description]);
}


@end
