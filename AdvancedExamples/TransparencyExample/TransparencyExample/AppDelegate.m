//
//  AppDelegate.m
//  TransparencyExample
//
//  Created by Tom Adriaenssen on 25/04/13.
//  Copyright (c) 2013 Tom Adriaenssen. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "CenterViewController.h"
#import "IIViewDeckController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController* leftController = [[LeftViewController alloc] initWithNibName:@"LeftViewController" bundle:nil];
    leftController = [[UINavigationController alloc] initWithRootViewController:leftController];
    
    UIViewController *centerController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    centerController = [[UINavigationController alloc] initWithRootViewController:centerController];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                    leftViewController:leftController];
    deckController.delegateMode = IIViewDeckDelegateOnly;
    deckController.centerViewOpacity = 0.4;
    deckController.centerViewCornerRadius = 100;
    self.window.rootViewController = deckController;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
