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

@interface DBCustomAcObject : NSObject <MLPAutoCompletionObject>
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) UIImage *image;

- (id)initWithUsername:(NSString *)name objectId:(NSString *)objectId image:(UIImage *)image;

@end
