//
//  DBEventCreateController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/19/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventCreateController.h"
#import "DBDateTableViewCell.h"
#import "UIViewController+Utils.h"
#import "DBEventPhotoCell.h"
#import "DBLocationCell.h"
#import "DBDescriptionCell.h"
#import "FTImageAssetRenderer.h"
#import "Parse.h"

@implementation DBEventCreateController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)setDefaultForKey:(NSString *)key forClass:(NSString *)class
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    id object = [[NSClassFromString(class) alloc] init];
    
    if ([class isEqualToString:@"UIImage"] || [class isEqualToString:@"CLLocation"])
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[[NSClassFromString(class) alloc] init]];
        [defaults registerDefaults:@{key : data}];
    }
    
    else
    {
        [defaults registerDefaults:@{key : object}]  ;
    }
}

- (void)publishButtonPressed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *event_name = [defaults objectForKey:@"event_name"];
    NSString *event_description = [defaults objectForKey:@"event_description"];
    NSDate *startDate = [defaults objectForKey:@"event_start_date"];
    NSDate *endDate = [defaults objectForKey:@"event_end_date"];
    
    NSData *locationData = [defaults objectForKey:@"event_location"];
    CLLocation *location = [NSKeyedUnarchiver unarchiveObjectWithData:locationData];
    
    NSData *imageData = [defaults objectForKey:@"event_image"];
    UIImage *image = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
    
    if (event_name.length == 0 || event_description.length == 0 || startDate == nil || endDate == nil || location == nil || image == nil)
    {
        NSString *message;
        if (event_name.length == 0) {
            message = @"please enter an event name";
        }
        else if (event_description.length == 0)
        {
            message = @"please enter an event description";
        }
        else if (startDate == nil)
        {
            message = @"please enter a start date";
        }
        else if (endDate == nil)
        {
            message = @"please enter an end date";
        }
        else if (location == nil)
        {
            message = @"please enter a location";
        }
        else if (image == nil)
        {
            message = @"please enter an image";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        
        [alert show];
    }
    else
    {
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        PFFile *file = [PFFile fileWithName:@"event-image" data:UIImageJPEGRepresentation(image, .9)];
        
        event[@"eventTitle"] = event_name;
        event[@"startTime"] = startDate;
        event[@"endTime"] = endDate;
        event[@"eventDescription"] = event_description;
        event[@"eventImage"] = file;
        event[@"creator"] = [PFUser currentUser];
        event[@"location"] = [PFGeoPoint geoPointWithLocation:location];
        event[@"building"] = [PFUser currentUser][@"building"];
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error == nil && [placemarks count] > 0)
             {
                 CLPlacemark *placemark = [placemarks lastObject];
                 event[@"locationString"] = placemark.name;
                 [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
                  {
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"eventPosted" object:nil];
                  }];
             }
         }];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)configureRightButton
{
    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"publish" withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *leftButtonImage= [renderer imageWithCacheIdentifier:@"white"];
    
    renderer.targetColor = [UIColor grayColor];
    UIImage *leftButtonImageDisabled = [renderer imageWithCacheIdentifier:@"gray"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 22, 22);
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    [leftButton setImage:leftButtonImageDisabled forState:UIControlStateDisabled];
    
    [leftButton addTarget:self action:@selector(publishButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc] init];
    [leftButtonItem setCustomView:leftButton];
    
    self.navigationItem.rightBarButtonItem = leftButtonItem;
}



- (void)viewDidAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"event_start_date" options:NSKeyValueObservingOptionNew context:nil];
    //[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"event_end_date" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"event_start_date"];
   // [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"event_end_date"];

}

- (void)setup
{
    [self configureCustomBackButton];
    
    [self configureRightButton];
    
    [self setDefaultForKey:@"event_name" forClass:@"NSString"];
    [self setDefaultForKey:@"event_description" forClass:@"NSString"];
    [self setDefaultForKey:@"event_start_date" forClass:@"NSDate"];
    [self setDefaultForKey:@"event_end_date" forClass:@"NSDate"];
    [self setDefaultForKey:@"event_image" forClass:@"UIImage"];
    [self setDefaultForKey:@"event_location" forClass:@"CLLocation"];
    
    
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"" handler:^(BOTableViewSection *section) {
        
        [section addCell:[BOTextTableViewCell cellWithTitle:@"Event Name" key:@"event_name" handler:^(BOTextTableViewCell *cell) {
            cell.textField.placeholder = @"Add Event Name";
            cell.inputErrorBlock = ^(BOTextTableViewCell *cell, BOTextFieldInputError error) {
            };
        }]];
        
        [section addCell:[BODateTableViewCell cellWithTitle:@"Date" key:@"event_start_date" handler:nil]];
        [section addCell:[DBDateTableViewCell cellWithTitle:@"Start time" key:@"event_start_date" handler:nil]];
        [section addCell:[DBDateTableViewCell cellWithTitle:@"End time" key:@"event_end_date" handler:nil]];
    }]];
    
    [self addSection:[BOTableViewSection sectionWithHeaderTitle:@"Details" handler:^(BOTableViewSection *section)
                      {
                          
                          [section addCell:[DBEventPhotoCell cellWithTitle:@"Photo" key:@"event_image" handler:^(DBEventPhotoCell *cell)
                                            {
                                                
                                            }]];
                          [section addCell:[DBLocationCell cellWithTitle:@"Location" key:@"event_location" handler:^(DBLocationCell *cell)
                                            {
                                                __weak typeof(cell) weakCell = cell;
                                                LocationPicker *locationPicker = [[LocationPicker alloc] init];
                                                UIBarButtonItem *cancelButton = [UIBarButtonItem new];
                                                [locationPicker addBarButtons:nil cancelButtonItem:cancelButton doneButtonOrientation:nil];
                                                
                                                weakCell.locationPicker = locationPicker;
                                                weakCell.destinationViewController = locationPicker;
                                                locationPicker.delegate = weakCell;
                                                
                                            }]];
                          
                          [section addCell:[DBDescriptionCell cellWithTitle:@"" key:@"event_description" handler:^(DBDescriptionCell *cell)
                                            {
                                                cell.textField.placeholder = @"Add Event Description";
                                                
                                                
                                            }]];
                          
                          
                      }]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (object == defaults)
    {
        // Here you can grab the values or just respond to it with an action.
        NSDate *startDate = [defaults objectForKey:@"event_start_date"];
        NSDate *endDate = [defaults objectForKey:@"event_end_date"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        //gather date components from date
        NSDateComponents *startDateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:startDate];
        NSDateComponents *endDateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:endDate];
        
        
        //set date components
        [endDateComponents setDay:startDateComponents.day];
        [endDateComponents setMonth:startDateComponents.month];
        [endDateComponents setYear:startDateComponents.year];
        
        //save date relative from date
        NSDate *newEndDate = [calendar dateFromComponents:endDateComponents];
        [defaults setObject:newEndDate forKey:@"event_end_date"];
        
       
    }
}


@end
