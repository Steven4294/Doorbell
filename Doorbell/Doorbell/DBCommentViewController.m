//
//  DBCommentViewController.m
//  Doorbell
//
//  Created by Steven Petteruti on 5/31/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBCommentViewController.h"
#import "DBCommentTopCell.h"
#import "DBCommentChatCell.h"
#import "DBCommentLikeCell.h"
#import "Parse.h"
#import "DBObjectManager.h"
#import "Doorbell-Swift.h"
#import "FRHyperLabel.h"
#import "NSString+Utils.h"

@interface DBCommentViewController ()
{
    NSMutableArray *commentsArray;
    DBObjectManager *objectManager;
}
@end

@implementation DBCommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    commentsArray = [[NSMutableArray alloc] init];
    objectManager = [[DBObjectManager alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self loadComments];
    self.inputContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputContainerView.layer.borderWidth =1.0f;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
}

- (void)sendButtonPressed
{
    if ([self.NextGrowingTextView.text isEqualToString:@""] == FALSE)
    {
        [self.sendButton setEnabled:NO];
        
        [objectManager postCommentWithString:self.NextGrowingTextView.text toRequest:self.request fromUser:[PFUser currentUser] withCompletion:^(BOOL success, PFObject *comment) {
            if (success)
            {
               
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                NSLog(@"before:%d", commentsArray.count);
                [self.tableView beginUpdates];
                [commentsArray insertObject:comment atIndex:0];
                NSLog(@"after:%d", commentsArray.count);

                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
                
                self.NextGrowingTextView.text = @"";
                
                [self.sendButton setEnabled:YES];
                // insert comment to the top of the table
            }
            
        }];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"began editing");
}

- (void)keyboardWillShowNotification:(NSNotification *)sender
{
    NSDictionary *dictionary = sender.userInfo;
    CGSize keyboardSize=[[dictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  
    self.inputContainerViewConstraint.constant = keyboardSize.height;
    [self.inputContainerView layoutIfNeeded];
}
- (void)keyboardWillHideNotification:(NSNotification *)sender
{
    NSDictionary *dictionary = sender.userInfo;
    CGSize keyboardSize=[[dictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.inputContainerViewConstraint.constant = keyboardSize.height;
    [self.inputContainerView layoutIfNeeded];
}
- (void)loadComments
{
    PFRelation *relation = [self.request relationForKey:@"comments"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error == nil)
        {
            commentsArray = [objects mutableCopy];
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"error loading comments: %@", error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (2 + commentsArray.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // configure the header cell
        DBCommentTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCommentTopCell" forIndexPath:indexPath];
        
        cell.requestObject = self.request;
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        
        [objectManager fetchLikersForRequest:cell.requestObject withBlock:^(BOOL isLiked, NSArray *objects, NSError *error)
        {
            if (error == nil)
            {
                cell.likersArray = [objects mutableCopy];
                [cell configureLikeLabel];
            }
        }];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else if (indexPath.row == 1)
    {
        // configure the like cell
        DBCommentLikeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCommentLikeCell" forIndexPath:indexPath];
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        cell.likersArray = self.likersArray;
        [cell configureLikeLabel];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        return cell;
    }
    else
    {
        // configure the comment cell
        DBCommentChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCommentChatCell" forIndexPath:indexPath];
        if (indexPath.row == 2)
        {
           // cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        }
        
        
        PFObject *comment = [commentsArray objectAtIndex:(indexPath.row - 2)];
        cell.comment = comment;
        
        void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
            NSLog(@"Selected: %@", substring);
        };

        NSString *fullName = comment[@"poster"][@"facebookName"];
        NSString *firstName = [fullName firstName];
        
       // [cell.textLabel setLinksForSubstrings:@[firstName] withLinkHandler:handler];
        
        cell.textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.textLabel.layer.borderWidth = 1.0f;

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
       // [cell.textLabel updateConstraints];

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[DBCommentLikeCell class]])
    {
        // toggle like
        DBCommentLikeCell *likeCell = (DBCommentLikeCell *) cell;
        [self toggleLike:likeCell];
    }
}

- (void)toggleLike:(DBCommentLikeCell *)cell
{
    [objectManager toggleLike:self.request withBlock:^(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error) {
        
        if (wasLiked == YES)
        {
            NSLog(@"Update UI because of LIKE");
            [cell.likersArray addObject:[PFUser currentUser]];
            [cell configureLikeLabel];
        }
        else
        {
            NSLog(@"Update UI because of UNLIKE");
            [cell.likersArray removeObject:[PFUser currentUser]];
            [cell configureLikeLabel];
        }
        
    }];
}

@end
