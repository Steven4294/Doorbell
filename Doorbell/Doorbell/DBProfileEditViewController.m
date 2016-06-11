//
//  DBProfileEditViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBProfileEditViewController.h"
#import "Parse.h"
#import "UIImageView+Profile.h"

@interface DBProfileEditViewController ()

@property (nonatomic, strong) UIImage *chosenImage;

@end

@implementation DBProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Profile";
    
    [self.profileImage setProfileImageViewForUser:[PFUser currentUser] isCircular:YES];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTapped)];
    [self.profileImage addGestureRecognizer:gesture];
}

- (void)profileImageTapped
{
    NSLog(@"profile image tapped");
    UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.profileImage.image = self.chosenImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonPressed:(id)sender
{
    if (self.chosenImage)
    {
        NSString *fileName = [NSString stringWithFormat:@"%@.png", @"facebookName"];
        PFFile *file = [PFFile fileWithName:fileName data:UIImageJPEGRepresentation(self.chosenImage, .9)];
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"profileImage"] = file;
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedProfileImage" object:nil];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
