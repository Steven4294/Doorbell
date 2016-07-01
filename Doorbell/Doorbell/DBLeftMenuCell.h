//
//  DBLeftMenuCell.h
//  
//
//  Created by Steven Petteruti on 5/29/16.
//
//

#import <UIKit/UIKit.h>
#import "SLExpandableTableView.h"

@interface DBLeftMenuCell : UITableViewCell <UIExpandingTableViewCell>

@property (nonatomic, strong) IBOutlet UILabel *itemLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) UIImage *unhighlightedImage;
@property (nonatomic, strong) UIImage *highlightedImage;


@property (nonatomic, assign, getter = isLoading) BOOL loading;

@property (nonatomic, readonly) UIExpansionStyle expansionStyle;


@end
