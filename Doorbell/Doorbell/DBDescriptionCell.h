//
//  DBDescriptionCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 7/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <Bohr/Bohr.h>

#import "JVFloatLabeledTextField.h"

@interface DBDescriptionCell : BOTableViewCell 

/**
 * Block type defining an input error that has ocurred in the cell text field.
 *
 * @param cell the cell affected by the input error.
 * @param error the received input error.
 */

/// The text field on the cell.
//@property (nonatomic) UITextField *textField;
@property (nonatomic) JVFloatLabeledTextField *textField;


/// The minimum amount of non-blank characters necessary for the text field.
@property (nonatomic) NSInteger minimumTextLength;

/// A block defining an input error that has ocurred in the cell text field.
@property (nonatomic, copy) BOTextFieldInputErrorBlock inputErrorBlock;

@end