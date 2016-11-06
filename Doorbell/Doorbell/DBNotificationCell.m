//
//  DBNotificationCell.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/21/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNotificationCell.h"
#import "Parse.h"
#import "NSDate+DateTools.h"
#import "UIImageView+Profile.h"

@implementation DBNotificationCell
{
    PFUser *user;
}

-(void)setNotificationObject:(PFObject *)notificationObject
{
    _notificationObject = notificationObject;
    
    self.nameClassifier = nil;
    self.postClassifier = nil;
    
    PFObject *comment = notificationObject[@"comment"];
    
    user = comment[@"poster"];
    NSLog(@"poster: %@", comment[@"poster"][@"facebookName"]);

    NSString *commentString = comment[@"commentString"];
    NSString *name = user[@"facebookName"];
    NSDate *date = [notificationObject createdAt];
    NSString *timeString = [date shortTimeAgoSinceNow];
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ commented: %@ %@", name, commentString, timeString];
    
    UIColor *color = [UIColor colorWithWhite:.80 alpha:1.0]; //0 = black,  1 = white
    UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
    
    NSDictionary *timeAttributes = @{NSForegroundColorAttributeName: color, NSFontAttributeName: font};
    NSDictionary *bodyAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: font};

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageBody];
    [attrStr addAttributes:bodyAttributes range:NSMakeRange(0, attrStr.length)];
    [attrStr addAttributes:timeAttributes range:NSMakeRange(attrStr.length - timeString.length, timeString.length)];
    
    self.commentLabel.attributedText = [attrStr copy];
    [self.profileImage setProfileImageViewForUser:user isCircular:YES];
    
    [self.commentLabel addLinkClassifier:self.nameClassifier];
    //[self.commentLabel addLinkClassifier:self.postClassifier];
}

- (KILabelLinkClassifier *)nameClassifier
{
    if (_nameClassifier == nil)
    {
        NSString *fullName = user[@"facebookName"];
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:fullName options:0 error:nil];
        KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
        
        classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor darkTextColor],
                                      NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:14.0]};
        _nameClassifier = classifier;
    }
    return _nameClassifier;
}

- (KILabelLinkClassifier *)postClassifier
{
    if (_postClassifier == nil)
    {
        NSString *fullName = @"commented:";
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:fullName options:0 error:nil];
        KILabelLinkClassifier *classifier = [KILabelLinkClassifier linkClassifierWithRegex:regex];
        
        classifier.linkAttributes = @{NSForegroundColorAttributeName: [UIColor redColor],
                                      NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:14.0]};
        _postClassifier = classifier;
    }
    return _postClassifier;
}

@end
