 //
//  DBEventBottomCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventBottomCell.h"
#import "Parse.h"

@implementation DBEventBottomCell

- (void)setEvent:(PFObject *)event
{
    _event = event;
    
    PFGeoPoint *location = event[@"location"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    self.mapView.clipsToBounds = YES;
    [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(.0015f, .0015f))];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinate;
    pin.title = @"Event"    ;
    [self.mapView addAnnotation:pin];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    
    [geocoder reverseGeocodeLocation:locationCL completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        
        if (placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark = placemarks[0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            
            NSArray *addressLines = [addressDictionary objectForKey:@"FormattedAddressLines"];
            NSString *name = event[@"locationString"];
            
            NSString *street= @"";
            NSString *zipcode = @"";
            NSString *country = @"";
            
            if (addressDictionary.count > 0)
            {
                street = [addressLines objectAtIndex:0];
            }
            if (addressDictionary.count > 1)
            {
                zipcode = [addressLines objectAtIndex:1];
            }
            if (addressDictionary.count > 2)
            {
                country = [addressLines objectAtIndex:2];
            }
            
            NSString *addressString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", name, street, zipcode, country];
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:addressString];
            NSDictionary *dict = @{NSForegroundColorAttributeName: [UIColor grayColor]};
            
            [attr addAttributes:dict range:NSMakeRange(name.length, attr.length - name.length)];
            
            self.locationLabel.attributedText = [attr copy];
        }
    }];
}

@end
