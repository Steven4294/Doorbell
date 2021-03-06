//
//  DBEventDetailViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventDetailViewController.h"
#import "UIViewController+Utils.h"
#import "DBEventTopCell.h"
#import "DBEventMiddleCell.h"
#import "DBEventBottomCell.h"
#import "Parse.h"
#import "DBEventCreateController.h"

@implementation DBEventDetailViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self configureCustomBackButton];
    [self configureRightButton];
}

- (void)configureRightButton
{
    if ([self.event[@"creator"] isEqual:[PFUser currentUser]])
    {
        UIBarButtonItem *rightButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

- (void)editButtonPressed
{
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:
                            
                            nil];
    [popup showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex)
    {
        case 0:
            [self deleteEvent];
            break;
            
        default:
            break;
    }
}

- (void)deleteEvent
{

    [self.event deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventDelete" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

# pragma mark - CollectionView Datasource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        DBEventTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topCell" forIndexPath:indexPath];
        cell.event = self.event;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(titleLableTapped:)];
        [cell.titleLabel addGestureRecognizer:tapGesture];
        
        return cell;
    }
    else if (indexPath.row == 1)
    {
        DBEventMiddleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"middleCell" forIndexPath:indexPath];
        cell.event = self.event;
        return cell;
    }
    else if (indexPath.row == 2)
    {
        DBEventBottomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bottomCell" forIndexPath:indexPath];
        cell.event = self.event;
        cell.mapView.delegate = self;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)];
        [cell.mapView addGestureRecognizer:tapGesture];
        return cell;
    }
    else
    {
        // something broke
        return nil  ;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat width = self.view.frame.size.width - 15.0f;
    
    if (indexPath.row == 0)
    {
        return CGSizeMake(width, 230);
    }
    else if (indexPath.row == 1)
    {
        return CGSizeMake(width, 313);

    }
    else if (indexPath.row == 2)
    {
        return CGSizeMake(width, 341);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}

- (void)titleLableTapped:(id)sender
{
    NSLog(@"title label tapped URL");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.doorbell.me/#!events/dxtmc"]];

}

- (void)mapViewTapped:(id)sender

{
    PFGeoPoint *location = self.event[@"location"];
    CLLocation *locationCL = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];

    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:locationCL completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@"\n"];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        MKPlacemark *placemarkToDisplay = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:placemark.addressDictionary];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemarkToDisplay];
        [item openInMapsWithLaunchOptions:nil];
    }];
    

}

@end
