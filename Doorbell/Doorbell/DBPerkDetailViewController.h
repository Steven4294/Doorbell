//
//  DBPerkDetailViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/26/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PFObject;

@interface DBPerkDetailViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) PFObject *deal;
@property (nonatomic, strong) IBOutlet UIImageView *dealImageView;
@property (nonatomic, strong) IBOutlet UIView *topView;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *dealLabel;


@end
