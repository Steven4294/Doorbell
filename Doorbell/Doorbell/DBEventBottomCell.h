//
//  DBEventBottomCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PFObject;

@interface DBEventBottomCell : UICollectionViewCell

@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
