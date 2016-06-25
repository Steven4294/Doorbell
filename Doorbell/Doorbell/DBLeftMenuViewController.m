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
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapped:)];
    gesture.minimumPressDuration = 0.0f;
    [self.headerView addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewWasTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

- (void)tableViewWasTapped:(UITapGestureRecognizer *)gesture
{
    // delay for a short time just for animation's sake
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                   {
                       [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
                   });}

- (void)headerViewTapped:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        UIColor *darkBlueColor = self.headerView.backgroundColor;
        
        [UIView animateWithDuration:.2 animations:^
         {
             self.headerView.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:.2 animations:^
                              {
                                  self.headerView.layer.backgroundColor = darkBlueColor.CGColor;
                              } completion:nil];
                         }];
        
    }    // do a cheeky animation
    else
    {
        [self.sideMenuController transitionToMenuItem:@"Profile"];
    }
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
