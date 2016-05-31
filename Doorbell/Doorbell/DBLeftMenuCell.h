//
//  DBLeftMenuCell.h
//  
//
//  Created by Steven Petteruti on 5/29/16.
//
//

#import <UIKit/UIKit.h>

@interface DBLeftMenuCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *itemLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) UIImage *unhighlightedImage;
@property (nonatomic, strong) UIImage *highlightedImage;

@end
