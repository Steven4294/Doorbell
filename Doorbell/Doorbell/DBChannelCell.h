//
//  DBChannelCell.h
//  Doorbell
//
//  Created by Steven Petteruti on 6/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@class PFObject;

@interface DBChannelCell : UITableViewCell <UIExpandingTableViewCell>

@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;

@property (nonatomic, strong) IBOutlet UILabel *channelLabel;

@property (nonatomic, strong) PFObject *channel;



@end
