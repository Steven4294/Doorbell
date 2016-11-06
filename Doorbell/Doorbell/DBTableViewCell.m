//
//  DBTableViewCell.m
//  Doorbell
//
//  Created by Steven on 3/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBTableViewCell.h"
#import "TTTTimeIntervalFormatter.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Parse.h"
#import "UIImage+Resize.h"
#import "UIImageView+Profile.h"
#import "DBObjectManager.h"
#import "DBCommentViewController.h"

@interface DBTableViewCell ()
{
DBObjectManager *objectManager;

}
@end

@implementation DBTableViewCell

- (void)awakeFromNib
{
    objectManager = [[DBObjectManager alloc] init];
    self.likersArray = [[NSMutableArray alloc] init];
    // Initialization code
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2.0f;
    self.profileImageView.clipsToBounds = YES;
    
    // COMMENT THIS OUT
    /*
    self.timeLabel.layer.borderColor = [UIColor grayColor].CGColor;
    self.timeLabel.layer.borderWidth = 1.0f;
    
    self.nameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameLabel.layer.borderWidth = 1.0f;
    
    self.messageLabel.layer.borderColor = [UIColor greenColor].CGColor;
    self.messageLabel.layer.borderWidth = 1.0f;
    
    self.listOfLikersLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.listOfLikersLabel.layer.borderWidth = 1.0f;
    
    self.likeLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.likeLabel.layer.borderWidth = 1.0f;
     */
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
    gesture.minimumPressDuration = 0.0f;
    [gesture addTarget:self action:@selector(likeLabelTapped:)];
    [self.likeLabel addGestureRecognizer:gesture];
}

- (void)setRequestObject:(PFObject *)requestObject
{
    self.classifier = nil;
    _requestObject = requestObject;
    PFUser *user = requestObject[@"poster"];
    self.user = user;
    
    self.nameLabel.text = user[@"facebookName"];
    
    [self.profileImageView setProfileImageViewForUser:user isCircular:YES];
    
    self.messageLabel.text = [requestObject objectForKey:@"message"];
    
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSDate *createdDate = [requestObject createdAt];
    self.timeLabel.text = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:createdDate];
    [self.messageLabel sizeToFit];
    [self.nameLabel addLinkClassifier:[self classifier]];
    
    // pass in weak-self
    [objectManager fetchLikersForRequest:self.requestObject withBlock:^(BOOL isLiked, NSArray *objects, NSError *error) {
        if (error == nil)
        {
            NSNumber *numberOfLikers = self.requestObject[@"numberOfLikers"];
            self.likersArray = [objects mutableCopy];
            [self configureLikeLabelWithInteger:numberOfLikers.intValue];
        }
    }];
    
    if ([requestObject[@"complete"] boolValue] == YES)
    {
        [self setShowsLeftSlideIndicator:NO];
        [self setShowsRightSlideIndicator:NO];
    }
    else
    {
        [self setShowsLeftSlideIndicator:YES];
        [self setShowsRightSlideIndicator:YES];
    }
    self.classifier = [self classifier];
    [self configureCommentLabel];
}

- (void)setLikersArray:(NSMutableArray *)likersArray
{
    _likersArray = likersArray;
}

- (NSString *)formattedUsernameForUser:(PFUser *)user
{
    return user[@"facebookName"];
}

- (void)configureLikeLabelWithInteger:(int)numberOfLikers
{
    BOOL isUserLiker = [self.likersArray containsObject:[PFUser currentUser]];
    //NSNumber *number = self.requestObject[@"numberOfLikers"];

    if (isUserLiker == YES)
    {
        self.likeLabel.text = @"Unlike";
        self.likeLabel.attributedText = [self concatText:@"Unlike    " withInteger:numberOfLikers];
    }
    else
    {
        self.likeLabel.text = @"Like";
        self.likeLabel.attributedText = [self concatText:@"Like        " withInteger:numberOfLikers];
    }
}

- (void)configureCommentLabel
{
    NSNumber *number = self.requestObject[@"numberOfComments"];
    if (number.intValue > 0)
    {
        self.commentLabel.attributedText = [self concatText:@"Comment    " withInteger:number.intValue];
    }
    else
    {
        self.commentLabel.text = @"Comment";
    }
}

- (void)likeLabelTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.likeLabel.alpha = .5;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        self.likeLabel.alpha = 1.0f;
        [self toggleLike:self];
    }
}

- (void)toggleLike:(DBTableViewCell *)cell
{
    [objectManager toggleLike:cell.requestObject withBlock:^(BOOL success, BOOL wasLiked, int numberOfLikers, NSError *error)
    {
        if (wasLiked == YES)
        {
            [cell.likersArray addObject:[PFUser currentUser]];
            [cell configureLikeLabelWithInteger:numberOfLikers];
        }
        else
        {
            [cell.likersArray removeObject:[PFUser currentUser]];
            [cell configureLikeLabelWithInteger:numberOfLikers];
        }
    }];
}

- (NSAttributedString *)concatText:(NSString *)text withInteger:(int)integer
{
    UIColor *color = [UIColor colorWithWhite:.80 alpha:1.0]; //0 = black,  1 = white
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Medium" size:11.0];
    NSDictionary *dict = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
    
    if (integer > 0)
    {
        NSString *messageBody = [NSString stringWithFormat:@"%@", text];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%d", messageBody, integer]];
        // make the numbers attributed (which is located at the end of the string)
        [attrStr addAttributes:dict range:NSMakeRange(messageBody.length, attrStr.length - messageBody.length)];
        return [attrStr copy];
    }
    else
    {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text];
        return attrStr;
    }
}

- (KILabelLinkClassifier *)classifier
{
    if (_classifier == nil)
    {
        NSString *fullName = self.user[@"facebookName"];
        if (fullName == nil)
        {
            fullName = @"";
            NSLog(@"crash potentiallly");
        }
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:fullName options:0 error:nil];
        KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
        
        classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor darkTextColor],
                                      NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:16]};
        _classifier = classifier;
    }
    return _classifier;
}

@end
