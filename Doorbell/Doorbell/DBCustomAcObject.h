//
//  DEMOCustomAutoCompleteObject.h
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompletionObject.h"

@interface DBCustomAcObject : NSObject <MLPAutoCompletionObject>
@property (strong) NSString *objectId;

- (id)initWithUsername:(NSString *)name objectId:(NSString *)objectId;

@end
