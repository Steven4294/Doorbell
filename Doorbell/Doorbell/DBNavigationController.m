//
//  DBNavigationController.m
//  Doorbell
//
//  Created by Steven Petteruti on 3/23/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "DBNavigationController.h"
#import "CEBaseInteractionController.h"
#import "CEReversibleAnimationController.h"

@interface DBNavigationController ()

@end

@implementation DBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (id<UIViewControllerAnimatedTransitioning>)navigationController:
(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    
    // reverse the animation for 'pop' transitions
    _navigationAnimationController.reverse = operation == UINavigationControllerOperationPop;
    return _navigationAnimationController;
}




@end
