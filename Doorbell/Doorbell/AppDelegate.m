//
//  AppDelegate.m
//  Doorbell
//
//  Created by Steven Petteruti on 1/29/16.
//  Copyright © 2016 Doorbell LLC. All rights reserved.
//

// last updated Nov 6. 2016

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import "RKSwipeBetweenViewControllers.h"

#import "DBNavigationController.h"
#import "DBLoginViewController.h"
#import "DBLoginNavigationController.h"
#import "DBLocationManager.h"
#import "DBObjectManager.h"


#import "DBFeedTableViewController.h"
#import "LGSideMenuController.h"
#import "DBSideMenuController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios/guide#local-datastore
    
    [DBLocationManager sharedInstance];
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"blahblah"; //D9gioUkezsLno8QYzueqF3SXQehuVsfi0xm6yoIJ
        configuration.clientKey = @"";
        configuration.server = @"http://doorbell-dev-api.herokuapp.com/parse";
       // configuration.server = @"http://localhost:1337/parse";
    }]];
    
    /*
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"D9gioUkezsLno8QYzueqF3SXQehuVsfi0xm6yoIJ"
                  clientKey:@"hBwjIInpGUF8bz3bzmPT6iX4d7XVhR9QhOhaGS1L"];
    

    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([PFUser currentUser] != nil && [PFUser currentUser][@"building"] != nil)
    {
        DBSideMenuController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DBSideMenuController"];
        self.window.rootViewController = viewController;
    }
    else
    {
        DBLoginNavigationController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"DBLoginNavigationController"];
        self.window.rootViewController = loginController;
    }
        
    [self.window makeKeyAndVisible];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    

    [self registerActivity];
    [self registerLocation];
    [NSTimer scheduledTimerWithTimeInterval:90.0f
                                     target:self
                                   selector:@selector(registerActivity)
                                   userInfo:nil
                                    repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:90.0f
                                     target:self
                                   selector:@selector(registerLocation)
                                   userInfo:nil
                                    repeats:YES];
*/
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"saved object test class: %d", succeeded);
        if (error != nil) {
            NSLog(@"error: %@", error);
        }
    }];
    return YES;
}

- (void)registerActivity
{
    NSLog(@"register activity");

    [PFCloud callFunctionInBackground:@"registerActivity"
                       withParameters:nil
                                block:nil];
}

- (void)registerLocation
{
    [[DBObjectManager sharedInstance] updateUsersCurrentLocation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation saveInBackground];
    
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationRecievedForMessage" object:nil userInfo:userInfo];
    }
    else if ([[userInfo objectForKey:@"type"] isEqualToString:@"comment"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationRecievedForComment" object:nil userInfo:userInfo];
    }
    else
    {
        [PFPush handlePush:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([PFUser currentUser] != nil)
    {
        UIBackgroundTaskIdentifier task;
        task = [application beginBackgroundTaskWithExpirationHandler:^
                {
                    NSLog(@"beginning task");
                    
                    
                    
                    [application endBackgroundTask:task];
                }];
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // Do the work associated with the task.
            NSLog(@"Started background task timeremaining = %f", [application backgroundTimeRemaining]);
            
            [self registerLocation];
            
            [application endBackgroundTask:task];
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
