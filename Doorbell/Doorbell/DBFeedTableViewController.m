//
//  DBFeedTableViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 3/8/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBFeedTableViewController.h"
#import "DRCellSlideGestureRecognizer.h"
#import "Parse.h"
#import "DBTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SVPullToRefresh.h"

#import "DBRequestFormViewController.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TLYShyNavBarManager.h"

@interface DBFeedTableViewController ()
{
    NSMutableArray *requests;
}

@property (nonatomic, strong) DBTableViewCell *prototypeCell;


@end

@implementation DBFeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Uncomment the following line to preserve selection between presentations.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
   
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            requests = [objects mutableCopy];
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        // prepend data to dataSource, insert cells at top of table view
        // call [tableView.pullToRefreshView stopAnimating] when done
        PFQuery *query = [PFQuery queryWithClassName:@"Request"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (!error) {
                // The find succeeded.
                // Do something with the found objects
                requests = [objects mutableCopy];
                [self.tableView reloadData];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            [self.tableView.pullToRefreshView stopAnimating];
        }];
        
    }];
    
    CGFloat padding_x = 0;
    CGFloat padding_y = 0;
    UIButton *requestButton = [[UIButton alloc] initWithFrame:CGRectMake(0 + padding_x, self.view.frame.size.height - 65 - padding_y, self.view.frame.size.width - 2*padding_x, 65 - padding_y)];
    requestButton.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:240/255.0 alpha:1.0f];
    [requestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestButton setTitle:@"request" forState:UIControlStateNormal];
    [requestButton.titleLabel setFont:[UIFont fontWithName:@"Avenir" size:20.0]];
    [self.view addSubview:requestButton];
    [self.view bringSubviewToFront:requestButton];
    [requestButton addTarget:self action:@selector(requestButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
   /* [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:242/255.0 green:120/255.0 blue:75/255.0 alpha:1.0],
       NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];*/
    
     [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
     NSFontAttributeName:[UIFont fontWithName:@"Black Rose" size:27]}];
    
    
    self.shyNavBarManager.scrollView = self.tableView;
    
    
}

-(void)requestButtonPressed{
    NSLog(@"request button pressed");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBRequestFormViewController"];
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    

    
    [self presentViewController:vc animated:YES completion:^{
        
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [requests count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if ([requests count] > indexPath.row)
    {
        PFObject *object = [requests objectAtIndex:indexPath.row];
        cell.messageLabel.text = [object objectForKey:@"message"];
        
        PFObject *sender = [object objectForKey:@"sender"];
        cell.nameLabel.text = sender[@"facebookName"];
        
        TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        
        NSDate *createdDate = [object createdAt];

        cell.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];;
        NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", sender[@"facebookId"]];
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                          placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
        
        [cell.messageLabel sizeToFit];
    }
   
    
    DRCellSlideGestureRecognizer *slideGestureRecognizer = [DRCellSlideGestureRecognizer new];
    DRCellSlideAction *squareAction = [DRCellSlideAction actionForFraction:0.25];
    squareAction.activeBackgroundColor = [UIColor clearColor];
    squareAction.inactiveBackgroundColor = [UIColor clearColor];
    squareAction.behavior = DRCellSlideActionPushBehavior;
    squareAction.elasticity = 40;
    squareAction.didTriggerBlock = [self pushTriggerBlock];
    
    [slideGestureRecognizer addActions:squareAction];
    
    [cell addGestureRecognizer:slideGestureRecognizer];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 150;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // dynamically resizes cells
    PFObject *object = [requests objectAtIndex:indexPath.row];
    NSString *messageString = [object objectForKey:@"message"];
    CGFloat labelHeight = [self paddingForString:messageString];
    CGFloat staticHeight = 85.0f;
    
    return labelHeight + staticHeight;
}

- (DRCellSlideActionBlock)pushTriggerBlock
{
    return ^(UITableView *tableView, NSIndexPath *indexPath) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hooray!" message:@"You just pulled a cell." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

- (DRCellSlideActionBlock)pullTriggerBlock
{
    return ^(UITableView *tableView, NSIndexPath *indexPath) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hooray!" message:@"You just pushed a cell." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    };
}

-(CGFloat)paddingForString:(NSString *)string
{
    CGFloat kNumberOfCharsPerLine = 30.0f;
    CGFloat padding = round([string length] / kNumberOfCharsPerLine);
    padding = padding * 15.0f;
    return padding;
}

@end
