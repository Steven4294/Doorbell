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
#import "UIColor+FlatColors.h"
#import "DBGenericProfileViewController.h"

@interface DBCommentViewController ()
{
    NSMutableArray *commentsArray;
    DBObjectManager *objectManager;
    NSMutableDictionary *nameAndUserDictionary;
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

- (void)setLikersArray:(NSMutableArray *)likersArray
{
    _likersArray = likersArray;
    
    nameAndUserDictionary = [[NSMutableDictionary alloc] init];

    for (PFObject *user in likersArray)
    {
        NSLog(@"%@", user[@"facebookName"]);
        [nameAndUserDictionary setValue:user forKey:user[@"facebookName"]];
    }
    [nameAndUserDictionary setValue:[PFUser currentUser] forKey:[PFUser currentUser][@"facebookName"]];
    NSLog(@"likers array set: %lu", (unsigned long)nameAndUserDictionary.count);
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
        
        [cell.nameLabel addLinkClassifier:[self createUserLinkClassifierTopCell:self.request[@"poster"]]];
        [cell.nameLabel setLinkDetectionTypes:KILinkTypeOptionNone];

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
        [cell.likeLabel addLinkClassifier:[self createLikerLabelClassifier]];
        [cell.likeLabel setLinkDetectionTypes:KILinkTypeOptionNone];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        return cell;
    }
    else
    {
        // configure the comment cell
        DBCommentChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCommentChatCell" forIndexPath:indexPath];
      
        PFObject *comment = [commentsArray objectAtIndex:(indexPath.row - 2)];
        cell.comment = comment;
    
        [cell.messageLabel addLinkClassifier:[self createUserLinkClassifier:comment[@"poster"]]];
        [cell.messageLabel setLinkDetectionTypes:KILinkTypeOptionNone];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

        return cell;
    }
}

- (NSString *)regexForArray:(NSArray *)array
{
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    for (NSString *string in array)
    {
        if (mutableString.length > 0) {
            [mutableString appendString:[NSString stringWithFormat:@"|%@",string]];

        }
        else
        {
            [mutableString appendString:string];

        }
    }
    
    return [mutableString copy];
}

- (KILabelLinkClassifier *)createLikerLabelClassifier
{
    NSLog(@"now creating the regex");
    NSArray *names = [nameAndUserDictionary allKeys];
    NSLog(@"%@", names);
    NSDataDetector *dateDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    NSString *regexString = [self regexForArray:names];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString options:0 error:nil];
    KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
    
    // Apply link attributes to the classifier to make fancy looking links
    classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor flatBelizeHoleColor],
                                  NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:15]};
    
    classifier.tapHandler = ^(KILabel *label, NSString *string, NSRange range)
    {
        PFUser *user = [nameAndUserDictionary valueForKey:string];
        [self presentProfileViewForUser:user];
    };
    
    
    return classifier;
}


- (KILabelLinkClassifier *)createUserLinkClassifier:(PFUser *)user
{
    // creates the link classifier for the chat cell
    NSString *fullName = user[@"facebookName"];
    NSString *firstName = [fullName firstNameLastInitial];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@:", firstName] options:0 error:nil];
    KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
    
    // Apply link attributes to the classifier to make fancy looking links
    classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor flatBelizeHoleColor],
                                  NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:15]};
    
    classifier.tapHandler = ^(KILabel *label, NSString *string, NSRange range)
    {
        CGPoint pointInTable = [label convertPoint:label.bounds.origin toView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTable];
        DBCommentChatCell *cell =  [self.tableView cellForRowAtIndexPath:indexPath];
        PFUser *user = cell.comment[@"poster"];
        
        [self presentProfileViewForUser:user];
    };
    

    return classifier;
}

- (KILabelLinkClassifier *)createUserLinkClassifierTopCell:(PFUser *)user
{
    NSString *fullName = user[@"facebookName"];
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:fullName options:0 error:nil];
    KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
    
    classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor darkTextColor],
                                  NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:16]};
    
    classifier.tapHandler = ^(KILabel *label, NSString *string, NSRange range)
    {
        PFUser *user = self.request[@"poster"];
        [self presentProfileViewForUser:user];
    };
    
    return classifier;
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

- (void)presentProfileViewForUser:(PFUser *)user
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DBGenericProfileViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DBGenericProfileViewController"];
    vc.user = user;
    
    [vc setModalPresentationStyle:UIModalPresentationFullScreen];
    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.navigationController pushViewController:vc animated:YES];

}

@end
