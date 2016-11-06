//
//  DBPerkViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 7/25/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBPerkViewController.h"
#import "DBPerkDetailViewController.h"

#import "DBPerkCell.h"
#import "DBObjectManager.h"
#import "UIViewController+Utils.h"

@implementation DBPerkViewController
{
    NSArray *dealsArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setContentInset:UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0)];
    [self fetchDeals];
}

- (void)fetchDeals
{
    dealsArray = [[NSArray alloc] init];
    [[DBObjectManager sharedInstance] fetchAllDeals:^(NSError *error, NSArray *deals) {
        dealsArray = deals;
        [self.tableView reloadData];
        if (dealsArray.count == 0) {
            [self displayEmptyView:YES withText:@"No deals near you" andSubText:@"local deals from nearby businesses will be shown here"];
        }
        else
        {
            [self displayEmptyView:NO withText:@"" andSubText:@""];

        }
    }];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dealsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBPerkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPerkCell" forIndexPath:indexPath];
    PFObject *deal = [dealsArray objectAtIndex:indexPath.row];
    cell.deal = deal;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *deal = [dealsArray objectAtIndex:indexPath.row];
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBPerkDetailViewController *vc = [main instantiateViewControllerWithIdentifier:@"DBPerkDetailViewController"];
    vc.deal = deal;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
