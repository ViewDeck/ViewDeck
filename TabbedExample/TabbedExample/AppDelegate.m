//
//  AppDelegate.m
//  TabbedExample
//
//  Created by Tom Adriaenssen on 03/02/12.
//  Copyright (c) 2012 Adriaenssen BVBA. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "IIViewDeckController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"
#import "SelectorController.h"
#import "IIWrapController.h"

#define VIEWDECK_ENABLED YES
#define TABBAR_ENABLED YES

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    UIViewController *viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    UIViewController *viewController2 = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    if (VIEWDECK_ENABLED) { 
        UIViewController *selectorController = [[SelectorController alloc] initWithNibName:@"SelectorController" bundle:nil];
        
        IIViewDeckController* deckController = [[IIViewDeckController alloc] initWithCenterViewController:viewController1 leftViewController:selectorController];
        deckController.automaticallyUpdateTabBarItems = YES;
        deckController.navigationControllerBehavior = IIViewDeckNavigationControllerIntegrated;
        deckController.maxSize = 220;
        viewController1 = deckController;
    }
    viewController1 = [[IIWrapController alloc] initWithViewController:[[UINavigationController alloc] initWithRootViewController:viewController1]];
    
    if (TABBAR_ENABLED) {
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, nil];
        self.window.rootViewController = self.tabBarController;
    }
    else {
        self.window.rootViewController = viewController1;
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (UIViewController*)controllerForIndex:(int)index {
    switch (index) {
        case 0:
            return [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
        case 1:
            return [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];
        case 2:
            return [[FourthViewController alloc] initWithNibName:@"FourthViewController" bundle:nil];
        case 3:
            return [[FifthViewController alloc] initWithNibName:@"FifthViewController" bundle:nil];
    }
    
    return nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
