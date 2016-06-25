//
//  DBEventDetailViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PFObject;

@interface DBEventDetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate>

@property (nonatomic, strong) PFObject *event;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@end
