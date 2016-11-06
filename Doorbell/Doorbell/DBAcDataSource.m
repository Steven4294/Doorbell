//
//  DEMODataSource.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 5/28/14.
//  Copyright (c) 2014 Mainloop. All rights reserved.
//

#import "DBAcDataSource.h"
#import "DBCustomAcObject.h"
#import "DBObjectManager.h"
#import "Parse.h"

@interface DBAcDataSource ()

@property (strong, nonatomic) NSArray *countryObjects;

@end


@implementation DBAcDataSource


#pragma mark - MLPAutoCompleteTextField DataSource


//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        if(self.simulateLatency){
           // CGFloat seconds = arc4random_uniform(4)+arc4random_uniform(4); //normal distribution
           // NSLog(@"sleeping fetch of completions for %f", seconds);
           // sleep(seconds);
        }
        
        NSArray *completions;
        if(self.testWithAutoCompleteObjectsInsteadOfStrings){
            //completions = [self allCountryObjects];
        } else {
            completions = [self allCountries];
            
            NSMutableArray *allUserNames = [[NSMutableArray alloc] init];
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"building" equalTo:[PFUser currentUser][@"building"]];
            query.limit = 1000;
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                for ( PFUser *user in objects)
                {
                    NSString *name = user[@"facebookName"];
                    
                    DBCustomAcObject *customObject = [[DBCustomAcObject alloc] initWithUsername:name user:user];
                    [allUserNames addObject:customObject];

                }
                handler([allUserNames copy]);

            }];
            
            
            
        }
        
    });
}

/*
 - (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
 {
 
 if(self.simulateLatency){
 CGFloat seconds = arc4random_uniform(4)+arc4random_uniform(4); //normal distribution
 NSLog(@"sleeping fetch of completions for %f", seconds);
 sleep(seconds);
 }
 
 NSArray *completions;
 if(self.testWithAutoCompleteObjectsInsteadOfStrings){
 completions = [self allCountryObjects];
 } else {
 completions = [self allCountries];
 }
 
 return completions;
 }
 */


- (NSArray *)allCountries
{
  
    NSArray *items = @[
                       @"vacuum",
                       @"sleeping bag",
                       @"calculator",
                       @"printer",
                       @"pencil"
                       ];
    return items;
}





@end
