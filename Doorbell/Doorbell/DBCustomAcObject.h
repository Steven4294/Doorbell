//
//  DEMOCustomAutoCompleteObject.h
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "MLPAutoCompletionObject.h"
@class PFUser;

@interface DBCustomAcObject : NSObject <MLPAutoCompletionObject>
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) PFUser *user;

- (id)initWithUsername:(NSString *)name user:(PFUser *)user;

@end
