//
//  DBEventsViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/30/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBEventsViewController.h"
#import "DBEventTableCell.h"
#import "DBObjectManager.h"
#import "DBEventDetailViewController.h"

@interface DBEventsViewController ()
{
    NSMutableArray *eventsArray;
}

@end

@implementation DBEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"events";
    
    eventsArray = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self fetchEvents];
}

- (void)fetchEvents
{
    [[[DBObjectManager alloc] init] fetchAllEvents:^(NSError *error, NSArray *events)
     {
        if (error == nil)
        {
            eventsArray = [events mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBEventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    
    cell.event = [eventsArray objectAtIndex:indexPath.row];
    
    return cell;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBEventTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBEventDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBEventDetailViewController"];
    vc.event = cell.event;
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
