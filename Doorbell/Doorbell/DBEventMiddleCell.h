//
//  DBEventMiddleCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject, DBLabel;

@interface DBEventMiddleCell : UICollectionViewCell

@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) IBOutlet DBLabel *eventDescription;
@property (nonatomic, strong) IBOutlet UIImageView *eventImage;

@end
