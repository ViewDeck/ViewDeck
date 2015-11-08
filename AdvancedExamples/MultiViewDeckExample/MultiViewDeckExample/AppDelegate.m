//
//  AppDelegate.m
//  MultiViewDeckExample
//
//  Created by Tom Adriaenssen on 06/05/12.
//  Copyright (c) 2012 Tom Adriaenssen. All rights reserved.
//

#import "AppDelegate.h"
#import "IIViewDeckController.h"
#import "LeftViewController.h"
#import "BottomViewController.h"
#import "CenterViewController.h"
@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController* leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
    leftController = [[UINavigationController alloc] initWithRootViewController:leftController];

    UIViewController* bottomController = [[BottomViewController alloc] initWithNibName:@"BottomViewController" bundle:nil];
    bottomController = [[UINavigationController alloc] initWithRootViewController:bottomController];

    UIViewController *centerController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    centerController = [[UINavigationController alloc] initWithRootViewController:centerController];

    IIViewDeckController* secondDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:leftController 
                                                                                    leftViewController:bottomController];
    secondDeckController.leftSize = 66;
    secondDeckController.delegateMode = IIViewDeckDelegateAndSubControllers;

    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                    leftViewController:secondDeckController];
    deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
    
//    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:deckController];
//    deckController.navigationControllerBehavior = IIViewDeckNavigationControllerIntegrated;
//    self.window.rootViewController = navController;
    self.window.rootViewController = deckController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
