//
//  DBPerkCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/25/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBPerkCell.h"
#import "Parse.h"
#import "DBLocationManager.h"
#import "DBObjectManager.h"

@implementation DBPerkCell

- (void)setDeal:(PFObject *)deal
{
    _deal = deal;
    
    self.dealImageView.clipsToBounds = YES;
    [deal[@"image"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         [self.dealImageView setImage:[UIImage imageWithData:data]];
     }];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.separatorInset = UIEdgeInsetsMake(0.f, self.bounds.size.width, 0.f, 0.f);
    
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.layer.borderWidth = 8.0f;
    
    self.topLabel.text = [NSString stringWithFormat:@"%@ ∙ %@", deal[@"description"], deal[@"businessName"]];
    
    PFGeoPoint *location = deal[@"location"];
    CLLocation *location_CL = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    PFGeoPoint *currentLocation =  [PFGeoPoint geoPointWithLocation:[[DBLocationManager sharedInstance] currentLocation]];
    double distance = [location distanceInMilesTo:currentLocation];
    NSString *distanceSubstring = [NSString stringWithFormat:@"%.1f", distance];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location_CL completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             
             NSArray *localityArray = [self subLocalityArray:placemark];
             
             NSString *local = [self secondToLastObject:localityArray]    ;
            
             
             self.bottomLabel.text = [NSString stringWithFormat:@"%@ ∙ %@ mi", local, distanceSubstring];
         }
         
     }];
    
    NSLog(@"%@ isOpen? %d",  self.deal[@"businessName"], [self.deal isBusinessOpen]);
}

- (id)secondToLastObject:(NSArray *)array
{
    id lastObject = [array lastObject];
    NSMutableArray *mutableCopy = [array mutableCopy];
    [mutableCopy removeObject:lastObject];
    id secondToLast = [mutableCopy lastObject];
    if (secondToLast)
    {
        return secondToLast;
    }
    else
    {
        return lastObject;
    }
}

- (NSArray *)subLocalityArray:(CLPlacemark *)placemark
{
    NSString *geoMapItem = placemark.description;
    NSRange start = [geoMapItem rangeOfString:@"dependentLocality"];
    NSRange end = [geoMapItem rangeOfString:@")" options:NSCaseInsensitiveSearch range:NSMakeRange(start.location, 1000)];
    NSString *dataString = [geoMapItem substringWithRange:NSMakeRange(start.location, end.location - start.location + end.length)];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"  " withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    start = [dataString rangeOfString:@"("];
    end = [dataString rangeOfString:@")"];
    NSString *arrayString = [dataString substringWithRange:NSMakeRange(start.location + 1, end.location - start.location - 1)];
    
    NSArray *array = [arrayString componentsSeparatedByString:@","];
    return array;
}

@end
