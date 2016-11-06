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

- (void)configureBackButtonOnView
{
    FTImageAssetRenderer *renderer = [FTAssetRenderer rendererForImageNamed:@"back-button2" withExtension:@"png"];
    renderer.targetColor = [UIColor whiteColor];
    UIImage *leftButtonImage= [renderer imageWithCacheIdentifier:@"white"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButton.frame = CGRectMake(10, 40.0f, 22, 22);
    [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:leftButton];
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)displayEmptyView:(BOOL)displayed withText:(NSString *)text andSubText:(NSString *)subText
{
    if (displayed == YES)
    {
        UIView *emptyView = [[UIView alloc] initWithFrame:self.view.frame];
        emptyView.tag = 17;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 30)];
        label.text = text;
        label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;

        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100 + label.frame.size.height, self.view.frame.size.width-2*50, 80)];
        subLabel.text = subText;
        subLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
        subLabel.textColor = [UIColor grayColor];
        subLabel.textAlignment = NSTextAlignmentCenter;
        subLabel.numberOfLines = 0;
        
        [self.view addSubview:emptyView];
        [self.view addSubview:label];
        [self.view addSubview:subLabel];
    }
    else
    {
        UIView *emptyView = [self.view viewWithTag:17];
        [emptyView removeFromSuperview];
    }
}

@end
