//
//  DBBuildingPickerViewController.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/12/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBBuildingPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) IBOutlet UIPickerView *buildingPickerView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UILabel *noBuildingLabel;

@end
