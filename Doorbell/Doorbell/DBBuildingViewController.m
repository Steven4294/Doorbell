
//
//  DBBuildingViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/27/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBBuildingViewController.h"
#import "DBBuildingCell.h"
#import "Parse.h"

@implementation DBBuildingViewController
{
    NSArray *buildingArray;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSString *buildingName = [PFUser currentUser][@"building"];
    self.title = [buildingName lowercaseString];
    
    [self fetchBuildingInformation];
}

- (void)fetchBuildingInformation
{
    buildingArray = [[NSArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"BuildingStaff"];
    [query whereKey:@"building" equalTo:[PFUser currentUser][@"building"] ];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error)
    {
        buildingArray = objects;
        [self.tableView reloadData];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return buildingArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBBuildingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buildingCell" forIndexPath:indexPath];
    PFObject *building = [buildingArray objectAtIndex:indexPath.row];
    cell.buildingObject = building;
    return cell;
}

@end
