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
#import "UIImageView+Profile.h"
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
    
    [self updateProfileImage];
    
    PFUser *currentUser = [PFUser currentUser];

    self.nameLabel.text = currentUser[@"facebookName"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileImage) name:@"updatedProfileImage" object:nil];
}
- (void)updateProfileImage
{
    
    PFUser *currentUser = [PFUser currentUser];
    
    [self.profileImage setProfileImageViewForUser:currentUser isCircular:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

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
