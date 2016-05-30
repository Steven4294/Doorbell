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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <SDWebImage/UIImageView+WebCache.h>

#import "JTSImageViewController.h"
#import "JTSImageInfo.h"


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
    
    if (currentUser[@"facebookName"] != nil)
    {
        self.nameLabel.text = currentUser[@"facebookName"];
    }
    
    [self retrieveUsersRequests];
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
    PFUser *currentUser = [PFUser currentUser];
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentUser[@"facebookId"]];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:URLString]
                         placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
 
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor colorWithWhite:.2 alpha:1.0].CGColor ;
    self.profileImage.layer.borderWidth = 0.0f;
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

- (void)logoutButton:(id)sender
{
    NSLog(@"logging out");
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error == nil) {
            [FBSDKAccessToken setCurrentAccessToken:nil];
            
            NSLog(@"logged out!");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DBLoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBLoginViewController"];
            [self presentViewController:vc animated:NO completion:nil];
            
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
        NSString *itemString = [object objectForKey:@"message"];
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        NSDate *createdDate = [object createdAt];
        
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];;
        
        PFUser *currentUser = [PFUser currentUser];
        cell.nameLabel.text = currentUser[@"facebookName"];
        cell.messageLabel.text = itemString;
        
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentUser[@"facebookId"]];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                             placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
        
    }
    
    cell.borderView.layer.borderWidth = 1.0f;
    cell.borderView.layer.borderColor = [UIColor colorWithWhite:0 alpha:.06].CGColor;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 107;
}

@end
