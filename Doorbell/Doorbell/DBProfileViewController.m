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
    
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentUser[@"facebookId"]];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:URLString]
                             placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor ;
    self.profileImage.layer.borderWidth = 1.0f;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (currentUser[@"facebookName"] != nil)
    {
        self.nameLabel.text = currentUser[@"facebookName"];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"poster" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            // The find succeeded.
            // Do something with the found objects
            userRequests = [objects mutableCopy];
            self.numberOfRequests.text = [NSString stringWithFormat:@"%lu", userRequests.count];
            if (userRequests.count > 100) {
                self.numberOfRequests.text = @"100+";
            }
            
        }
        else
        {
            // Log details of the failure
        }
    }];
    
    PFRelation *relation = [currentUser relationForKey:@"messages"];
    PFQuery *queryChat = [relation query];
    queryChat.limit = 1000;
    [queryChat findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error)
        {
            // The find succeeded.
            // Do something with the found objects
            self.numberOfMessages.text = [NSString stringWithFormat:@"%lu", objects.count];
            if (objects.count > 1000) {
                self.numberOfMessages.text = @"1000+";
            }
            
        }
        else
        {
            // Log details of the failure
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}]; 
}

-(void)logoutButton:(id)sender
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    DBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileTableViewCell" forIndexPath:indexPath];
    
    if ([userRequests count] > indexPath.row)
    {
        PFObject *object = [userRequests objectAtIndex:indexPath.row];
        NSString *itemString = [object objectForKey:@"message"];
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        NSDate *createdDate = [object createdAt];
        
        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];;
    
        [cell.messageLabel sizeToFit];
        
        UIColor *normalColor = [UIColor blackColor];
        UIColor *highlightColor = [UIColor colorWithRed:52.0/255.0f green:152.0/255.0f blue:219.0/255.0f alpha:1.0f];
        NSDictionary *normalAttributes = @{NSForegroundColorAttributeName:normalColor};
        NSDictionary *highlightAttributes = @{NSForegroundColorAttributeName:highlightColor};
        
        if (itemString != nil) {
            NSAttributedString *normalText = [[NSAttributedString alloc] initWithString:@"Requested: " attributes:normalAttributes];
            NSAttributedString *highlightedText = [[NSAttributedString alloc] initWithString:itemString attributes:highlightAttributes];
            
            NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:normalText];
            [finalAttributedString appendAttributedString:highlightedText];
            
            cell.profileLabel.attributedText = finalAttributedString;
        }
    }
  
    cell.borderView.layer.borderWidth = 1.0f;
    cell.borderView.layer.borderColor = [UIColor colorWithWhite:0 alpha:.06].CGColor;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

@end
