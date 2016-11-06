//
//  DBEventPhotoCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/19/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bohr/Bohr.h>

@interface DBEventPhotoCell : BOTableViewCell <UIImagePickerControllerDelegate>

@property (nonatomic) UIDatePicker *datePicker;
@property (nonatomic) UIImageView *eventImageView;
- (void)wasSelectedFromViewController:(BOTableViewController *)viewController;

@end
