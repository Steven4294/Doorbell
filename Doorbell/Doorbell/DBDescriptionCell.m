//
//  DBDescriptionCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBDescriptionCell.h"
#import "BOTableViewCell+Subclass.h"

@interface DBDescriptionCell () <UITextFieldDelegate>

@end

@implementation DBDescriptionCell

- (void)setup {
    self.tintColor = [UIColor lightGrayColor];
    
    self.textField = [[JVFloatLabeledTextField alloc] init];
    self.textField.delegate = self;
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.frame = CGRectMake(self.separatorInset.left, 0, self.frame.size.width, self.frame.size.height + 10.0f);
  
    self.textField.floatingLabelActiveTextColor = self.textField.floatingLabelTextColor;
    [self addSubview:self.textField];

    
}

- (void)updateAppearance {
    self.textField.textColor = self.secondaryColor;
    self.textField.tintColor = self.secondaryColor;
    
    if (self.secondaryFont) {
        self.textField.font = self.secondaryFont;
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes:@{NSFontAttributeName : self.secondaryFont}];
    }
}

- (void)settingValueDidChange {
    self.textField.text = self.setting.value;
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"text field began editing");
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    
    return YES;
}

- (NSString *)textFieldTrimmedText {
    return [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    BOTextFieldInputError error = [self validateTextFieldInput:[self textFieldTrimmedText]];
    
    if (error != BOTextFieldInputNoError) {
        [self resetTextFieldAndInvokeInputError:error];
    } else {
        self.setting.value = [self settingValueForInput:textField.text];
    }
}

- (BOTextFieldInputError)validateTextFieldInput:(NSString *)input {
    return input.length < self.minimumTextLength ? BOTextFieldInputTooShortError : BOTextFieldInputNoError;
}

- (void)resetTextFieldAndInvokeInputError:(BOTextFieldInputError)error {
    [self settingValueDidChange];
    if (self.inputErrorBlock) self.inputErrorBlock(self, error);
}

- (id)settingValueForInput:(NSString *)input {
    return [self textFieldTrimmedText];
}

@end
