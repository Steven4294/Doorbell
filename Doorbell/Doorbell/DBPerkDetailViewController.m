//
//  DBPerkDetailViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/26/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBPerkDetailViewController.h"
#import "UIViewController+Utils.h"
#import "UIScrollView+TwitterCover.h"
#import "DBObjectManager.h"

@implementation DBPerkDetailViewController
{
    CGFloat imageViewHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    [self configureCustomBackButton];
    self.dealImageView.layer.borderColor = [UIColor blueColor].CGColor;
    self.dealImageView.layer.borderWidth = 1.0f;
    self.dealImageView.clipsToBounds = YES;
    self.dealImageView.hidden = YES;

    self.dealImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    imageViewHeight = self.dealImageView.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, 940.0f);
    self.topView.layer.borderWidth = 1.0f;
    self.topView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    self.mapView.clipsToBounds = YES;
    self.mapView.delegate = self;
    PFGeoPoint *location = self.deal[@"location"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    [self.mapView setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(.01f, .01f))];
    
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = coordinate;
    pin.title = self.deal[@"businessName"]    ;
    [self.mapView addAnnotation:pin];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    NSLog(@"location: %f x %f : %@", coordinate.latitude, coordinate.longitude, self.mapView);
    
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
            NSString *street = [addressLines objectAtIndex:0];
            NSString *zipcode = [addressLines objectAtIndex:1];
            NSString *country = [addressLines objectAtIndex:2];
            
            NSString *addressString = [NSString stringWithFormat:@"%@\n%@\n%@", street, zipcode, country];
            self.addressLabel.text = addressString;
            //  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:addressString];
            //  NSDictionary *dict = @{NSForegroundColorAttributeName: [UIColor grayColor]};
            
            //  [attr addAttributes:dict range:NSMakeRange(name.length, attr.length - name.length)];
            
        }
    }];
    
    self.dealLabel.text = self.deal[@"description"];
    self.descriptionLabel.text = self.deal[@"instruction"];
    self.titleLabel.text = self.deal[@"businessName"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ — %@", [self.deal openingTimeAsString], [self.deal closingTimeAsString]];
    
}

- (void)viewWillAppear:(BOOL)animated
{

  
}

- (void)viewWillDisappear:(BOOL)animated
{
   // self.navigationController.navigationBar.hidden = NO;
}

- (void)setDeal:(PFObject *)deal
{
    _deal = deal;
    
    [deal[@"image"] getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         NSLog(@"got data");
         UIImage *image = [UIImage imageWithData:data];
         [self.dealImageView setImage:image];
         
         [self.scrollView addTwitterCoverWithImage:image];

     }];
    

    

}

# pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   CGFloat offset = scrollView.contentOffset.y;
    CGFloat percentage = offset / scrollView.contentSize.height;

    //NSLog(@"offset %f", offset);
    if (offset < 0) {
        
        self.dealImageView.center = CGPointMake(self.dealImageView.center.x, self.dealImageView.center.y - percentage * 10);
        
    } else if (offset > 0){
        
        self.dealImageView.center = CGPointMake(self.dealImageView.center.x, self.dealImageView.center.y + percentage * 10);
        
    }
    
}


@end
