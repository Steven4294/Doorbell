YZSwipeBetweenViewController
============================

A view controller that has a scroll view which contains multiple view controllers's views; user can swipe left/right to switch to different views.

![Screenshot](https://raw.githubusercontent.com/yichizhang/YZSwipeBetweenViewController/master/demogif.gif)

## Install
Simply use [CocoaPods](http://cocoapods.org/):

`pod 'YZSwipeBetweenViewController'`


## Usage

Simple Usage:

```objc
@property (strong) YZSwipeBetweenViewController *swipeBetweenVC;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	self.swipeBetweenVC = [YZSwipeBetweenViewController new];
	
	UIViewController *vc1 = [DemoMainViewController new];
	UINavigationController *navCon1 =
	[[UINavigationController alloc]initWithRootViewController:vc1];
	
	UIViewController *vc2 = [DemoMainViewController new];
	UINavigationController *navCon2 =
	[[UINavigationController alloc] initWithRootViewController:vc2];
	
	UIViewController *vc3 = [DemoMainViewController new];
	UINavigationController *navCon3 =
	[[UINavigationController alloc] initWithRootViewController:vc3];
	
	self.swipeBetweenVC.viewControllers = @[navCon1, navCon2, navCon3];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor blackColor];
	[self.window setRootViewController:self.swipeBetweenVC];
	[self.window makeKeyAndVisible];
	
	return YES;
}
```

You can change the view controllers:

```objc

self.swipeBetweenVC.viewControllers = newViewControllers;
[self.swipeBetweenVC reloadViewControllers];

```

Scroll to a view controller at an index:

```objc

//Switch to the first view controller
[self.swipeBetweenVC scrollToViewControllerAtIndex:0 animated:YES];

//Switch to the second view controller
[self.swipeBetweenVC scrollToViewControllerAtIndex:1 animated:YES];

//Switch to the third view controller
[self.swipeBetweenVC scrollToViewControllerAtIndex:2 animated:YES];

```