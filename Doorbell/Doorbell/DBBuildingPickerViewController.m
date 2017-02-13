//
//  DBBuildingPickerViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/12/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBuildingPickerViewController.h"
#import "UIViewController+Utils.h"
#import "Parse.h"
#import "DBObjectManager.h"
#import "DBSideMenuController.h"

#import "MMPopupItem.h"
#import "MMAlertView.h"
#import "MMSheetView.h"
#import "MMPopupWindow.h"

@implementation DBBuildingPickerViewController
{
    NSArray *buildingsArray;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBackButtonOnView];
    self.buildingPickerView.delegate = self;
    self.buildingPickerView.dataSource = self;
    self.nextButton.layer.cornerRadius = 5.0f;
    [self.nextButton addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self fetchBuildings];

    self.noBuildingLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    [gesture addTarget:self action:@selector(noBuildingLabelPressed)];
    [self.noBuildingLabel addGestureRecognizer:gesture];
}

- (void)noBuildingLabelPressed
{
    [self presentFeedForBuilding:@""];
}

- (void)fetchBuildings
{
    buildingsArray = [[NSArray alloc] init];
    [[DBObjectManager sharedInstance] fetchAllBuildings:^(NSError *error, NSArray *buildings)
    {
        buildingsArray = buildings;
        [self.buildingPickerView reloadAllComponents];
    }];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"buildings arraY: %@", buildingsArray   );
    PFObject *building = [buildingsArray objectAtIndex:row];
    NSString *title = building[@"buildingLongName"];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    return attString;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return buildingsArray.count;
}

- (void)nextButtonPressed
{    
    [self promptUserForCode];
}

- (void)presentFeedForBuilding:(NSString *)building
{
    // also updates the user
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"building"] = building;
    currentUser[@"verifiedCode"] = [NSNumber numberWithBool:YES];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {
         [self presentFeed];
     }];
}

- (void)promptUserForCode
{
    NSUInteger row = [self.buildingPickerView selectedRowInComponent:0];
    PFObject *building = [buildingsArray objectAtIndex:row];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithInputTitle:@"Building Code" detail:@"Input Dialog" placeholder:@"enter building code" handler:^(NSString *text)
                              {
                                  BOOL correctCode = [[DBObjectManager sharedInstance] isCodeValid:text forBuilding:building];
                                  
                                  if (correctCode == YES)
                                  {
                                      [self presentFeedForBuilding:building[@"buildingName"]];
                                  }
                                  else
                                  {
                                      [self showIncorrectCodeAlert];
                                  }
                              }];
    alertView.tintColor = [UIColor blackColor];
    alertView.attachedView = self.view;
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleExtraLight;
    [alertView showWithBlock:nil];
}

- (void)presentFeed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBSideMenuController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBSideMenuController"];
    [self presentViewController:vc animated:YES completion:^{}];
}

- (void)showIncorrectCodeAlert
{
    MMPopupItemHandler block = ^(NSInteger index)
    {
        [self promptUserForCode];
        
    };
    
    NSArray *items =
    @[
      MMItemMake(@"Cancel", MMItemTypeNormal, block)];
    
    MMAlertView *alertView = [[MMAlertView alloc] initWithTitle:@"Invalid code"
                                                         detail:@"sorry that is incorrect!"
                                                          items:items];
    alertView.attachedView.mm_dimBackgroundBlurEnabled = NO;
    alertView.attachedView.mm_dimBackgroundBlurEffectStyle = UIBlurEffectStyleLight;
    [alertView show];
}

@end
