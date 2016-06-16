//
//  UIViewController+Utils.m
//  Doorbell
//
//  Created by Steven Petteruti on 6/15/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

#import "UIViewController+Utils.h"
#import "FTImageAssetRenderer.h"

@implementation UIViewController (Utils)

- (void)configureCustomBackButton
{
    if (self.navigationItem.leftBarButtonItem == nil)
    {
        FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"back-button2" withExtension:@"png"];
        renderer.targetColor = [UIColor whiteColor];
        UIImage *leftButtonImage= [renderer imageWithCacheIdentifier:@"white"];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 22, 22);
        [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *leftButtonItem=[[UIBarButtonItem alloc] init];
        [leftButtonItem setCustomView:leftButton];
        
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    }
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
