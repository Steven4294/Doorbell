//
//  DBLeftMenuViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBLeftMenuViewController.h"
#import "DBLeftMenuCell.h"
#import "DBSideMenuController.h"
#import "Parse.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DBLeftMenuViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation DBLeftMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"initing left menu");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _titlesArray = @[@"Home",
                         @"Profile",
                         @"Address Book",
                         @"Events",
                         @"Notifications",
                         @"Settings"];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[DBLeftMenuCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView reloadData];
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *URLString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", currentUser[@"facebookId"]];
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:URLString]
                         placeholderImage:[UIImage imageNamed:@"http://graph.facebook.com/67563683055/picture?type=square"]];
    
    self.nameLabel.text = currentUser[@"facebookName"];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width/2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
}

- (void)setSideMenuController:(DBSideMenuController *)sideMenuController
{
    _sideMenuController = sideMenuController;
    
    self.tableView.delegate = self.sideMenuController;
    self.tableView.dataSource = self.sideMenuController;
    [self.tableView reloadData];
    
}

@end
