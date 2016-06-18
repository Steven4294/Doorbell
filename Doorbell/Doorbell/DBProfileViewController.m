//
//  DBProfileViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 2/2/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBProfileViewController.h"
#import "Parse.h"
#import "DBTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "DBLoginViewController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "UIImageView+Profile.h"
#import "DBProfileEditViewController.h"
#import "FTImageAssetRenderer.h"
#import "UIColor+FlatColors.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DBCommentViewController.h"

@interface DBProfileViewController ()
{
    NSMutableArray *userRequests;
}


@end

@implementation DBProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *currentUser = [PFUser currentUser];
    
    [self setupProfilePicture];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.title = @"profile";
    
    if (currentUser[@"facebookName"] != nil)
    {
        self.nameLabel.text = currentUser[@"facebookName"];
    }
    
    [self retrieveUsersRequests];
    /*
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 22, 22);
    [rightButton setImage:[UIImage imageNamed:@"Chat_white.png"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc] init];
    [rightButtonItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
     */
    
    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"pencil" withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *image = [renderer imageWithCacheIdentifier:@"white"];
    [self.editImageButton setImage:image];
    self.editImageButton.layer.cornerRadius = self.editImageButton.frame.size.width/2;
    self.editImageButton.layer.borderColor = self.editImageButton.superview.backgroundColor.CGColor;
    self.editImageButton.backgroundColor = [UIColor flatTurquoiseColor];

    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editButtonPressed:)];
    [self.editImageButton addGestureRecognizer:gesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileImage) name:@"updatedProfileImage" object:nil];
}

- (void)updateProfileImage
{
    [self.tableView reloadData];
    [self setupProfilePicture];
}

- (void)retrieveUsersRequests
{
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"poster" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            // The find succeeded.
            // Do something with the found objects
            userRequests = [objects mutableCopy];
            [self.tableView reloadData];

            if (userRequests.count == 1)
            {
                self.numberOfRequests.text = @"1 post";
            }
            else if (userRequests.count > 100)
            {
                self.numberOfRequests.text = @"100+ posts";
            }
            else
            {
                self.numberOfRequests.text = [NSString stringWithFormat:@"%lu posts", (unsigned long)userRequests.count];
            }
            
        }
        else
        {
            // Log details of the failure
        }
    }];
}

- (void)setupProfilePicture
{
    [self.profileImage setProfileImageViewForUser:[PFUser currentUser] isCircular:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(profileImageTapped:)];
    [self.profileImage addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)profileImageTapped:(id)sender
{
    // Light Box the profile image
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = self.profileImage.image;
    imageInfo.referenceRect = self.profileImage.frame;
    imageInfo.referenceView = self.profileImage.superview;
    imageInfo.referenceContentMode = self.profileImage.contentMode;
    imageInfo.referenceCornerRadius = self.profileImage.layer.cornerRadius;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if ([userRequests count] > indexPath.row)
    {
        PFObject *object = [userRequests objectAtIndex:indexPath.row];
        cell.requestObject = object;
    }
    
    UILongPressGestureRecognizer *commentGesture = [[UILongPressGestureRecognizer alloc] init];
    commentGesture.minimumPressDuration = 0.0f;
    [commentGesture addTarget:self action:@selector(commentLabelWasTapped:)];
    [cell.commentLabel addGestureRecognizer:commentGesture];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBTableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self openCommentsViewController:cell];
}

- (void)openCommentsViewController:(DBTableViewCell *)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBCommentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBCommentViewController"];
    vc.likersArray = cell.likersArray;
    vc.request = cell.requestObject;
    
    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark - Actions

- (void)editButtonPressed:(id)sender
{
    UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *fileName = [NSString stringWithFormat:@"%@.png", @"facebookName"];
    PFFile *file = [PFFile fileWithName:fileName data:UIImageJPEGRepresentation(image, .9)];
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"profileImage"] = file;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedProfileImage" object:nil];
     }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)commentLabelWasTapped:(UIGestureRecognizer *)gesture
{
    CGPoint swipeLocation = [gesture locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    DBTableViewCell* tappedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        tappedCell.commentLabel.alpha = .5;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        tappedCell.commentLabel.alpha = 1.0f;
        [self openCommentsViewController:tappedCell];
    }
    else
    {
        tappedCell.commentLabel.alpha = 1.0f;
    }
}

@end
