//
//  DBLocationCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/20/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Bohr/Bohr.h>
#import "Doorbell-Swift.h"

@interface DBLocationCell : BOTableViewCell <LocationPickerDelegate>

@property (nonatomic, strong) LocationPicker *locationPicker;

@end
