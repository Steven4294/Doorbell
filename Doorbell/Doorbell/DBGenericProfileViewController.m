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
    
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.user[@"facebookId"]];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:URLString]
                         placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
    
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
        
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
        
        cell.nameLabel.text = self.user[@"facebookName"];
        cell.messageLabel.text = itemString;
        cell.messageLabel.numberOfLines = 2;
        
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.user[@"facebookId"]];
        
        
        
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                                 placeholderImage: nil
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                            
                                            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
                                            [tapRecognizer addTarget:self action:@selector(cellImageViewTapped:)];
                                            [cell.profileImageView addGestureRecognizer:tapRecognizer];
                                        }];
        //[cell.messageLabel sizeToFit];

        
    
    }
    
   
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

@end
