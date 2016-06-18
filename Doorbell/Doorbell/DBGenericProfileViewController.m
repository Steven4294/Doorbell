//
//  DBGenericProfileViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/28/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBGenericProfileViewController.h"
#import "Parse.h"

#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "DBTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "DBMessageViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "UIImageView+Profile.h"
#import "DBCommentViewController.h"
#import "UIViewController+Utils.h"

@interface DBGenericProfileViewController ()
{
    NSMutableArray *userRequests;
}
@end

@implementation DBGenericProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self configureCustomBackButton];

    [self.profileImage setProfileImageViewForUser:self.user isCircular:YES];
    
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor ;
    self.profileImage.layer.borderWidth = 0.0f;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(profileImageTapped:)];
    [self.profileImage addGestureRecognizer:tapRecognizer];
    
    [self retrieveUsersRequests];
    self.nameLabel.text = self.user[@"facebookName"];
    
    self.numberOfPosts.layer.borderColor = [UIColor colorWithWhite:.85f alpha:1.0f].CGColor;
    self.numberOfPosts.layer.borderWidth = 1.0f;
    self.numberOfPosts.layer.cornerRadius = 4.0f;
    self.numberOfPosts.clipsToBounds = YES;
    
    [self.chatButton addTarget:self action:@selector(chatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)chatButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBMessageViewController *messageVC = [storyboard instantiateViewControllerWithIdentifier:@"DBMessageViewController"];
    
    messageVC.userReciever = self.user;
    messageVC.senderId = [PFUser currentUser].objectId;
    messageVC.senderDisplayName = @"display name";
    messageVC.automaticallyScrollsToMostRecentMessage = YES;
    
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)retrieveUsersRequests
{
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"poster" equalTo:self.user];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            userRequests = [objects mutableCopy];
            
            NSUInteger postsCount = objects.count;
            if (postsCount == 1)
            {
                self.numberOfPosts.text = @"1 post";
            }
            else
            {
                self.numberOfPosts.text = [NSString stringWithFormat:@"%lu posts", (unsigned long)postsCount];
            }
            
            [self.tableView reloadData];
        }
        else
        {
            // Log details of the failure
        }
    }];
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

- (void)cellImageViewTapped:(id)sender
{
    // Light Box the profile image
    UIGestureRecognizer *gesture = (UIGestureRecognizer *) sender;
    UIImageView *imageView = (UIImageView *) gesture.view;
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = imageView.image;
    imageInfo.referenceRect = imageView.frame;
    imageInfo.referenceView = imageView.superview;
    imageInfo.referenceContentMode = imageView.contentMode;
    imageInfo.referenceCornerRadius = imageView.layer.cornerRadius;
    
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
