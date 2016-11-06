//
//  DBEventPhotoCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/19/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventPhotoCell.h"
#import "BOTableViewCell+Subclass.h"
#import "FTImageAssetRenderer.h"

@implementation DBEventPhotoCell
{
    UIView *buttonContainer;
}


- (void)setup
{
    self.userInteractionEnabled = YES;
    self.expansionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 216)];
    self.expansionView.userInteractionEnabled = YES;

    self.eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.expansionView.frame.size.width, 216)];
    NSData* rawData = [[NSUserDefaults standardUserDefaults] objectForKey:@"event_image"];
   // NSData *imageData = [NSKeyedUnarchiver unarchiveObjectWithData:rawData];
    UIImage* image = [UIImage imageWithData:rawData];
    self.eventImageView.image = image;
    self.eventImageView.backgroundColor = [UIColor colorWithRed:9/255.0f green:36/255.0f blue:50/255.0f alpha:1.0f];
    self.eventImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.eventImageView.userInteractionEnabled = YES;
    self.eventImageView.clipsToBounds = YES;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];

    [self.expansionView addSubview:self.eventImageView];
    
    buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    buttonContainer.backgroundColor = [UIColor blackColor];
    buttonContainer.userInteractionEnabled = YES;
    button.center = buttonContainer.center;

    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"cross" withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *buttonImage = [renderer imageWithCacheIdentifier:@"white"];
    [button setImage:buttonImage forState:UIControlStateNormal];

    [buttonContainer addSubview:button];
    [self.eventImageView addSubview:buttonContainer];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint locationPoint = [[touches anyObject] locationInView:self.expansionView];
    BOOL withinBounds = CGRectContainsPoint(buttonContainer.bounds, locationPoint);

    if (withinBounds == YES) {
        [self closeButtonPressed];
    }
}

- (void)closeButtonPressed
{
    self.eventImageView.image = nil;
}

- (CGFloat)expansionHeight {
    if (self.eventImageView.image != nil)
    {
        return 216;
    }
    else
    {
        return 0;
    }
}

- (void)setEventImageView:(UIImageView *)eventImageView
{
    _eventImageView = eventImageView;
    if (eventImageView.image != nil)
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Edit" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
        
    }
    else
    {
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Add Photo" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self updateAppearance];
       
    }
}


- (void)wasSelectedFromViewController:(BOTableViewController *)viewController
{
    NSLog(@"was selected");
    [super wasSelectedFromViewController:viewController];

    if (self.eventImageView.image == nil)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        [viewController presentViewController:picker animated:YES completion:nil];
    }
  
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (image != nil)
    {
        self.eventImageView.image = image;
        self.eventImageView = self.eventImageView;

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:image];
        self.setting.value = data;
  
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        ;
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
