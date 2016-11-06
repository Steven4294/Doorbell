//
//  DBLocationCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/20/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLocationCell.h"
#import "BOTableViewCell+Subclass.h"
#import "Doorbell-Swift.h"


@implementation DBLocationCell

- (void)locationDidPick:(LocationItem *)locationItem
{
    NSLog(@"location picked");
    CLLocation *location = locationItem.mapItem.placemark.location;
    
   // [self.destinationViewController.navigationController popViewControllerAnimated:YES];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.setting setValue:[NSKeyedArchiver archivedDataWithRootObject:location]];
    }];
    
    [self.destinationViewController.navigationController popViewControllerAnimated:YES];
    
    [CATransaction commit];
    
}

- (void)settingValueDidChange
{
    CLLocation *location  = [NSKeyedUnarchiver unarchiveObjectWithData:[self.setting value]] ;
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             self.detailTextLabel.text = placemark.name;
         }
     }];
}

@end
