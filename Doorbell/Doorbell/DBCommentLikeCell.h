//
//  DBCommentLikeCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/1/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCommentLikeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *likeIconView;
@property (nonatomic, strong) IBOutlet UILabel *likeLabel;

@property (nonatomic, strong) NSMutableArray *likersArray;

-(void)configureLikeLabel;

@end
