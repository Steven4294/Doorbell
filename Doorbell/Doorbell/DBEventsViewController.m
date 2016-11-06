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
#import "FTImageAssetRenderer.h"
#import "DBEventCreateController.h"
#import "UIViewController+Utils.h"

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
    self.tableView.tableFooterView = [UIView new];

    [self fetchEvents];
    
    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"compose" withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *image= [renderer imageWithCacheIdentifier:@"white"];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 22, 22);
    [rightButton setImage:image forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(composeEventButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc] init];
    [rightButtonItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDeleted) name:@"eventDelete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEvents) name:@"eventPosted" object:nil];

}

- (void)eventDeleted
{
    [self fetchEvents];
}

- (void)composeEventButtonPressed
{
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //DBEventCreateViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBEventCreateViewController"];
   // [self.navigationController pushViewController:vc animated:YES];
  
    
    
    DBEventCreateController *vc = [[DBEventCreateController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)fetchEvents
{
    [[[DBObjectManager alloc] init] fetchAllEvents:^(NSError *error, NSArray *events)
     {
        if (error == nil)
        {
            eventsArray = [events mutableCopy];
            [self.tableView reloadData];
            
            if (events.count == 0)
            {
                [self displayEmptyView:YES withText:@"No events" andSubText:@"You can find events for your building here."];
            }
            else
            {
                [self displayEmptyView:NO withText:@"No events" andSubText:@"You can find events for your building here."];
            }
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
